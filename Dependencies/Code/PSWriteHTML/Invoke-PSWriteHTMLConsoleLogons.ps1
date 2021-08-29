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
