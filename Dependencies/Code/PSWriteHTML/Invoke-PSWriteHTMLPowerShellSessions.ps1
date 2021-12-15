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
                                    -Image  $script:EasyWinIcon `
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
# EJOgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtmkJwxQoWPoWQt43UALJ5sh/B0wwDQYJKoZI
# hvcNAQEBBQAEggEALMj5Ir16Pb8VuL8+FWT16IzPyE7RqI4zyArUJ9THNAKZTISz
# HPzB8A/m8XhxO3ShWJ3okSS09OXyhKuwmjuf1GBU2WY2DgvCYGifS/Jw3YDnhnr4
# K9PtQiwZ3zdpMdAdc362WF3nK9+7NLCxJalbKIbEq0QTmfPTIKsMKIhdwNLVDjo3
# 6+HKBsG9+hdIet5A53NZwvbsfUq6UjdS+9mU6uXeQVeb9luFWgIN7BJ0KwRhO2ox
# 0v1EICR3jjuiUTHc7ha789fWZuPKlxniLWrh2QL9N0MXPAzxYjunXu6I2fWx3sxT
# 3IpX8cyPoail4ncYbfJpVVOyvxa6BsahIUzZQA==
# SIG # End signature block
