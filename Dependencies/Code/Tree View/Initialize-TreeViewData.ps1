function Initialize-TreeViewData {
    <#
        .Description
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        $script:TreeNodeAccountsList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Accounts'
        $script:TreeNodeAccountsList.Tag = "Accounts"
        $script:TreeNodeAccountsList.Expand()
        $script:TreeNodeAccountsList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeAccountsList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    
        $script:AccountsListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:AccountsListSearch.Tag = "Search"
    }
    if ($Endpoint) {
        $script:TreeNodeComputerList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Endpoints'
        $script:TreeNodeComputerList.Tag = "Endpoint"
        $script:TreeNodeComputerList.Expand()
        $script:TreeNodeComputerList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeComputerList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    
        $script:ComputerListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:ComputerListSearch.Tag = "Search"
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrremqsr7HBcNRuGFQsmhLys7
# ly6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUEvv1fXrms1CY5NVIR0rtnSyskgcwDQYJKoZI
# hvcNAQEBBQAEggEAfoolxHh0FC5Xk58CfvcWNcqQB8MRF44qRcCt/JIvnp4oOnIA
# jYYpH40YBDwhYB41UVu58JhTIcpi8rfmahphGFAzfzJN+dB3ZeDY659RKd4zSz3N
# xW0a+tvjFb4oK6r5OBbAZTKSSpxi0RozECw77SbiN3PUTGT8w2miXr1nlsZ7YvxD
# KjHsa8PQonZHoEXB+LuZ3vGN+0O0ItRtJ/G364ieTb3DzLRlB0uMdEsWND4Lb+3j
# 4wikgM+uk9gx1wqyogK/ZtvMv8yfDDp1Ktmu9A6bQScgdMK07IQVcNuRkfqST3gu
# vDbCuN8tzU8KboiDKv0cZlqiN3jflWr++agdEg==
# SIG # End signature block
