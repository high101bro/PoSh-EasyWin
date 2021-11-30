
$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Collections"
    UseVisualStyleBackColor = $True
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageIndex = 0
}
$MainLeftTabControl.Controls.Add($Section1CollectionsTab)

$MainLeftCollectionsTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Query
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))
# Index 1 = Accounts
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png"))
# Index 2 = Event-Viewer
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Event-Viewer.png"))
# Index 3 = Registry 
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Registry.png"))
# Index 4 = File-Search
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\File-Search.png"))
# Index 5 = Network
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Network.png"))
# Index 6 = Packet Capture
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\pcap.png"))
# Index 7 = Processes
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Processes.png"))
# Index 8 = Event Logs / Chainsaw
$MainLeftCollectionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\ChainSaw.png"))


$MainLeftCollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * (557 + 5)}
    ShowToolTips  = $True
    SelectedIndex = 0
    ImageList     = $MainLeftCollectionsTabControlImageList
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline = $true
}
$Section1CollectionsTab.Controls.Add($MainLeftCollectionsTabControl)


# This tab contains all the individual commands within the command treeview, such as the
# PowerShell, WMI, and Native Commands using the WinRM, RPC/DCOM, and SMB protocols
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Queries.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Queries.ps1"


# This tab contains fields specific to assist with querying account information such as
# account logon activeity, currently logged on users, and PowerShell logons
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Accounts.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Accounts.ps1"


# This tab contains fields specific to assist with querying event logs
# It also has the settings to specify and limit collections to narrow queries,  
# reduce unnecessary data returned, and lower collection time 
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Event Logs CSV.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Event Logs CSV.ps1"

# This tab contains fields specific to pulling back event logs for viewing with Windows Event Viewer and/or processing with Chainsaw.exe
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Event Logs EVTX.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Event Logs EVTX.ps1"


# This tab contains fields specific to assist with querying the registry
# for names, keys, and values
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Registry.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Registry.ps1"


# This tab contains fields specific to assist with querying for file names and hashes
# Also supports searching for Alternate Data Streams (ADS) and their extraction/retrieval
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections File Search.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections File Search.ps1"


# This tab contains fields specific to assist with querying network status
# Such as local/remote IPs and ports, processes that start connnections, and dns cache
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Network.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Network.ps1"


# This tab contains fields specific to packet capturing
# Feilds for the legacy netsh trace and the upcoming native Win10 Packet Capture
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Packet Capture.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Packet Capture.ps1"


# This tab contains fields specific to search for specific process related information
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections Processes.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections Processes.ps1"

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3PlJXt91Q1APpo7zBPIQAlxI
# 4tSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUOZg8wB0fIKieTrT/U495w+SQ7FAwDQYJKoZI
# hvcNAQEBBQAEggEAUJXtToIHWX2rNiHlKSIGyLT2dxac8+qw0rRbuoIKRzSSXLzT
# telx92zfJCKUYLTD2oc8f47c913qlixi/6C9Hl4y30RBAn5MBo9m0f0nj/RW/0LH
# FKerRRGWorQW+ATrtrTR1UvVoK3TiAzcFpzpgINHVtMwAOz8S0IP9yvKW/gETIL9
# pmdOR9Huws01/th9Ki7vlmnyg3zJskzDV0WpzwcY+gF/muWPOXnt+a/ZJA9XKAbW
# lMkDPb9fue/9H4fQdaY5so/VgJbCfTJ6pKkO627mBqE1emZYEvk/Yc5ypHMufGgc
# cf64Feutun6P9yfEmA2GsR5yfPJ39KeYOjIjpg==
# SIG # End signature block
