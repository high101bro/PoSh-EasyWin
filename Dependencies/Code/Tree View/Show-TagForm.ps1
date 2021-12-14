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
# t9KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUAwOJElgSjJpL3VRyxj/2RC/rtTAwDQYJKoZI
# hvcNAQEBBQAEggEAB41G+sufkWfOEopqDqBzPhYQJpHNxJccVfTBaYQceHwFLHWe
# RWaZA0nEheRfwp7q2H+Pfh7X6spiU5ZPJNekkUyIoh6G38jmw5OGMs0X0pcxto0K
# Xz4evazVObP2dh9R+l1iKAVMJJ8tXxYLXZ6J6qjytZ4UrqEmT1tp/zhypuYATbRX
# v/46MDXAdaKqjR1eVwCj0XF+j4d+sGrshhJVx3gx5q5Ml1mGYXCsYKc0cuNMOZ0M
# CmS6kSJ94tTlic5NmLXZEy+E849gb0YGikO0/Yhud0AGcObDcGJuvsyKgx1UYOOh
# wnCPLbHJPvZJgJEZNSNFoFpIqDtaidGiPq/eaw==
# SIG # End signature block
