function Show-TagForm {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )
    if ($Endpoint){
        $script:ComputerListMassTagValue = $null
        $ComputerListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
            Text = "Tag Endpoints"
            Size     = @{ Width  = $FormScale * 350
                          Height = $FormScale * 115 }
            StartPosition = "CenterScreen"
            Font = New-Object System.Drawing.Font('Courier New',$($FormScale * 11),0,0,0)
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        #$ComputerListMassTagForm | select *
        $ComputerListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Tag Name:"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 14 }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
        }
        $ComputerListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = ""
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $ComputerListMassTagNewTagNameLabel.Size.Width + $($FormScale * 5)
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 215
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            #DataSource         = $ArrayIfNotAddedWIth .Items.Add
        }
        #$TagListFileContents = Get-Content -Path $TagAutoListFile
        ForEach ($Tag in $TagListFileContents) {
            $ComputerListMassTagNewTagNameComboBox.Items.Add($Tag)
        }
        $ComputerListMassTagNewTagNameComboBox.Add_KeyDown({
            if ($_.KeyCode -eq "Enter" -and $ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        })
        $ComputerListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Apply Tag"
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $($FormScale * 104)
                          Y = $ComputerListMassTagNewTagNameLabel.Location.Y + $ComputerListMassTagNewTagNameLabel.Size.Height + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                if ($ComputerListMassTagNewTagNameComboBox.text -ne '') {
                    $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                    $ComputerListMassTagForm.Close()
                }
            }
        }
        Apply-CommonButtonSettings -Button $ComputerListMassTagNewTagNameButton
        $ComputerListMassTagForm.Controls.AddRange(@($ComputerListMassTagNewTagNameLabel,$ComputerListMassTagNewTagNameComboBox,$ComputerListMassTagNewTagNameButton))
        $ComputerListMassTagForm.Add_Shown({$ComputerListMassTagForm.Activate()})
        $ComputerListMassTagForm.ShowDialog()
    }
    elseif ($Accounts){
        $script:AccountsListMassTagValue = $null
        $AccountsListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
            Text = "Tag Accounts"
            Size     = @{ Width  = $FormScale * 350
                          Height = $FormScale * 115 }
            StartPosition = "CenterScreen"
            Font = New-Object System.Drawing.Font('Courier New',$($FormScale * 11),0,0,0)
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        #$AccountsListMassTagForm | select *
        $AccountsListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Tag Name:"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 14 }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
        }
        $AccountsListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = ""
            Location = @{ X = $AccountsListMassTagNewTagNameLabel.Location.X + $AccountsListMassTagNewTagNameLabel.Size.Width + $($FormScale * 5)
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 215
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            #DataSource         = $ArrayIfNotAddedWIth .Items.Add
        }
        #$TagListFileContents = Get-Content -Path $TagAutoListFile
        ForEach ($Tag in $TagListFileContents) {
            $AccountsListMassTagNewTagNameComboBox.Items.Add($Tag)
        }
        $AccountsListMassTagNewTagNameComboBox.Add_KeyDown({
            if ($_.KeyCode -eq "Enter" -and $AccountsListMassTagNewTagNameComboBox.text -ne '') {
                $script:AccountsListMassTagValue = $AccountsListMassTagNewTagNameComboBox.text
                $AccountsListMassTagForm.Close()
            }
        })
        $AccountsListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Apply Tag"
            Location = @{ X = $AccountsListMassTagNewTagNameLabel.Location.X + $($FormScale * 104)
                          Y = $AccountsListMassTagNewTagNameLabel.Location.Y + $AccountsListMassTagNewTagNameLabel.Size.Height + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                if ($AccountsListMassTagNewTagNameComboBox.text -ne '') {
                    $script:AccountsListMassTagValue = $AccountsListMassTagNewTagNameComboBox.text
                    $AccountsListMassTagForm.Close()
                }
            }
        }
        Apply-CommonButtonSettings -Button $AccountsListMassTagNewTagNameButton
        $AccountsListMassTagForm.Controls.AddRange(@($AccountsListMassTagNewTagNameLabel,$AccountsListMassTagNewTagNameComboBox,$AccountsListMassTagNewTagNameButton))
        $AccountsListMassTagForm.Add_Shown({$AccountsListMassTagForm.Activate()})
        $AccountsListMassTagForm.ShowDialog()
    }
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY085MRHtSV7XPt0781aVMJQg
# t9KgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUAwOJElgSjJpL3VRyxj/2RC/rtTAwDQYJKoZI
# hvcNAQEBBQAEggEAlyOcp736qji3Ax9rwLAZWu3Fs8B9mTCBBYHlhK3nJPOtnW4v
# WBLBI9csRjwenRBz8L69Oh5JY2Ne4fzqR/1eErDdtMVr5RYvKHCRQYXcH1VPjyae
# QnKM3r7I9HstdH55umfWU/nk2lN48jzuZiZd2HwvILcv7YPaY/38mQ0S37xfXtYx
# ODblr86F3zcnCg7gJt85VnjwWXoDZGit0yMhsb5qlENRC0OsV8KOo/UmB6HkZEFO
# FN98A1dgKHQ6WyBGBPs4OU97Lfb44qsmwEML5TChJXGI4U90g8hwLrScs/mCXB1Y
# 8pCrujsilxRk+vbtvjWDV8fT4NFvvtzHqbs3DQ==
# SIG # End signature block
