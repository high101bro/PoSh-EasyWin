
$Section1FileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "File Search"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 4
}
$MainLeftCollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Recursively goes through directories down to the specified depth
# Used for backwards compatibility with systems that have older PowerShell versions, newer versions of PowerShell has a -Depth parameter
Update-FormProgress "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"
. "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"

# This code is used within both the Individual and Session Based execution modes
Update-FormProgress "$Dependencies\Code\Main Body\Conduct-FileSearch.ps1"
. "$Dependencies\Code\Main Body\Conduct-FileSearch.ps1"

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Directory Listing (WinRM)"
    Left   = $FormScale * 3
    Top    = $FormScale * 15
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)


        $FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchDirectoryListingCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)


        $FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchDirectoryListingMaxDepthLabel.Left + $FileSearchDirectoryListingMaxDepthLabel.Width
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)


        $FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time is dependant on the directory's contents."
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingCheckbox.Top + $FileSearchDirectoryListingCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 330
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        $FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingLabel.Top + $FileSearchDirectoryListingLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 22
            MultiLine          = $False
            WordWrap           = $false
            Text               = "Enter a single directory"
            AutoCompleteSource = "FileSystem"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchDirectoryListingTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchDirectoryListingTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchDirectoryListingTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)


$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "File Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchDirectoryListingTextbox.Top + $FileSearchDirectoryListingTextbox.Height + $($FormScale * 25)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount

        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)


        $FileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)


        $FileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchFileSearchMaxDepthLabel.Left + $FileSearchFileSearchMaxDepthLabel.Width
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)


        $FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time depends on the number of files and directories, plus recursive depth."
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchMaxDepthTextbox.Top + $FileSearchFileSearchMaxDepthTextbox.Height + $($FormScale * 2)
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)


        $FileSearchSearchByFileHashLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Search by Filename or Filehash:"
            Left   = $FileSearchFileSearchLabel.Left
            Top    = $FileSearchFileSearchLabel.Top + $FileSearchFileSearchLabel.Height
            Width  = $FormScale * 175
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchSearchByFileHashLabel)


        Update-FormProgress "$Dependencies\Code\Main Body\Get-FileHash.ps1"
        . "$Dependencies\Code\Main Body\Get-FileHash.ps1"
        $FileSearchSelectFileHashComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text   = "Filename"
            Left   = $FileSearchSearchByFileHashLabel.Left + $FileSearchSearchByFileHashLabel.Width
            Top    = $FileSearchSearchByFileHashLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $HashingAlgorithms = @('Filename','MD5','SHA1','SHA256','SHA384','SHA512','RIPEMD160')
        ForEach ($Hash in $HashingAlgorithms) { $FileSearchSelectFileHashComboBox.Items.Add($Hash) }
        $Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashComboBox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        $FileSearchFileSearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchSearchByFileHashLabel.Top + $FileSearchSearchByFileHashLabel.Height + ($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine = $True
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryRichTextbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        $FileSearchFileSearchFileRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter FileNames; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchDirectoryRichTextbox.Top + $FileSearchFileSearchDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine  = $True
            ScrollBars = "Vertical" #Horizontal
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchFileRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchFileRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchFileRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileRichTextbox)


Update-FormProgress "$Dependencies\Code\Main Body\Search-AlternateDataStream.ps1"
. "$Dependencies\Code\Main Body\Search-AlternateDataStream.ps1"
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Alternate Data Stream Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchFileSearchFileRichTextbox.Top + $FileSearchFileSearchFileRichTextbox.Height + $($FormScale * 20)
    Width  = $FormScale * 260
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)


        $FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale *11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)


        $FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchAlternateDataStreamMaxDepthLabel.Left + $FileSearchAlternateDataStreamMaxDepthLabel.Width
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)


        $FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamMaxDepthTextbox.Top + $FileSearchAlternateDataStreamMaxDepthTextbox.Height
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        $FileSearchAlternateDataStreamDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamLabel.Top + $FileSearchAlternateDataStreamLabel.Height
            Width  = $FormScale * 430
            Height = $FormScale * 80
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine     = $True
            Add_MouseEnter = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryRichTextbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        . "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        . "$Dependencies\Code\Main Body\Get-RemoteAlternateDataStream.ps1"
        $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Retrieve and Extract Stream Data'
            Left   = $FileSearchAlternateDataStreamDirectoryRichTextbox.Left + $FileSearchAlternateDataStreamDirectoryRichTextbox.Width - $($FormScale * 200 - 1)
            Top    = $FileSearchAlternateDataStreamDirectoryRichTextbox.Top + $FileSearchAlternateDataStreamDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 200
            Height = $FormScale * 20
            Add_Click = $FileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryExtractStreamDataButton)
        Apply-CommonButtonSettings -Button $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU97UQ4BLEmIfiMPlVpShRUsHQ
# gkegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjHccx/4rfxADlNFEmaxzHyyd8MAwDQYJKoZI
# hvcNAQEBBQAEggEASn91QCdt2JT5ktQOGRdjkSUjjfhefR17hJCTLTPyqMiAmYyW
# FvVldFJkIy3o9fhMmDHE/1S+PP0E4MXKqaSToGQLcnd85hjl7qpgwIRS64QjbrWz
# FrpT3bU/r4xKsB5tbcIPyiLnUyBYEE5HXBsUHT+2/zc9hH0VI9/X7+zeegtMBstc
# GFuY2dEboq9xdaw5+W9dEnleMH43bDml+uNJplhcUj6WHCJfSjD/W8T3t1gIlKJI
# qLkEkSAKbyPjDYoijucfC9b/uhRqbQBKB9pSqhkRXgE2h6NS6E5Y6hfCOgt1Iuvh
# SB2xk4q6EiOPMGHG50TJgJJsTBRjUysIr0noUA==
# SIG # End signature block
