param(
    $CredentialXML,
    $ComputerList
)
function Enter-MultiPSSession {
    param(
        $SessionId,
        $ComputerList
    )
    while ($Command -ne "exit") {
        $PSSession = Get-PSSession -Id $SessionId

#        if ($PSSession.ComputerName.count -ge 1) {
#            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
#        elseif ($PSSession.ComputerName.count -eq 0) {
            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
        $Command = Read-Host

        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }
        elseif ($Command -ne "exit") {
            Invoke-Command `
            -ScriptBlock {
                param([string]$Command)
                . ([ScriptBlock]::Create("$Command")) | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:ComputerName -PassThru
            } `
            -Session $PSSession `
            -ArgumentList @($Command)
        }
        elseif ($command -eq "exit") {
            $PSSession = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}
$Credential = Import-CliXML "$CredentialXML"

$MultiEndpointSession = New-PSSession -ComputerName $ComputerList -Credential $Credential
Enter-MultiPSSession -SessionId $MultiEndpointSession.Id -ComputerList $ComputerList











# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFSobeqqVlDq1aI/wR0+HVuBp
# iN6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUMAHYgQ+1mSFUxeqRKxqPoRdLBlUwDQYJKoZI
# hvcNAQEBBQAEggEAFHi5UNMQmqYoVVsgsUo3Ca0ttUpbAb5WNOANjioPHFYbt7HC
# f9VtxPKzQBU1q3tuZkN11EPOa4eIBf4lx2QPWzdkD4dNyeVLJyKLpl8gjJqp6Mfq
# 77q6plDAXGbr2IMdb+7Z9SXyi+qw4xUEqDEKjXlBanD0iuU75PDPuj22MuihFgUw
# kak/JIZg/tXRbKKjLE1cfBEeeQjkod/WMu3Ob7qToeQ23QMTRttQ/VU5cYyMidRC
# D5foUiJ8BUYxesDtUgoLmNLb3vxf9B9tWxp0P7mtFX2wZbY3DK8vy71clvXJg/pk
# l0EUJg0XxXBMC2ymhOGu9SSzUqskDgN+GtzpWQ==
# SIG # End signature block
