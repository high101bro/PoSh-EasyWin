$EndpointsWithNoSessions = @()
Foreach ($Endpoint in $script:ComputerList) {
    if ($Endpoint -notin $PSSession.ComputerName) { $EndpointsWithNoSessions += $Endpoint }
}
if ($EndpointsWithNoSessions.count -gt 0) {
    [system.media.systemsounds]::Exclamation.play()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Unchecked $($EndpointsWithNoSessions.Count) Endpoints Without Sessions")
    $PoShEasyWin.Refresh()
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
    foreach ($root in $AllTreeViewNodes) {
        foreach ($Category in $root.Nodes) {
            $Category.Checked = $False
            $EntryNodeCheckedCount = 0
            foreach ($Entry in $Category.nodes) {
                if ($EndpointsWithNoSessions -icontains $($Entry.Text)) {
                    $Entry.Checked         = $False
                    $Entry.NodeFont        = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor       = [System.Drawing.Color]::FromArgb(0,0,0,0)
                }
                if ($Entry.Checked) {
                    $EntryNodeCheckedCount += 1
                }
            }
            if ($EntryNodeCheckedCount -eq 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    Start-Sleep -Seconds 3
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4kkKnm54yPrwAL/tzlR0FAyz
# ckigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUw54LZ7Dqta2mvXfNZsO+yH8t8JMwDQYJKoZI
# hvcNAQEBBQAEggEAIh6p3GfXiPZhDBFNKYmRGBDp10Ni+TRsZdPCN9Wv4kiMeB9v
# 5Lq00H2KZtgI694XiLqEF93jW4Vo1Ld8TtQioM7IkITUMkX0FmhnH0vYQ2QImzAo
# DApHs7U5ltstwvzRAWpppFssIaBaAwDqw02ROsnFOFEMZIfMv+xIZtwM4NNHLb+6
# CYBUGDwYESvWZFVnxoguA0vLSdOY0NzW8qWa2Mwvh7jZW3UxMD8qZp9+fOxspjLS
# Y5Q9TPM+fySmfzGUC3ZtNEbLRGthNmE4xbhlIUCoqj0FtIzWt8zc3ormN9fH2Joz
# HSOp8fYn9xiwVDzjHijxK/lBl6tdC84Up+HiQA==
# SIG # End signature block
