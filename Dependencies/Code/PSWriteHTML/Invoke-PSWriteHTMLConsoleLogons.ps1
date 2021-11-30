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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKRfa2J52urKanT/xKwmAZUuc
# n7KgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU4ozPUghkIJ5DuRrV25q8emO+8bswDQYJKoZI
# hvcNAQEBBQAEggEAq2FHrJLrubhdXJy5DRfBl+1/NCREa/6Q7vAFNEgfkLX6fAfS
# PQqZsfYaxaWSD0xd8PeZDyWIorBU6RSUhnWBXgwifWg0f2TgrQ/LDuUrimHUR6gm
# 5b7YV4XBlv0giK9h4h6ILn36tfBL5FAaS2CazGA4f6oYg+vhcmNi4e3kVcCoPBqW
# 1xBdg14V8X+I0g4rHYa6c475LlZqI/cVYo/nsOiyWan8l//8BDgAfWOMHTWx7H4C
# Gn3Ddv67peyCoKYF+juJXTMNVfLDSg1zxk3FLAur+UxzC/X6URLBOmZWDdV0mqyi
# u/UGyQNY4TIz1oTLKS00Lyv2ksEhE4638pZbvg==
# SIG # End signature block
