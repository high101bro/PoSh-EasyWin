$CommandsTreeViewRemoveCommandButtonAdd_Click = {
    if (Verify-Action -Title "PoSh-EasyWin" -Question "Do you want to remove the selected Custom Group or User Added Commands?") {
        $QueryHistoryRemoveGroupCategoryList  = @()
        $QueryHistoryRemoveUserAddedEntryList = @()
        $QueryHistoryKeepGroupCategoryList    = @()
        $QueryHistoryKeepUserAddedEntryList   = @()
        
        # Iterates through the command treeview and creates a list of non-checked commands
        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
        foreach ($root in $AllCommandsNode) {
            if ($root.text -match 'Custom Group Commands') {
                $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                foreach ($Category in $root.Nodes) {
                    $QueryHistoryRemoveGroupCategoryList += $Category
                    if (!($Category.checked)) { $QueryHistoryKeepGroupCategoryList += $Category }
                }
            }
            if ($root.text -match 'User Added Commands') {
                $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $QueryHistoryRemoveUserAddedEntryList += $Entry
                        if (!($Entry.checked)) { $QueryHistoryKeepUserAddedEntryList += $Entry }    
                    }
                }
            }
        }

        # Removes all commands
        foreach ($Entry in $QueryHistoryRemoveGroupCategoryList) { 
            $Entry.remove() 
        }
        foreach ($Entry in $QueryHistoryRemoveUserAddedEntryList) {
            $Entry.remove() 
        }
        
        # removes the button from view
        $Section1TreeViewCommandsTab.Controls.Remove($CommandsTreeViewRemoveCommandButton)
    
        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $QueryHistoryKeepGroupSelected = @()
        foreach ($Category in $QueryHistoryKeepGroupCategoryList) {
            foreach ($Entry in $Category.nodes) {
                $QueryHistoryKeepGroupSelected += [pscustomobject]@{
                    CategoryName = $Category.Text
                    Name         = $Entry.Text
                }
                Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Category.text)" -Entry "$($Entry.Text)" -ToolTip $Command.Command
            }
        }
        $script:CustomGroupCommandsList = $QueryHistoryKeepGroupSelected
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped


        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $CommandsUserAddedAddedList = @()
        $CommandsUserAddedToKeep = @()
        foreach ($Entry in $QueryHistoryKeepUserAddedEntryList) {
            Foreach ($command in $script:UserAddedCommands){
                if ($Entry.text -match $command.name -and $command -notin $CommandsUserAddedAddedList){
                    $CommandsUserAddedAddedList += $command
                    Add-NodeCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip "$($command.Command_WinRM_PoSh)"
                    $CommandsUserAddedToKeep += $command  
                }
            }
        }

        # Save remaining User Added Commands
        $script:UserAddedCommands = $CommandsUserAddedToKeep
        $script:UserAddedCommands | Export-Csv $CommandsUserAdded -NoTypeInformation

        # Save remaining Custom Group Commands List
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6AN3CsSw+Es0I/OwbwuSEnpb
# 6eKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUHtSfWeBH6BDqv+/s/ArPup1BPPMwDQYJKoZI
# hvcNAQEBBQAEggEArEZ8s0JpUcpTC/IfDZ6EcKPtx47H4n0jStMvrvKUk6E0U3Hp
# D/b0xxkhKRmShtdPZ6ilGhWJrt7eoztg1CA0lmYlIoAwetFt3SWuNOdLy7FPqdvV
# odfEI45K8kXWPg+zqgEAbAWaOqKDOuPx5BjEZfNTyOjM2y56AJELYuKLHHMdsG3r
# Cvf4fvDg9tWBc3GSStb0H+2iLJwV5o6JEpVuAWqI+K4WVRNV8ho4swyFeCgr1jhI
# NXJZz3CrWZX1TsmQ8OVrPk4ePAVUCLD8SFmkVeki86vAfJA7oTC5FxSxmk1kCiDs
# sg4hm4JtDQc57LVhZOlpAAOJg+Ci5/SqfkHuog==
# SIG # End signature block
