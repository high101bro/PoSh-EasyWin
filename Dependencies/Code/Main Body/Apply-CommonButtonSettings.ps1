
function Apply-CommonButtonSettings {
    param($Button)
    $Button.Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    $Button.ForeColor = "Black"
    $Button.Flatstyle = 'Flat'
    $Button.UseVisualStyleBackColor = $true
    #$Button.FlatAppearance.BorderSize        = 1
    $Button.BackColor = 'LightGray'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    <#
    $Button.BackColor = 'LightSkyBlue'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DodgerBlue
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::PowderBlue

    $contextMenuStrip1 = New-Object System.Windows.Forms.ContextMenuStrip
    $contextMenuStrip1.Items.Add("Item 1")
    $contextMenuStrip1.Items.Add("Item 2")
    $Button.ShortcutsEnabled = $false
    $Button.ContextMenuStrip = $contextMenuStrip1
    #>
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwuQh7aqa7mA3V9YYoF2pVsgD
# N7qgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUbDrel7AH85JSDztc0/VEoyR63EUwDQYJKoZI
# hvcNAQEBBQAEggEAldTw7ET7PwCLylCn9iSV254LJuZz7Hup4/19fRmJOd/0TZQp
# 7sDWrpC4aMzwf+c3mlgkMS+QyYJoN52/TCZE2ieZXu5pmf8GLtoy/GW8ImGe9eif
# RhRvI9PouyQYXXaHrdbHlhWJ4Z/1lz1sG44l40/c/pqw/6BfG6wsw/W6psPV/cnl
# MzGb55MB/XjBFbtUR3XX0heBiffNB7WSMNMEYZAXjsgG7r+Ppv277WpU9RYulLRe
# jd/jC/yl5JA2JR3oUHqhJug/iIWFwN0wB6o17dyD5buwnQLXl9dtFat8ZReTotPz
# NIzl6eqdKgZi4YcO99O/2YJJmCpEWS6NaCEGTw==
# SIG # End signature block
