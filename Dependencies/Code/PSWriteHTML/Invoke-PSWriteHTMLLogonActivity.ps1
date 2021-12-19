function script:Invoke-PSWriteHTMLLogonActivity {
    param(
        $InputData = $null
    )

    $LogonActivityTimeStampDaySortDay   = $InputData | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Name, Count
    $LogonActivityTimeStampDaySortCount = $InputData | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Count, Name
    $LogonActivityLogonType             = $InputData | Select-Object LogonType | Group-Object LogonType | Sort-Object Count, Name
    $LogonActivityWorkstationName       = $InputData | Select-Object WorkstationName | Where-Object {$_.WorkStationName -ne '' -and $_.WorkStationName -ne '-'} | Group-Object WorkstationName | Sort-Object Count, Name
    $LogonActivitySourceNetworkAddress  = $InputData | Select-Object SourceNetworkAddress | Where-Object {$_.SourceNetworkAddress -ne '' -and $_.SourceNetworkAddress -ne '-'} | Group-Object SourceNetworkAddress | Sort-Object Count, Name
    $LogonActivityTimeStampLogonLocalSystem   = $InputData | Where-Object LogonType -eq LocalSystem | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonInteractive   = $InputData | Where-Object LogonType -eq Interactive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNetwork       = $InputData | Where-Object LogonType -eq Network | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
        #very noisy
    $LogonActivityTimeStampLogonBatch         = $InputData | Where-Object LogonType -eq Batch | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonService       = $InputData | Where-Object LogonType -eq Service | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonUnlock        = $InputData | Where-Object LogonType -eq Unlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNetworkClearText    = $InputData | Where-Object LogonType -eq NetworkClearText | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonNewCredentials      = $InputData | Where-Object LogonType -eq NewCredentials | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonRemoteInteractive   = $InputData | Where-Object LogonType -eq RemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedInteractive   = $InputData | Where-Object LogonType -eq CachedInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedRemoteInteractive   = $InputData | Where-Object LogonType -eq CachedRemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    $LogonActivityTimeStampLogonCachedUnlock              = $InputData | Where-Object LogonType -eq CachedUnlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count

    New-HTMLTab -Name 'Logon Activity' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Pane Search' -IconSolid th {
            New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Logon Activity' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.TimeStamp `
                        -Title "$($_.PSComputerName) [$($_.UserAccount)] $($_.LogonType)" `
                        -Description "$($_.PSComputerName) || Account: $($_.UserAccount) || $($_.LogonType) || $($_.WorkStationName) || $($_.SourceNetworkAddress)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
            script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Day)" -Data $LogonActivityTimeStampDaySortDay
            script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Count)" -Data $LogonActivityTimeStampDaySortCount
            script:Generate-TablePieBarCharts -Title "Workstation Name" -Data $LogonActivityWorkstationName
            script:Generate-TablePieBarCharts -Title "Source Network Address" -Data $LogonActivitySourceNetworkAddress
            script:Generate-TablePieBarCharts -Title "Logon Type" -Data $LogonActivityLogonType
            script:Generate-TablePieBarCharts -Title "Logon Local System" -Data $LogonActivityTimeStampLogonLocalSystem
            script:Generate-TablePieBarCharts -Title "Logon Interactive" -Data $LogonActivityTimeStampLogonInteractive
            script:Generate-TablePieBarCharts -Title "Logon Network" -Data $LogonActivityTimeStampLogonNetwork
            script:Generate-TablePieBarCharts -Title "Logon Batch" -Data $LogonActivityTimeStampLogonBatch
            script:Generate-TablePieBarCharts -Title "Logon Service" -Data $LogonActivityTimeStampLogonService
            script:Generate-TablePieBarCharts -Title "Logon Unlock" -Data $LogonActivityTimeStampLogonUnlock
            script:Generate-TablePieBarCharts -Title "Logon Network Clear Text" -Data $LogonActivityTimeStampLogonNetworkClearText
            script:Generate-TablePieBarCharts -Title "Logon New Credentials" -Data $LogonActivityTimeStampLogonNewCredentials
            script:Generate-TablePieBarCharts -Title "Logon Remote Interactive" -Data $LogonActivityTimeStampLogonRemoteInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Interactive" -Data $LogonActivityTimeStampLogonCachedInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Remote Interactive" -Data $LogonActivityTimeStampLogonCachedRemoteInteractive
            script:Generate-TablePieBarCharts -Title "Logon Cached Unlock" -Data $LogonActivityTimeStampLogonCachedUnlock
        }
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPYchZpSkX+Thnu7trNo/gD76
# zoqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8DWpVAGe/PqtTiWNRM9XonMuIVYwDQYJKoZI
# hvcNAQEBBQAEggEAP3CagB/BUpgF+lxizSBfnRHUQL5ulR6+RPGzmQuISt4WC2Yw
# VQgnwqSURwHty7AqFbZr9oZrPgKww/0KUS0+canYcJ/7z5JIWT42FP65PBBn0fpk
# bIuN9qFc1PD5iguyOFX0nSWO8tht1Ad0gPo4AvSdcWAM6rTkPnW81xVjqo+ZYjzU
# j7JOov3afITs9W9duc28L3qcBz/+hxNFOjc8Xm5OhaJLtCKrHlJCeWOH/HEPfhuT
# G4P3Bj2g8yWctx9j2USwa9Sff0muPJKcIVJjiK4PiLOgjBdYmCJKNhLUy71XrM8D
# odv6qviynpKi7DrPIqcAOEo0zOGQT/29GIyxaQ==
# SIG # End signature block
