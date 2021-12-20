function Add-TreeViewCommand {
    param (
        $RootNode,
        $Category,
        $Entry,
        $ToolTip
    )
    $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = "$Entry"
        Text = "$Entry"
    }

    if ($ToolTip) {
        $newNode.ToolTipText  = "$ToolTip"
    }
    else {
        $newNode.ToolTipText  = "No Unique Data Available"
    }

    If ($RootNode.Nodes.Tag -contains $Category) {
        $CommandNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    Else {
        $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = $Category
            Text = $Category
            Tag  = $Category
            #ToolTipText   = "Checkbox this Category to query all its hosts"
        }
        #$CategoryNode.Expand()

        if ($Category -match '[\[\(]WinRM[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Windows Remote Management (WinRM)
Protocols: HTTP(WSMan), MIME, SOAP, XML
Port:      5985/5986 (WinRM v2+)
                80 (WinRM v1)
                47001 (If a WinRM listener not created)
                Any (listeners can be configured on any port)
Encrypted: Yes, HTTP  - message level encryption
                Yes, HTTPS - added TLS protocol encyption
OS:        Win7 / 2008R2+
                Older Operating Systems with WinRM installed
Data:      Deserialized Objects
Pros:      Works With PoSh-EasyWin's Monitor Jobs Feature
                Single Port required
                Can establish sessions with endpoints
                Supports any cmdlet and native commands
Cons:       Requires WinRM service
                Many admins/networks disable this if not used
"@
        }
        elseif ($Category -match '[\[\(]RPC[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Remote Procedure Call / Distributed COM
Protocols: RPC/DCOM
Encrypted: Not Encrypted (clear text)
Ports:     135, Random High
OS:        Windows 2000 and above
Data:      PowerShell = Deserialized Objects
                Native CMD = Serialized Data
Pros:      Works With PoSh-EasyWin's Monitor Jobs Feature
                Works with older Operating Systems
                Does not require WinRM
Cons:      Uses random high ports
                Not firewall friendly
                Transmits data in clear text
"@
        }
        elseif ($Category -match '[\[\(]SMB[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Server Message Block (via PSExec.exe)
Protocols: SMB (and NetBIOS)
Encrypted: Yes, v3.0+
Ports:     445 and 139 (over NetBIOS)
OS:        Port 445 - Windows 2000 and above
Data:      Serialized Data (PoSh-EasyWin will convert it)
Pros:      Works with older Operating Systems
                Access to domained and non-domained hosts
                Does not require WinRM or RPC
Cons:      Does NOT Work With PoSh-EasyWin's Monitor Jobs Feature
                Not natively supported, requires PSExec.exe
                Creates the service: PSEXEC
                May be blocked via Anti-Virus / Endpoint Security
                May be blocked via Application White/Black Listing
"@
        }
        elseif ($Category -match '[\[\(]SSH[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Secure Shell (SSH)
Protocols: SSL/TLS (Secure Socket Layer/Transport Socket Layer)
Encrypted: Yes
Ports:     22 (default)
OS:        Windows 10+ and Server 2019+ (OpenSSH)
Data:      Serialized Data (PoSh-EasyWin will attempt to convert it)
Pros:      Access to Linux and Windows systems with SSH enabled
                Access to domained and non-domained hosts                
Cons:      Does NOT Work With PoSh-EasyWin's Monitor Jobs Feature
                PoSh-EasyWin uses plink and kitty (more compatiable)
                SSH is often used on non-default (port 22) ports
"@
        }
        else { $CategoryNode.ToolTipText = "This is the directory name of the commands executed previously at that momemnt." }

        $CategoryNode.NodeFont   = New-Object System.Drawing.Font("Courier New",$($FormScale * 10),1,1,1)
        $CategoryNode.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $Null     = $RootNode.Nodes.Add($CategoryNode)
        $CommandNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    $Null = $CommandNode.Nodes.Add($newNode)
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWa/fn/TbSoQOoPhGgfEA/By3
# l4ygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUogWUEDRV3ZqOfkewZrBSeaPHxL0wDQYJKoZI
# hvcNAQEBBQAEggEAZ/5z3hLKjfUF+sfju/rIvC0u1bt40wTgG/qwnV3YHB26DOxj
# 7FAPup4hmSKAUb9lyuV/hVxjmw9JNiv6nZfKbBOV1oyKZidqttCx3YqhThHSoD3Q
# 40JO1p4el9DDQH5yErYTtC9lxc0eUpPJcfIFi6E/dpCAOSnCUbAG+ykYX8UOPbSM
# +cgchH7kpNEjGm3Dp10Qsv7btXtxtOD3UD7a6907+1Ph/ZcUkK496cNG8EivXcXF
# /JygbMDU95M18zTfte0DsQSEJdBIsCpBGo7GfbfCytbeY9GhbtMf9BG9jmVTM2Xo
# FBh28fNFPZvLW3xR7uuv9fAYfjOxAW2HwnHCJQ==
# SIG # End signature block
