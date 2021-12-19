$AllEventLogNames = wevtutil enum-logs
$EventLogDetails = @()
Foreach ($LogName in $AllEventLogNames) {
    $EventLogMetadata = wevtutil get-log $LogName
            
    $EventLogObject = [pscustomobject]@{}
            
    ForEach ($line in $EventLogMetadata){
        $Name  = $line.split(':').trim()[0]
        $Value = $line.split(':').trim()[1]
        if ($Value) {
            $EventLogObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        }
    }
    $EventLogDetails += $EventLogObject
}
$EventLogDetails `
| Select-Object -Property @{n='Name';e={$_.Name}}, @{n='Enabled';e={$_.Enabled}}, @{n='Type';e={$_.Type}}, @{n='OwningPublisher';e={$_.OwningPublisher}}, @{n='Isolation';e={$_.Isolation}}, @{n='LogFileName';e={$_.LogFileName}}, @{n='MaxSize';e={$_.MaxSize}}, @{n='FileMax';e={$_.FileMax}}, @{n='Retention';e={$_.Retention}}, @{n='AutoBackup';e={$_.AutoBackup}} `
| Sort-Object -Property @{e="Enabled";Descending=$True}, @{e="Name";Descending=$False}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQvS2RhCxBFoZjZPo3nMV4cWw
# ZBmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoFb8T8JGfU6sqAYPQg+/e8ykYKowDQYJKoZI
# hvcNAQEBBQAEggEAd3UNZAQeIEPfzUBnogl7xBGvDpoG8LSC+PZwivIC6BKPdW4s
# ggEvd3Gczqoeuf3Cax6vdRfEdgG+EfQeVFnxlXTYqkxTVthUvjEZr7wZLyvq5zOa
# ITzgFFFrBxGeYcVHT9mb0rUG301WSBdKVyICqZOGfCRKcpNObnXC7gg8nrWuboOk
# 6BvxeOWatbCns1SjUAIn4CgFa6xeTFtBBaZ8ItU4OK43jLJQFppJeH4yil47upuN
# OzN5ZZNfhj+nyMIDqZe0d8+ywgN6qCY0DitztPxRtL87jjYQ0kj9zKd4IUtb6mk+
# JqL0djnRNez5Y9X3ivQ9lR9K5jsfIqfRl7ax2Q==
# SIG # End signature block
