$NetworkLiveSearchRemoteIPAddressSelectionButtonAdd_Click = {
    Import-Csv "$script:EndpointTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
    $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
    $IPAddressToBeScan = ""
    Foreach ($Port in $IPAddressColumn) {
        $IPAddressToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchRemoteIPAddressRichTextbox.Lines -eq "Enter Remote IPs; One Per Line") { $NetworkLiveSearchRemoteIPAddressRichTextbox.Text = "" }
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text  = $NetworkLiveSearchRemoteIPAddressRichTextbox.Text.Trim("")
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfGU6kqIiU4zfm29KxdHOWbjI
# q/agggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDTC5QKh/wwmR594wBUeS4ymsJhQwDQYJKoZI
# hvcNAQEBBQAEggEATOtxJNHfrqOysbHu5Nm2UdEdGRtoOYyIS0UZ9DKv+1OzQX/x
# C2xdBWUJo8cz9fBDjZzg4W2UQUS7wR58m2S9bG22XE7618ygQ3eb+Lyqfsl0uzey
# pOKyX0WaYG7DLQD6s9NcRCrkf1yPnkqLxZ0yCskdbybXGsPxb9TZLqUlbYTiHyYc
# /45ilh5uIOECMW65sJdQIkk9Zt8d/iPseiJlVFTzN5NngbolltbckNbhsi1w3/zj
# S8iqnE6l+hqmd+S4Q+FIkJypUn83k6TOKKp3wyujn6B5dZ/PtGAkvi6Dqu1/QJRW
# 1PNlpqiR8OANEJOWjFiytkieahMpfHDDaoqeYQ==
# SIG # End signature block
