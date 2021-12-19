param(
    $CredentialXML,
    $TargetComputer,
    $PivotHost
)
function Pivot-PSSession {
    param(
        $SessionId,
        $TargetComputer
    )
    while ($Command -ne "exit") {
        $Session = Get-PSSession -Id $SessionId
        $PivotHost = $Session.ComputerName
        Write-Host "[$PivotHost -> $TargetComputer]: Pivot> " -NoNewline
        $Command = Read-Host
        
        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }        
        elseif ($Command -ne "exit") {
            function Pivot-Command {
                param(
                    $Command,
                    $TargetComputer,
                    $Credential
                )
                Invoke-Command `
                -ScriptBlock {
                    param($Command)
                    Invoke-Expression -Command "$Command"
                } `
                -ArgumentList @($Command,$null) `
                -ComputerName $TargetComputer `
                -credential $Credential `
                -HideComputerName
            }
            $PivotCommand = "function Pivot-Command { ${function:Pivot-Command} }"
            Invoke-Command `
            -ScriptBlock {
                param($PivotCommand,$Command,$TargetComputer,$Credential)
                . ([ScriptBlock]::Create($PivotCommand)) #| Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:ComputerName -PassThru

                Pivot-Command -Command $Command -TargetComputer $TargetComputer -Credential $Credential
            
            } `
            -Session $Session `
            -ArgumentList @($PivotCommand,$Command,$TargetComputer,$Credential) `
            -HideComputerName
        }
        elseif ($command -eq "exit") {
            $Session = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}

$Credential = Import-CliXML $CredentialXML

$PivotSession = New-PSSession -ComputerName $PivotHost -Credential $Credential
Pivot-PSSession -SessionId $PivotSession.Id -TargetComputer $TargetComputer


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmoxAhky8eq2ByFL8kiPc9Rkv
# CgGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNav+1XrP5LFk+KuJ9s6zDFxDTKMwDQYJKoZI
# hvcNAQEBBQAEggEAVmprxBRWJkogp5Ln1+yIwxLSFLjv9iFtSG82Fpz/SE9hUmHK
# C8hxLCH/kP307OZJNhf7tEmBaZffHN0BjKbzT9/6d8YUZJW0bbSaJ5d+DAk+VBYz
# cPBUzaXjNZpyg2d98l9qeGhGxe7Gl14E4h7sjQzaTvxaEwBDVV+EotKvHRWaXBQI
# vl+h3y6BIZykZh4fLemmeeEPfIcPqxVj4vnTt2lW0F97rr13kKQDkmHH1gwzwxYc
# PkB+gZ1YPXRJOW0pKl4TfzGF9T9OoDrimz4gM/uxB7+v1LjEHE0z7swm8IADlVB1
# 4cHOtXFK6fPCT4L70W8Ys3PyuLOZDBUOXHUapA==
# SIG # End signature block
