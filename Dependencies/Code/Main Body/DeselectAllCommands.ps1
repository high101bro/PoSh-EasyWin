function Deselect-AllCommands {
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        $root.Checked   = $false
        $root.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $root.Collapse()
        if ($root.text -notmatch 'Custom Group Commands') { $root.Expand() }
        foreach ($Category in $root.Nodes) {
            $Category.Checked   = $false
            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            $Category.Collapse()
            foreach ($Entry in $Category.nodes) {
                $Entry.Checked   = $false
                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }

    foreach ($CheckBox in $script:AllCheckBoxesList) {
        $CheckBox.checked = $false
        $CheckBox.ForeColor = 'Blue'
    }

    $script:PreviousQueryCount = 0
    $script:SectionQueryCount = 0

    # This has the added affect of updating the command count which in part has to do with the disable/color change of the 'Execute Script' button
    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZnw+tJ0chesELvaStARq5daq
# uJagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5TS00kclQ9ywwwnLc1Jc979nTSYwDQYJKoZI
# hvcNAQEBBQAEggEARYMZ1jEY7n/5Ts9axBGcZx+aNyvuks2wk+2Yd3qI2f8WKORt
# lFQNkSt+rbcSo9zl9dMhZhYiHwTeL8NXckqxYO7Fr7izZ8qMKn4up9Kya3aWGQuZ
# PHlM6/Mxdc3pOvnJl97fXZjDRibfdvCpNRBf9dmEpDFhGIlzxprbatq0uenypb7Z
# +aMvdTvhgDNOM1HuNpgXevbPqDRdlaY+DE6yk+wpInaw+vtb2oEiMtSu/U/hvC3O
# ZF2Oh27rO/Sn4gl6g5FK0ORmtNkFvVACQF+bKXUtDSamaWkcpvOixGDu1YhWE/XI
# bE3uUEDyqeYq5vPfBHqJOMBV4Papc6+JOCE0Vw==
# SIG # End signature block
