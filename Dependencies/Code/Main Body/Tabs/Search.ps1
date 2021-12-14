
$Section1SearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Search  "
    UseVisualStyleBackColor = $True
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageIndex = 1
}
$MainLeftTabControl.Controls.Add($Section1SearchTab)

$MainLeftSearchTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Query
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))
# Index 1 = Accounts
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png"))
# Index 2 = Event-Viewer
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Event-Viewer.png"))
# Index 3 = Registry 
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Registry.png"))
# Index 4 = File-Search
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\File-Search.png"))
# Index 5 = Network
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Network.png"))
# Index 6 = Packet Capture
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\pcap.png"))
# Index 7 = Processes
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Processes.png"))
# Index 8 = Event Logs / Chainsaw
$MainLeftSearchTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\ChainSaw.png"))


$MainLeftSearchTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * (557 + 5)}
    ShowToolTips  = $True
    SelectedIndex = 0
    ImageList     = $MainLeftSearchTabControlImageList
    Appearance    = [System.Windows.Forms.TabAppearance]::Buttons
    Hottrack      = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    Multiline = $true
}
$Section1SearchTab.Controls.Add($MainLeftSearchTabControl)


# This tab contains fields specific to assist with querying account information such as
# account logon activeity, currently logged on users, and PowerShell logons
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Accounts.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Accounts.ps1"


# This tab contains fields specific to assist with querying for file names and hashes
# Also supports searching for Alternate Data Streams (ADS) and their extraction/retrieval
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search File Search.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search File Search.ps1"


# This tab contains fields specific to assist with querying event logs
# It also has the settings to specify and limit Search to narrow queries,  
# reduce unnecessary data returned, and lower collection time 
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Event Logs CSV.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Event Logs CSV.ps1"


# This tab contains fields specific to pulling back event logs for viewing with Windows Event Viewer and/or processing with Chainsaw.exe
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Event Logs EVTX.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Event Logs EVTX.ps1"


# This tab contains fields specific to assist with querying the registry
# for names, keys, and values
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Registry.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Registry.ps1"


# This tab contains fields specific to search for specific process related information
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Processes.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Processes.ps1"


# This tab contains fields specific to assist with querying network status
# Such as local/remote IPs and ports, processes that start connnections, and dns cache
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Search Network.ps1"
. "$Dependencies\Code\Main Body\Tabs\Search Network.ps1"


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGF4c9NatsLsbx42fJB3aEaI4
# Ti+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPDvwkPA9BKpLl8w0cpJTfCcqScowDQYJKoZI
# hvcNAQEBBQAEggEAi25LIf7iRVOFBBsdWvZgcLTQJTRRx2MzgDoePo7JzclvPQBF
# Vsi5J1wqA8BQG2uLTiBQq3FCp+gtlumgl/9ZxyujV2Ozbl4FVuCggUa0NNDsoVYm
# YZURv1Uiv6qjcdCEaTpFMqD8ykMTg5uiBjlTii0miJuS1irdIAdNFFoS6mdZoj0g
# FfHHHdfg6jdhLhRMfZqPGuHQqp1Pz24H5amsYAUSpHWdfReCkF4rFTg1NkvgtT9A
# Cw++OTSw8hJGae0ea3nEKBQVo4KrXTfTKr1uGzZcNh0H1Gq9VHTaJzNQXMvK+gNA
# w+fwnXt31cy0Uh93BAhzMH04M7aWVwqjDY2zQg==
# SIG # End signature block
