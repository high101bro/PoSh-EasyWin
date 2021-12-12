
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 100 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistrySearchDirectoryRichTextboxAdd_MouseLeave
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
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyItemPropertyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyItemPropertyNameCheckbox.Location.X
                  Y = $RegistryKeyItemPropertyNameCheckbox.Location.Y + $RegistryKeyItemPropertyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueNameSearchRichTextboxAdd_MouseLeave
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueDataSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueDataSearchRichTextboxAdd_MouseLeave
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpL5bAhhylxa0B9CHx/FpEfIx
# ViqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUznKXIwIw4fY4mtTv0uYAzIaJKkwwDQYJKoZI
# hvcNAQEBBQAEggEAcEdTyS9RA9i54aPIvZN02mIBLP671zsQFZq2cE4P6Jc1Bzzc
# r8AAjVDBNEV1zonF/0Fg5ET8JDrByN3AgbDphielVA1HUVxTFKFsXZEeIMCsN5S9
# PTC/qjNIRvfQ4nJJX7Ju2Yh9DumAk8LHNlJu5y+yeJlOMYomPH+y7dFNmIRWtUds
# 6WPx44W3IlmO6w+chmX8nMmImhh1FN71o/QuEm9McfMRV2l6v9MKUculHbydWwUL
# AjjjPDszdUoAuqAkPVebyuR0xive8UyjYRx4fMnlovzdemzpkdo1Mg6tje6Eoa6a
# I6VtxfSzJOCllQxGC+VtdMb73idTYQDVOoHk1A==
# SIG # End signature block
