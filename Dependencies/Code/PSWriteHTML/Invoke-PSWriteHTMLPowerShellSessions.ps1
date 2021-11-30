function script:Invoke-PSWriteHTMLPowerShellSessions {
    param(
        $InputData = $null
    )

    $PowerShellSessionsPerEndpoint    = $InputData | Select-Object PSComputerName, ClientIP | Group-Object PSComputerName | Sort-Object Count, Name -Descending
    $PowerShellSessionsCount          = $InputData | Select-Object PSComputerName, Owner | Group-Object Owner | Sort-Object Count, Name -Descending
    $PowerShellSessionsLogonTime      = $InputData | Select-Object @{n='TimeCreatedHour';e={"$(($_.TimeCreated -split ' ')[0]) $((($_.TimeCreated -split ' ')[1] -split ':')[0])H"}} | Group-Object TimeCreatedHour | Sort-Object Name, Count
    $PowerShellSessionsClientIP       = $InputData | Select-Object PSComputerName, ClientIP -Unique | Group-Object ClientIP | Sort-Object Count, Name
    $PowerShellSessionsOwner          = $InputData | Select-Object PSComputerName, Owner -Unique | Group-Object Owner | Sort-Object Count, Name
    $PowerShellSessionsState          = $InputData | Select-Object PSComputerName, State -Unique | Group-Object State | Sort-Object Count, Name
    $PowerShellSessionsMemoryUsed     = $InputData | Select-Object PSComputerName, MemoryUsed -Unique | Group-Object MemoryUsed | Sort-Object Count, Name
    $PowerShellSessionsProfileLoaded  = $InputData | Select-Object PSComputerName, ProfileLoaded -Unique | Group-Object ProfileLoaded | Sort-Object Count, Name
    $PowerShellSessionsChildProcesses = $InputData | Select-Object PSComputerName, ChildProcesses -Unique | Where-Object {$_.ChildProcess -ne ''} | Group-Object ChildProcesses | Sort-Object Count, Name

    New-HTMLTab -Name 'PowerShell Sessions' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Pane Search' -IconSolid th {
            New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - PowerShell Sessions' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.LogonTime `
                        -Title "$($_.PSComputerName) by $($_.Owner) from $($_.ClientIP)" `
                        -Description "$($_.PSComputerName) || Account: $($_.Owner) || From: $($_.ClientIP) || State: $($_.State)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Per Endpoint" -Data $PowerShellSessionsPerEndpoint
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Count" -Data $PowerShellSessionsCount
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Logon Time" -Data $PowerShellSessionsLogonTime
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Client IP" -Data $PowerShellSessionsClientIP
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Owner" -Data $PowerShellSessionsOwner
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions State" -Data $PowerShellSessionsState
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Memory Used" -Data $PowerShellSessionsMemoryUsed
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Profile Loaded" -Data $PowerShellSessionsProfileLoaded
            script:Generate-TablePieBarCharts -Title "PowerShell Sessions Child Processes" -Data $PowerShellSessionsChildProcesses
        } 
    
        ###########
        New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
            $DataTableIDPowerShellSessions = Get-Random -Minimum 100000 -Maximum 2000000
            New-HTMLSection -HeaderText 'PowerShell Sessions' -CanCollapse {
                New-HTMLPanel -Width 40% {
                    New-HTMLTable -DataTable $InputData -DataTableID $DataTableIDPowerShellSessions -SearchRegularExpression  {
                        New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18 
                    } 
                }
                New-HTMLPanel {
                    
                    New-HTMLText `
                        -FontSize 12 `
                        -FontFamily 'Source Sans Pro' `
                        -Color Blue `
                        -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'

                    New-HTMLDiagram -Height '1000px' {
                        New-DiagramEvent -ID $DataTableIDPowerShellSessions -ColumnID 0
                        New-DiagramOptionsInteraction -Hover $true
                        New-DiagramOptionsManipulation 
                        New-DiagramOptionsPhysics -Enabled $true
                        New-DiagramOptionsLayout -RandomSeed 13

                        ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                        
                        New-DiagramOptionsNodes `
                            -BorderWidth 1 `
                            -ColorBackground LightSteelBlue `
                            -ColorHighlightBorder Orange `
                            -ColorHoverBackground Orange
                        New-DiagramOptionsLinks `
                            -FontSize 12 `
                            -ColorHighlight Orange `
                            -ColorHover Orange `
                            -Length 5000
                            # -ArrowsToEnabled $true `
                            # -Color BlueViolet `
                            # -ArrowsToType arrow `
                            # -ArrowsFromEnabled $false `
                        New-DiagramOptionsEdges `
                            -ColorHighlight Orange `
                            -ColorHover Orange

                        foreach ($object in $InputData) {
                            New-DiagramNode `
                                -Label  $object.PSComputerName `
                                -To     "[$($object.PSComputerName)]`nAccount: $($object.Owner)" `
                                -Image "$Dependencies\Images\Computer.jpg" `
                                -size 25 `
                                -FontColor  Blue `
                                -LinkColor  Blue `
                                -ArrowsFromEnabled
                            New-DiagramNode `
                                -Label  "[$($object.PSComputerName)]`nAccount: $($object.Owner)" `
                                -To     "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                -Image "$Dependencies\Images\User.jpg" `
                                -size 20 `
                                -FontColor  Blue `
                                -LinkColor  Blue `
                                -ArrowsFromEnabled
                            if ($object.ClientIP -in $script:PoShEasyWinIPAddress) {
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                    -Image "$Dependencies\Images\NIC.jpg" `
                                    -size 20 `
                                    -FontColor  Blue `
                                    -LinkColor  LightBlue `
                                    -ArrowsFromEnabled
                            }
                            else {
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                    -Image  $EasyWinIcon `
                                    -size   20 `
                                    -LinkColor DarkGray `
                                    -ArrowsToEnabled
                            }
                        }
                    }
                }
            }
        }
    }
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHEnCVgIxcaur3vFZWVBV5heP
# EJOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtmkJwxQoWPoWQt43UALJ5sh/B0wwDQYJKoZI
# hvcNAQEBBQAEggEAAjGL3d94woMz6MKivBu0ARkBGg4F6UdbR8TnRj+K9irLEJDK
# Sw/SimjkOdKVHV/UifepBq9seplaUBk7v72P4vHIWjRYfPTiW53oTYk3J/f+Mgwv
# DQpv1UKcrRa46tOt9bWMWws2z0Eo0VSJ6CUFOwQS0AWobznWCxPwkaWFrUnuZmCp
# rM8k50+Ym0/q8IcUYsDLvJUOVyIl9ScDOSLbhp2dpgp/uVHPrlJS1seUqAUTCzCr
# zd2qUpC2MWAcFiYLyWJ99Gwg0bAkh8PbUk2+sO/+Uki368iPTFPfdZCdUbDMX2G6
# w8m0Z/hpPRmyhr5GjbK48fIbq05hc7HAtj7Jgw==
# SIG # End signature block
