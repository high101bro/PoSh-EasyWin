function script:Invoke-PSWriteHTMLConsoleLogons {
    param(
        $InputData = $null
    )

    $ConsoleLogonsPerEndpoint   = $InputData | Select-Object PSComputerName, UserName | Group-Object PSComputerName | Sort-Object Count, Name -Descending
    $ConsoleLogonsCount         = $InputData | Select-Object PSComputerName, UserName | Group-Object UserName | Sort-Object Count, Name -Descending
    $ConsoleLogonsLogonTimeHour = $InputData | Select-Object @{n='LogonTimeHour';e={(($_.LogonTime -split ' ')[0] -split ':')[0]}} | Group-Object LogonTimeHour | Sort-Object Name, Count
    $ConsoleLogonsState         = $InputData | Select-Object PSComputerName, State -Unique | Group-Object State | Sort-Object Count, Name

    New-HTMLTab -Name 'Console Logons' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Pane Search' -IconSolid th {
            New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Console Logons' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.LogonTime `
                        -Title "$($_.PSComputerName) Logon: $($_.UserName)" `
                        -Description "$($_.PSComputerName) || Logon: $($_.UserName) || State: $($_.State) || Idle Time: $($_.IdleTime)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########       
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
            script:Generate-TablePieBarCharts -Title "Console Logons Per Endpoint" -Data $ConsoleLogonsPerEndpoint
            script:Generate-TablePieBarCharts -Title "Console Logon Count" -Data $ConsoleLogonsCount
            script:Generate-TablePieBarCharts -Title "Logon Times (Hour)" -Data $ConsoleLogonsLogonTimeHour
            script:Generate-TablePieBarCharts -Title "Console Logon State" -Data $ConsoleLogonsState
        }
        ###########
        New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
            $DataTableIDConsoleLogons = Get-Random -Minimum 100000 -Maximum 2000000
            New-HTMLSection -HeaderText 'Console Logons' -CanCollapse {
                New-HTMLPanel -Width 40% {
                    New-HTMLTable -DataTable $InputData -DataTableID $DataTableIDConsoleLogons -SearchRegularExpression  {
                        New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18 
                    } 
                }
                New-HTMLPanel {
                    
                    New-HTMLText `
                        -FontSize 12 `
                        -FontFamily 'Source Sans Pro' `
                        -Color Blue `
                        -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'

                    New-HTMLDiagram -Height '1000px' {
                        New-DiagramEvent -ID $DataTableIDConsoleLogons -ColumnID 0
                        New-DiagramOptionsInteraction -Hover $true
                        New-DiagramOptionsManipulation 
                        New-DiagramOptionsPhysics -Enabled $true
                        New-DiagramOptionsLayout `
                            -RandomSeed 13

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
                                -To     "[$($object.PSComputerName)]`nUser Name: $($object.UserName)" `
                                -Image "$Dependencies\Images\Computer.jpg" `
                                -size 25 `
                                -FontColor  Blue `
                                -LinkColor  Blue
                            New-DiagramNode `
                                -Label "[$($object.PSComputerName)]`nUser Name: $($object.UserName)" `
                                -To    "[$($object.PSComputerName)]`nState: $($object.State)`nLogon Time: $($object.LogonTime)" `
                                -Image "$Dependencies\Images\User.jpg" `
                                -size 15 `
                                -FontColor  Blue `
                                -LinkColor  Blue
                            New-DiagramNode `
                                -Label  "[$($object.PSComputerName)]`nState: $($object.State)`nLogon Time: $($object.LogonTime)" `
                                -Image "$Dependencies\Images\Clock.jpg" `
                                -size 10 `
                                -FontColor  Blue `
                                -LinkColor  LightBlue
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGjh9hS4rorKUf9w+IiRvS03e
# 5SGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5sa04K23xmQ/GunzShlKybSimP8wDQYJKoZI
# hvcNAQEBBQAEggEAggDzSti8uA7l5kiaM3DOjE4wItzNxVH+0tjEv+uVxiQebQLo
# xcoNxjAtwDMoiKRuwUCU+qO5qf7Srr5AU9SNMU1ABkQnB1ZXkfu48+8j2cjiQcSq
# 3REuvkj2Y6i+8UthtbohJ+6fPFiz+fVsg9oD9pZ9GrPY4OH+lukDxmy+pJpJinyt
# 4oMAEK6OSpLTSnCCWE+T/sPu/QD7cdct4Ptq/nlvF/S0soD/N49FaeGxC/HcXbjL
# Ix8BtcxbtSftwVN41nYtVnbyF77hSa7Uu6VUSr5qyY2beLN/gOuBmj3r63yVF09O
# rg+TW459C2R5bqlgdyjg4xOmjMx7f1FcvjJrRQ==
# SIG # End signature block
