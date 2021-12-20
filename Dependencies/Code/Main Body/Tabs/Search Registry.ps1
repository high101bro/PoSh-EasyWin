####################################################################################################
# ScriptBlocks
####################################################################################################

$RegistryValueNameSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter one Value Name per line
+  Supports RegEx, examples:
    +  [aeiou]
    +  ([0-9]{1,3}\.){3}[0-9]{1,3}
    +  [(http)(https)]://
    +  ^[(http)(https)]://
    +  [a-z0-9]
+  Will return results with partial matches
"@
}

$RegistryValueDataSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter FileNames
+  One Per Line
+  Example: svchost
+  Filenames don't have to include file extension
+  This search will also find the keyword within the filename
"@
}

$RegistrySearchDirectoryRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter Directories
+  One Per Line
+  Example: HKLM:\SYSTEM\CurrentControlSet\Services\
"@
}


$RegistryKeyNameSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter FileNames
+  One Per Line
+  Filenames don't have to include file extension
+  This search will also find the keyword within the filename
+  Example: dhcp
"@
}


####################################################################################################
# WinForms
####################################################################################################

Update-FormProgress "$Dependencies\Code\Main Body\Search-Registry.ps1"
. "$Dependencies\Code\Main Body\Search-Registry.ps1"
$Section1RegistryTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Registry  "
    Location = @{ X = $FormScale * $RegistryRightPosition
                  Y = $FormScale * $RegistryDownPosition }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 3
}
$MainLeftSearchTabControl.Controls.Add($Section1RegistryTab)


$RegistrySearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Registry Search (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        if ($this.Checked -eq $true){
            $RegistrySearchCheckbox.checked = $true
            if ($script:RegistrySelected -eq 'RegistryKeyItemPropertyNameCheckBox') {
                $RegistryKeyItemPropertyNameCheckbox.checked = $true
                $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryKeyNameCheckBox') {
                $RegistryKeyNameCheckbox.checked = $true
                $RegistryKeyNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryValueNameCheckbox') {
                $RegistryValueNameCheckbox.checked = $true
                $RegistryValueNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryValueDataCheckBox') {
                $RegistryValueDataCheckbox.checked = $true
                $RegistryValueDataCheckbox.ForeColor = 'Red'
            }
            else {
                $RegistryKeyItemPropertyNameCheckbox.checked = $true
                $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
            }
        }
        else {
            $RegistrySearchCheckbox.checked = $false
            $RegistryKeyItemPropertyNameCheckbox.checked = $false
            $RegistryKeyNameCheckbox.checked = $false
            $RegistryValueNameCheckbox.checked = $false
            $RegistryValueDataCheckbox.checked = $false

            $RegistrySearchCheckbox.ForeColor = 'Blue'
            $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
            $RegistryKeyNameCheckbox.ForeColor = 'Blue'
            $RegistryValueNameCheckbox.ForeColor = 'Blue'
            $RegistryValueDataCheckbox.ForeColor = 'Blue'                
        }
    
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}        
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchCheckbox)


$RegistrySearchRecursiveCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Recursive Search"
    Location = @{ X = $RegistrySearchCheckbox.Size.Width + $($FormScale * 85)
                  Y = $RegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 20 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor  = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchRecursiveCheckbox)
$script:RegistrySelected = ''


# $RegistrySearchItemPropertiesCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
#     Text     = "Item Properties"
#     Location = @{ X = $RegistrySearchCheckbox.Size.Width + $($FormScale * 85)
#                   Y = $RegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
#     Size     = @{ Width  = $FormScale * 200
#                   Height = $FormScale * 20 }
#     Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ForeColor  = "Black"
# }
# $Section1RegistryTab.Controls.Add($RegistrySearchItemPropertiesCheckbox)


$RegistrySearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "The collection time is depenant on the number of paths and queries entered, and more so if recursive is selected."
    Location = @{ X = $RegistrySearchCheckbox.Location.X
                  Y = $RegistrySearchRecursiveCheckbox.Location.Y + $RegistrySearchRecursiveCheckbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 40 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchLabel)


$RegistrySearchReferenceButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Location"
    Location = @{ X = $RegistrySearchLabel.Location.X + $RegistrySearchLabel.Size.Width + $($FormScale * 30)
                  Y = $RegistrySearchLabel.Location.Y + $($FormScale * 5)}
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 20 }
    Add_Click = {
        Import-Csv "$Dependencies\Reference Registry Locations.csv" | Out-GridView -Title 'PoSh-EasyWin Registry Reference Selection' -PassThru | Set-Variable -Name RegistryReferenceSelected
        $script:RegistrySearchDirectoryRichTextbox.text = ''
        foreach ($Registry in $RegistryReferenceSelected) { $script:RegistrySearchDirectoryRichTextbox.Lines += $Registry.Location}
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchReferenceButton)
Apply-CommonButtonSettings -Button $RegistrySearchReferenceButton


$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 100 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = { if ($this.text -eq "Enter Registry Paths; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter Registry Paths; One Per Line" } }
    Add_MouseHover = $RegistrySearchDirectoryRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistrySearchDirectoryRichTextbox)


$RegistryKeyItemPropertyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Item Property (no monitor)"
    Location = @{ X = $script:RegistrySearchDirectoryRichTextbox.Location.X
                  Y = $script:RegistrySearchDirectoryRichTextbox.Location.Y + $script:RegistrySearchDirectoryRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $true
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false

        $RegistrySearchCheckbox.ForeColor    = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
        $RegistryKeyNameCheckbox.ForeColor   = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'                

        $script:RegistrySelected = 'RegistryKeyItemPropertyNameCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes    

    }
}
$Section1RegistryTab.Controls.Add($RegistryKeyItemPropertyNameCheckbox)


#batman update the mouseover,hover,enter
$script:RegistryKeyItemPropertyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyItemPropertyNameCheckbox.Location.X
                  Y = $RegistryKeyItemPropertyNameCheckbox.Location.Y + $RegistryKeyItemPropertyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = { if ($this.text -eq "Enter Key Name; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter Key Name; One Per Line" } }
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyItemPropertyNameSearchRichTextbox)


$RegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (RegEx)"
    Location = @{ X = $RegistryKeyItemPropertyNameCheckbox.Location.X + $RegistryKeyItemPropertyNameCheckbox.Size.Width + $($FormScale * 10)
                  Y = $RegistryKeyItemPropertyNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $true
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false

        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Red'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'                

        $script:RegistrySelected = 'RegistryKeyNameCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes    
    }
}
$Section1RegistryTab.Controls.Add($RegistryKeyNameCheckbox)


$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = { if ($this.text -eq "Enter Key Name; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter Key Name; One Per Line" } }
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyNameSearchRichTextbox)


$RegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (RegEx)"
    Location = @{ X = $script:RegistryKeyItemPropertyNameSearchRichTextbox.Location.X
                  Y = $script:RegistryKeyItemPropertyNameSearchRichTextbox.Location.Y + $script:RegistryKeyItemPropertyNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $true
        $RegistryValueDataCheckbox.checked = $false
    
        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Red'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'

        $script:RegistrySelected = 'RegistryValueNameCheckbox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueNameCheckbox)


$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = { if ($this.text -eq "Enter Value Name; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter Value Name; One Per Line" } }
    Add_MouseHover = $RegistryValueNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueNameSearchRichTextbox)


$RegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (RegEx)"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X + $RegistryValueNameCheckbox.Size.Width + $($FormScale * 10)
                  Y = $RegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 20 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $true

        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Red'

        $script:RegistrySelected = 'RegistryValueDataCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueDataCheckbox)


$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)    
    Add_MouseEnter = { if ($this.text -eq "Enter Value Data; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter Value Data; One Per Line" } }
    Add_MouseHover = $RegistryValueDataSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueDataSearchRichTextbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "RegEx Examples"
    Location = @{ X = $script:RegistryValueDataSearchRichTextbox.Location.X + $script:RegistryValueDataSearchRichTextbox.Size.Width - $($FormScale * 100)
                  Y = $script:RegistryValueDataSearchRichTextbox.Location.Y + $script:RegistryValueDataSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 20 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
Apply-CommonButtonSettings -Button $SupportsRegexButton



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUueqOsRrwlNau/+etK+vMK8qI
# hP+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUMGLyfxmB/oMGNuWO00TA/YGGQS8wDQYJKoZI
# hvcNAQEBBQAEggEAkrxzu4TWR4BQJqvhvLDe0/ETFPZ1A7j3xsvK7hx/VQ/dBzzT
# SLnxgH3CDrYEIJ65agcf5V1RfyFCN1sgxZQs7nZppClBWYZQJGFnpWjb4BHyzYxy
# MCTsKyrfQFjxFgNDZATBeO2b3PMgJCVg9ZlWSw3lN2Q7YoB6Hz65bXXcBWsjkgJu
# QVGu6OFBItwZGPWqbTdGa/VVYbw66ot8R8ve1mSFcprMink3yNvydWNimyijbyl9
# 5WaU1D0KWpbnxT7aLhf2CHKmGzUbRiXqFWVy8yEn25nbAMqWNKtaSKq1x0Ggf7GL
# 8NGdp8ylzmshrkfXESio8Guu4f6iHiADv3jCmg==
# SIG # End signature block
