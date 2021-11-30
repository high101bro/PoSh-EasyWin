$EnumerationResolveDNSNameButtonAdd_Click = {
    if ($($EnumerationComputerListBox.SelectedItems).count -eq 0){
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("DNS Resolution:  Make at least one selection")
    }
    else {
        if (Verify-Action -Title "Verification: Resolve DNS" -Question "Conduct a DNS Resolution of the following?" -Computer $($EnumerationComputerListBox.SelectedItems -join ', ')) {
            #for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }

            #$EnumerationComputerListBoxSelected = $EnumerationComputerListBox.SelectedItems
            #$EnumerationComputerListBox.Items.Clear()

            # Resolve DNS Names
            $DNSResolutionList = @()
            foreach ($Selected in $($EnumerationComputerListBox.SelectedItems)) {
                $DNSResolution      = (((Resolve-DnsName $Selected).NameHost).split('.'))[0]
                $DNSResolutionList += $DNSResolution
                $EnumerationComputerListBox.Items.Remove($Selected)
            }
            foreach ($Item in $DNSResolutionList) { $EnumerationComputerListBox.Items.Add($Item) }
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("DNS Resolution:  Cancelled")
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpBy98g4cGSYZaYebv9L/Ybhd
# EkWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPBwzq482Xn8a0TPDREyh/x2M/p4wDQYJKoZI
# hvcNAQEBBQAEggEAgeV4iPmetZpd0APgebSuu6xvvRqJ2R7inIJLFzcd/gC6z79b
# ZdqTBbJAeZ6qpJjM8Vly8sYPkTviYlhN3HQ61qJ5w3KUEctOKb46D6n7NKntLEuC
# 0WQhPjXdOpwqML0iqHLMzcyo+tmD/o7e6hp/phuohBhnpBF3MFOR5ZJtZ87LGHeJ
# d+OaVarFAqyRCB4anPAufP5fgCg8F6UCx6gK4HYNIVNX7NlFa/UHHUcqzok62ovv
# oQbboZ5hFp0OmRUXjpSOgZAnBlfPHVoCUAxREZPfIfvqLsXiq8k3vcgXZQ9rkh/y
# rBa2cWUNXrEiGYn8gNsZAdflDH3d2BfODd2f1g==
# SIG # End signature block
