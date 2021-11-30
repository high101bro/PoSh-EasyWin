Function Message-NodeAlreadyExists {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        $Message,
        $Account,
        $Computer,
        [Switch]$ResultsListBoxMessage
    )
    if ($Accounts) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        [system.media.systemsounds]::Exclamation.play()
        if ($Account){
            $AccountsNameExist = $Account
        }
        elseif ($Account.Name) {
            $AccountsNameExist = $Account.Name
        }
    
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$Message")
    
        if ($ResultsListBoxMessage) {
            $ResultsListBox.Items.Add("The following Account already exists: $AccountsNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            [System.Windows.MessageBox]::Show("The following Account already exists: $AccountsNameExist
- OU/CN:      $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)
- Created:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).Created)
- LockedOut:  $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).LockedOut)",'Error')
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).MACAddress)")
    }
    if ($Endpoint) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        [system.media.systemsounds]::Exclamation.play()
        if ($Computer){
            $ComputerNameExist = $Computer
        }
        elseif ($Computer.Name) {
            $ComputerNameExist = $Computer.Name
        }
    
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$Message")
    
        if ($ResultsListBoxMessage) {
            $ResultsListBox.Items.Add("The following Endpoint already exists: $ComputerNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            [System.Windows.MessageBox]::Show("The following Endpoint already exists: $ComputerNameExist
- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)
- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)",'Error')
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwzbPWKsEdUix+JlgfZZfjxtd
# 4SagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUl8WEmv7rLMyLJC/gxV18QQ9kdlwwDQYJKoZI
# hvcNAQEBBQAEggEAXfFqlFijAT/zE3rCo6NpE42xfRG/nsVnH4jkmpeOQIpX9QJJ
# fP9pQnfHBZkNJFP/0aa4TA7opIJ4f/BgrDXuQ0AieAp+7tD+sAT4D2HP5uSporHo
# mddw31d2JG8J7oiZyzqVgKnfuoLKfO8jebRS81Tnnp7Uxbnrjpw98t7T6bdCLd8D
# KWuF8AFNF69qONhc7ETJ9U9ppuFjVVoipUUsLasZjj58GFci3OOOxFOtHqpsyWU1
# pUcrChxz2NorDhn/CxYgxEHDZO98iM5KAXSS9GyqKIMG+W/M+uoIG73qC8LsAUSu
# PYzSacnWA5XcrqAjGf8/HyaJO3afOj5W6zlkog==
# SIG # End signature block
