function Add-NodeCommand {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvatEMy+ddaWki6b8VYujL/Ct
# 76ugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/+S0pWrsCAHEPwKvDO3y1xWHCdMwDQYJKoZI
# hvcNAQEBBQAEggEAuYYcPRmOiWPVGIsKt9S7NhzDnquicUUnzWuzKTeknnOHpmJO
# MYB0iAGGSWvxf3RyBIcKbKI/SwVk4sHVUIm4X7cfUUpMsVJaiwO9cnZaQaHeSual
# CgGnlJXyOeNpCpr7A9kFW6Q6dqJr0fINHRO0MQ+f8mFjxXCNe3CtT+yuS7U7sekL
# Ffyr6CdHZqxL4gjvwq0tZGXux47w723kZK+jGjNFpExn9a3dqNlG57b6yjAvb4o+
# Tke0Orf6y2/Sq4TEX9UDM9BggbYwso/4m+67K3qtgP1q2kHmm9G63AlKb/tv1fKh
# o9mKZ4JBI3JzdylVbbTbX8yVfi7ADrxj2rJSAg==
# SIG # End signature block
