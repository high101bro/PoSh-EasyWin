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
# iP6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXbWfJvPsw6t9HeoLVHoj9K9yjr0wDQYJKoZI
# hvcNAQEBBQAEggEAvhx7z20J49eiY1+BzRT96xomR/PfAVrCZtLazWEmeZAikEC8
# TKfbW/bb8VpeuH/7mTgei6/lxukl58Uli7X1Ev244t508okt1Sk6+VX1la9bjU/0
# bV3OwoQCz6CxnPSMQhCtIWfC4Ty5hUp9s5PguoE+hpIZYzt+pWW2jk27TEi8YYSL
# AQTzI4BJg93jJxGO2AQR1CsVKDIVNxvM0unId4JaQX4pzJClEHjHpYs80zD+xd+J
# tM+AF926A0BWSt1PBZR9Qc/VdzthyTl9rYsHHHiowofVssclQZKIGa9MRvvNNAzg
# qklZMS2vTDwjLOQF8KiqaIi2QYhQZJXCP/riPw==
# SIG # End signature block
