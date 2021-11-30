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
        $Section1CommandsTab.Controls.Remove($CommandsTreeViewRemoveCommandButton)
    
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5w1NqbHepSd1mAagKijt42rG
# QlqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUgnrch5Fs2MwYfnDd6icjvCSciNcwDQYJKoZI
# hvcNAQEBBQAEggEAGc8e6cOmb/byNKvMfUfbTe56Ukjas4dJT3C4VV+AMebIjQW3
# t8IQ5LXQvfSxnVv/G5dWfKGHONyljOfjjcYJug4fwioq61LO9ZsD3Pbm0chsMlvs
# hp3shvxqHAwa0TUh9q77wZsESK2lFtZ93uvOTbPB+3xtiMCFC0ZH7zGmmacrvKZM
# 0i8l4PDUiVP1rH6PQQ8um2ZiahEulMIG8AcaHvfPhWcp9FzxRSLDbIxNBmKvcwT0
# 45XJcppbaYVFGiPrzu4HY/0yW42trfU1i40wLn93I7Y14uWHtUdFQNlBd/A/Zzuv
# k4WEWq4BMVxxYZlNsrixFAC2gV1/l1+03O/1UA==
# SIG # End signature block
