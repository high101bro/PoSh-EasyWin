$OpNotesCreateReportButtonAdd_Click = {
    New-Item -ItemType Directory "$PoShHome\Reports" -ErrorAction SilentlyContinue | Out-Null
    if ($OpNotesListBox.SelectedItems.Count -gt 0) {
        # Popup that allows you select where to save the Report
        [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null
        #$OpNotesSaveLocation                 = New-Object -Typename System.Windows.Forms.SaveFileDialog
        $OpNotesSaveLocation                  = New-Object Microsoft.Win32.SaveFileDialog
        $OpNotesSaveLocation.InitialDirectory = "$PoShHome\Reports"
        $OpNotesSaveLocation.MultiSelect      = $false
        $OpNotesSaveLocation.Filter           = "Text files (*.txt)| *.txt"
        $OpNotesSaveLocation.ShowDialog()
        Write-Output $($OpNotesListBox.SelectedItems) | Out-File "$($OpNotesSaveLocation.Filename)"
    }
    else {
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add('You must select at least one line to add to a report!')
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUN57oeWHbNmxmzGUCZnRB5os5
# X2ygggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUxrJbsvuMVcFCU9WG/LG+YmywV4AwDQYJKoZI
# hvcNAQEBBQAEggEAZ7mFLBBEJHbpgeiICYqV5A/8XFZCyTHRFKQiQ9FldWNa/zQ9
# XzP8n5ZkoWsHOQjX9HJ4lpXRxLxijdcREJd7W+JPhEvNtOGAn60efKSiUQikhnLu
# DY9x3gpo5IXbhXw8jr1Gom3+IOh0BUuFHCyryaqohKxuC+8dNXz31Fi63ZM2OPF+
# r/53cuwzmuyuHJrLJf/IWrZ2OqLAu1Uh7d4MVOW1WXJ+QhMnBGlm/bHYIRlpmAAt
# 4ItcFNQqKPV3KcYjk/wgsF4XsBJv9hwsql8qbhaKzn98uUznAZeTtfiSAlyWUkhO
# frYckPIadqwDndG61XdgA17bbcoY00rM6/naRQ==
# SIG # End signature block
