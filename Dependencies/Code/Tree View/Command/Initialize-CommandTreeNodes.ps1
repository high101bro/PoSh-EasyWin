function Initialize-CommandTreeNodes {
    $script:TreeNodeCommandSearch = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "* Search Results          " -Property @{
        Tag       = "Search"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeEndpointCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "1) Endpoint Commands          " -Property @{
        Tag       = "Endpoint Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeActiveDirectoryCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "2) Active Directory Commands          " -Property @{
        Tag       = "ADDS Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeCustomGroupCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "3) Custom Group Commands          " -Property @{
        Tag       = "Custom Group Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeUserAddedCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "4) User Added Commands          " -Property @{
        Tag       = "User Added Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    
    $script:UserAddedCommands = @()
    if (Test-Path $CommandsUserAdded){ 
        $script:UserAddedCommands += Import-Csv $CommandsUserAdded
        foreach ($command in $script:UserAddedCommands) {
            Add-NodeCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip "$($command.Command_WinRM_PoSh)"
        }
    }
    else {$script:UserAddedCommands = $null}
    
    $script:TreeNodeCommandSearch.Expand()
    $script:TreeNodeEndpointCommands.Expand()
    $script:TreeNodeActiveDirectoryCommands.Expand()
    $script:TreeNodeCustomGroupCommands.Expand()
    $script:TreeNodeUserAddedCommands.Expand()

    #$script:TreeNodeCustomGroupCommands.Collapse()
    $script:CommandsTreeView.Nodes.Clear()

#    UpdateState-TreeViewData -Endpoint
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSQvnKbwolb6T4EyDw/CqG5rQ
# iP6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXbWfJvPsw6t9HeoLVHoj9K9yjr0wDQYJKoZI
# hvcNAQEBBQAEggEANQl181ljXksjO8PlaSiIG7vYTvgeTe9wb3VnSDy+gLxhw4pD
# OgmIz2DrU1OtvWzxtB3krpgg/crpoqEEYC7RNYnvpljJ79la1xcd6KheSpGC9bU3
# 2wAotj8XXf7q+kQhuTNWmRY4qHKZw9O4GkUIv9+6G3/1GFz012Ac772nlyQjNQde
# TlFMkaDugPM1F2SW9HFkrPZhwTgeYPPdTrFJQdoXmDUWK2qPq4I3HDMpl6YUak/V
# vc523ICQeiFyS7wrvvvtPKmYcHAtuYADBW/8qinun5O1McdjRpPZt/r6G81Nl8g/
# +Bdf62Vc1pE8Og/aW9/C+Sp6Fpf1ausyRKrNRQ==
# SIG # End signature block
