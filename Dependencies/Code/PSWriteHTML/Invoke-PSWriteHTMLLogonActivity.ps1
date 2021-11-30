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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8PNJ4mIFjuBDon+ZNQXg4pnc
# RLigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUhQh4iSW/8vwSuLtaOX8nRCCLI9YwDQYJKoZI
# hvcNAQEBBQAEggEAI+SgaUH+DfwbMrZ8xIksSqGh8UV75F6mVCUwIuOoPFI4+P48
# v3171mljkU4iAPaZ/dI2CIv2vEb0CM8JRcfSgKPY31wWwvrC34g2T5rDVP5iM99+
# ereMOTbwuHtfvijyqL7JjDMPT146LaBe9IJ9RvGYlTsGmrOwaZZetorlJ1RBn2mF
# Fhi7GLkdDX9N5J29KU9rQEH3jK96SuLjzHRD0iZME5KQc3LOoamT0a2nmeUcb0D8
# s9Er2ZiI9mCJokyTPBfR4akEKohmB8oGO3nNAwUQDy0jCKu2N/5LeDDdKikTJd0a
# U33eVkVHhCX+7ehUqGYQ0HAT9KzCdznK2vTq/w==
# SIG # End signature block
