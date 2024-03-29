####################################################################################################
# ScriptBlocks
####################################################################################################
Update-FormProgress "Interactions.ps1 - ScriptBlocks"

####################################################################################################
# WinForms
####################################################################################################
Update-FormProgress "Interactions.ps1 - WinForms"

$Section1InteractionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Interactions  "
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 0 }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$MainLeftTabControl.Controls.Add($Section1InteractionsTab)


$MainLeftSection1InteractionsTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Main
$MainLeftSection1InteractionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Muliple-Endpoints.png"))
# Index 1 = Options
$MainLeftSection1InteractionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Executable.png"))
# Index 2 = Packet Capture
$MainLeftSection1InteractionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\pcap.png"))


$MainLeftSection1InteractionsTabTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Interactions TabControl"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * 557 }
    ShowToolTips  = $True
    SelectedIndex = 0
    Appearance    = [System.Windows.Forms.TabAppearance]::Buttons
    Hottrack      = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    ImageList = $MainLeftSection1InteractionsTabControlImageList
}
$Section1InteractionsTab.Controls.Add($MainLeftSection1InteractionsTabTabControl)


Update-FormProgress "$Dependencies\Code\Main\Tabs\Interactions Multi-Endpoint Actions.ps1"
. "$Dependencies\Code\Main\Tabs\Interactions Multi-Endpoint Actions.ps1"


Update-FormProgress "$Dependencies\Code\Main\Tabs\Interactions Executables.ps1"
. "$Dependencies\Code\Main\Tabs\Interactions Executables.ps1"


# This tab contains fields specific to packet capturing
# Feilds for the legacy netsh trace and the upcoming native Win10 Packet Capture
Update-FormProgress "$Dependencies\Code\Main\Tabs\Interactions Packet Capture.ps1"
. "$Dependencies\Code\Main\Tabs\Interactions Packet Capture.ps1"










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsijMUyh/SfWvCmqMPgPyAw9h
# pMKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUM2Gn1m8xla31v161YFV0FaZmWMUwDQYJKoZI
# hvcNAQEBBQAEggEALNOOW9FUE0PjXvLGCpTruqxsUjVOOfncn6dkHrnX7GQ1Ny7u
# vLDzCvLfvyyG4nubcvmH1dWeyJW4rRrCUlLdd2DnUqcwfewVFlBIDtvfTf9YvSnJ
# 2Ag+Jy50XnXQLxubnRWck8sUhOtY3PJ3ID9rBh5dguXkoaMatnSnuYhJd27Rsgwx
# utiqhe99znZuTfS0YINyYC0Q+Q+bIQ5KsLFp9E9QG3vr9BJyiEiO6cFZo9MWsl7I
# rIlD3LdBAzxrs0OUDFnUlLGIYq6bEhziH2YPwO4gI/RV6hImpWZbEo0i4CKVZTvK
# J0rUkgpXnSgdjnZXhNgSiaiQBMMM0yTicgqvdg==
# SIG # End signature block
