function script:Invoke-PSWriteHTMLProcess {
    param(
        $InputData = $null
    )

    $ProcessesTotalMemoryPerHost = $InputData | Select-Object pscomputername, workingset | Sort-Object PScomputerName | Group-Object pscomputername | Foreach-Object {[PSCustomObject]@{Name=$_.group.pscomputername[0];count=(($_.group.workingset | Measure-Object -Sum).Sum)}} | Sort-Object Count, Name -Descending
    
    $ProcessesCountPerHost = $InputData | Select-Object PSComputerName, ProcessID | Group-Object PSComputerName | Sort-Object Count, Name -Descending
    
    $ProcessesUnique = $InputData | Select-Object PSComputerName, ProcessName -Unique | Where-Object {$_.ProcessName -ne $null} | Group-Object ProcessName | Sort-Object Count, Name
    
    $ProcessesNetworkConnections = $InputData | Select-Object PSComputerName, NetworkConnections -unique | Where-Object {$_.NetworkConnections -ne $null} | Group-Object NetworkConnections | Sort-Object Count, Name
    
    $ProcessesServicesStarted = $InputData | Select-Object PSComputerName, ServiceInfo -unique | Where-Object {$_.ServiceInfo -ne $null} | Group-Object ServiceInfo | Sort-Object Count, Name
    
    $ProcessesCompanyNames = $InputData | Select-Object PSComputerName, Company -unique | Where-Object {$_.Company -ne $null} | Group-Object Company | Sort-Object Count, Name
    
    $ProcessesProductNames = $InputData | Select-Object PSComputerName, Product -unique | Where-Object {$_.Product -ne $null} | Group-Object Product | Sort-Object Count, Name
    
    $ProcessesSignerCompany = $InputData | Select-Object PSComputerName, SignerCompany -Unique | Where-Object {$_.SignerCompany -ne $null} | Group-Object SignerCompany | Where-Object {$_.Name -ne ''} | Sort-Object Count, Name
    
    $ProcessesSignerCertificates = $InputData | Select-Object PSComputerName, SignerCertificate -unique | Where-Object {$_.SignerCertificate -ne $null} | Group-Object SignerCertificate | Sort-Object Count, Name
    
    $ProcessesPaths = $InputData | Select-Object PSComputerName, Path | Where-Object {$_.Path -ne $null} | Group-Object Path | Sort-Object Count, Name
    
    $ProcessesMD5Hashes = $InputData | Select-Object PSComputerName, MD5Hash -unique | Where-Object {$_.MD5Hash -ne $null} | Group-Object MD5Hash | Sort-Object Count, Name
    
    $ProcessesModules = @()
    $InputData | Select-Object pscomputername, processname, modules | Where-Object modules -ne $null | Foreach-Object {$ProcessesModules += $_.modules}
    
    $ProcessesModules = $ProcessesModules | Group-Object | Sort-Object count


    New-HTMLTab -Name 'Processes' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table' -IconSolid th {
            New-HTMLSection -HeaderText 'Table' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Process Data Has Been Enriched With Related Network Connections, Authenticode Signatures, And File Hashes.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Search Pane' -IconSolid th {
            New-HTMLSection -HeaderText 'Search Pane' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Process Data Has Been Enriched With Related Network Connections, Authenticode Signatures, And File Hashes.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Process Data' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.StartTime `
                        -Title "$($_.PSComputerName) || $($_.ProcessName):$($_.ProcessID)" `
                        -Description "$($_.PSComputerName) || Process: $($_.ProcessName):$($_.ProcessID) || Start Time: $($_.StartTime) || Parent: $($_.ParentProcessName):$($_.ParentProcessID)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
            script:Generate-TablePieBarCharts -Title "Total Memory Per Host" -Data $ProcessesTotalMemoryPerHost
            script:Generate-TablePieBarCharts -Title "Count Per Host" -Data $ProcessesCountPerHost
            script:Generate-TablePieBarCharts -Title "Unique Processes" -Data $ProcessesUnique
            script:Generate-TablePieBarCharts -Title "Processes with Network Connections" -Data $ProcessesNetworkConnections
            script:Generate-TablePieBarCharts -Title "Services Started by Processes" -Data $ProcessesServicesStarted
            script:Generate-TablePieBarCharts -Title "Company Names" -Data $ProcessesCompanyNames
            script:Generate-TablePieBarCharts -Title "Product Names" -Data $ProcessesProductNames
            script:Generate-TablePieBarCharts -Title "Signer Company" -Data $ProcessesSignerCompany
            script:Generate-TablePieBarCharts -Title "Signer Certificates" -Data $ProcessesSignerCertificates
            script:Generate-TablePieBarCharts -Title "Paths" -Data $ProcessesPaths
            script:Generate-TablePieBarCharts -Title "MD5 Hashes" -Data $ProcessesMD5Hashes
            script:Generate-TablePieBarCharts -Title "Modules" -Data $ProcessesModules
        }        
        ###########
        New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
            $DataTableIDProcesses1 = Get-Random -Minimum 100000 -Maximum 2000000
            New-HTMLTab -TabName 'Processes Associated With Endpoints'{
                New-HTMLSection -HeaderText 'Processes With Associated Started Services And Network Connections' -CanCollapse {
                    New-HTMLPanel -Width 40% {
                        New-HTMLTable -DataTable $InputData -DataTableID $DataTableIDProcesses1 -SearchRegularExpression  {
                            New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                        } 
                    }
                    New-HTMLPanel {
                        New-HTMLText `
                            -FontSize 12 `
                            -FontFamily 'Source Sans Pro' `
                            -Color Blue `
                            -Text 'Click On The Process Icons To Automatically Locate Them Within The Table'

                        New-HTMLDiagram -Height '1000px' {
                            New-DiagramEvent -ID $DataTableIDProcesses1 -ColumnID 1
                            New-DiagramOptionsInteraction -Hover $true
                            New-DiagramOptionsManipulation
                            New-DiagramOptionsPhysics -Enabled $true
                            New-DiagramOptionsLayout `
                                -RandomSeed 13
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
                            $list = @()
                            foreach ($_ in $InputData) {
                                New-DiagramNode `
                                    -Label $_.ProcessName `
                                    -To $_.PSComputerName `
                                    -IconRegular file-alt `
                                    -Size 35
                                if ($_.ServiceInfo -ne $null) {
                                    $Service = ($_.ServiceInfo -split ' ')[0]
                                    $ServiceInfo = (($_.ServiceInfo -split ' ')[1..10] -join ' ').replace('[','').replace(']','')
                                    New-DiagramNode `
                                        -Label "[$($_.PSComputername)]`nService Started: $($Service)`n$($ServiceInfo)" `
                                        -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                        -Size 10 `
                                        -Shape triangle `
                                        -ColorBackground Cyan `
                                        -ColorBorder LightBlue
                                }
                                if ("[$($_.PSComputername)]`n$($_.ProcessName)" -notin $list) {
                                    New-DiagramNode `
                                        -Label "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                        -To $_.ProcessName `
                                        -size 25 `
                                        -Image "$Dependencies\Images\Computer.jpg" `
                                        -ColorBackground AliceBlue
                                    $list += "[$($_.PSComputername)]`n$($_.ProcessName)"
                                }
                                if ($_.NetworkConnections -ne $null) {
                                    if ($_.NetworkConnections -match 'Establish') {
                                        New-DiagramNode `
                                            -Label "[$($_.PSComputername)]`nNetwork Connection`nEstablished`nPID: $($_.ProcessID)" `
                                            -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                            -Size 10 `
                                            -Shape dot `
                                            -ColorBackground LightCoral `
                                            -ColorBorder Red
                                    }
                                    if ($_.NetworkConnections -match 'Listen') {
                                        New-DiagramNode `
                                            -Label "[$($_.PSComputername)]`nNetwork Connection`nListening`nPID: $($_.ProcessID)" `
                                            -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                            -Size 10 `
                                            -Shape dot `
                                            -ColorBackground Yellow `
                                            -ColorBorder Orange
                                    }
                                    if ($_.NetworkConnections -match 'Bound') {
                                        New-DiagramNode `
                                            -Label "[$($_.PSComputername)]`nNetwork Connection`nBound`nPID: $($_.ProcessID)" `
                                            -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                            -Size 10 `
                                            -Shape dot `
                                            -ColorBackground LightSteelBlue `
                                            -ColorBorder Blue
                                    }
                                    if ($_.NetworkConnections -match 'CloseWait') {
                                        New-DiagramNode `
                                            -Label "[$($_.PSComputername)]`nNetwork Connection`nCloseWait`nPID: $($_.ProcessID)" `
                                            -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                            -Size 10 `
                                            -Shape dot `
                                            -ColorBackground LightGreen `
                                            -ColorBorder Green
                                    }
                                    if ($_.NetworkConnections -match 'Timeout') {
                                        New-DiagramNode `
                                            -Label "[$($_.PSComputername)]`nNetwork Connection`nTimeout`nPID: $($_.ProcessID)" `
                                            -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                            -Size 10 `
                                            -Shape dot `
                                            -ColorBackground Violet `
                                            -ColorBorder DarkViolet
                                    }
                                }
                            }
                        }
                    }
                }
            }

            $DataTableIDProcesses2 = Get-Random -Minimum 100000 -Maximum 2000000
            New-HTMLTab -TabName 'Process Tree Represenation' {
                New-HTMLSection -HeaderText 'Graph' -CanCollapse {
                    New-HTMLPanel -Width 40% {
                        New-HTMLTable -DataTable $InputData -DataTableID $DataTableIDProcesses2 -SearchRegularExpression  {
                            New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                        } 
                    }
                    New-HTMLPanel {
                        New-HTMLText `
                            -FontSize 12 `
                            -FontFamily 'Source Sans Pro' `
                            -Color Blue `
                            -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'

                        New-HTMLDiagram -Height '1000px' {
                            New-DiagramEvent -ID $DataTableIDProcesses2 -ColumnID 2
                            New-DiagramOptionsInteraction
                            New-DiagramOptionsManipulation
                            New-DiagramOptionsPhysics
                            New-DiagramOptionsLayout `
                                -RandomSeed 13
                            New-DiagramOptionsNodes `
                                -BorderWidth 1 `
                                -ColorBackground LightSteelBlue `
                                -ColorHighlightBorder Orange `
                                -ColorHoverBackground Orange
                            New-DiagramOptionsLinks `
                                -ColorHighlight Orange `
                                -ColorHover Orange
                            New-DiagramOptionsEdges `
                                -ColorHighlight Orange `
                                -ColorHover Orange

                            foreach ($object in $InputData) {
                                if ($object.level -eq 0) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -Image  "$Dependencies\Images\Computer.jpg" `
                                        -Size   35 `
                                        -FontSize   20 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor  Blue `
                                        -ArrowsToEnabled
                                    if ($object.ServiceInfo) {
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nService: $(($object.ServiceInfo -split ' ')[0])`n$((($object.ServiceInfo -split ' ')[1..$object.ServiceInfo.length] -join ' ') -replace '[','' -replace ']','')" `
                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                            -Shape  triangle `
                                            -size   10 `
                                            -ColorBackground  Cyan `
                                            -LinkColor        Cyan `
                                            -ArrowsFromEnabled
                                    }
                                    if ($object.NetworkConnections) {
                                        foreach ($connection in $($object.NetworkConnections -split "`n")){
                                            $connList = $connection.split('||').replace("[]","").trim() | Where-Object {$_ -ne ''}
                                            foreach ($conn in $connList) {
                                                if ($conn -match 'Establish') {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Red `
                                                        -ColorBackground  LightCoral `
                                                        -LinkColor        LightCoral `
                                                        -ArrowsFromEnabled
                                                }
                                                elseif ($conn -match 'Listen') {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled
                                                }
                                                else {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      DarkGray `
                                                        -ColorBackground  LightGray `
                                                        -LinkColor        LightGray `
                                                        -ArrowsFromEnabled
                                                }
                                            }
                                        }
                                    }
                                    <# THIS VERSION OF THE CODE ENDED UP SHOWING THE RELATIONSHIPS BETWEEN THE ENDPOINTS VIA NETWORK CONNECTIONS                
                                    if ($object.NetworkConnections) {
                                        foreach ($conn in $($object.NetworkConnections -split "`n")){
                                            if ($conn -match 'Establish') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Red `
                                                    -ColorBackground  LightCoral `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ($conn -match 'Listen') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Orange `
                                                    -ColorBackground  Yellow `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            else {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      DarkViolet `
                                                    -ColorBackground  Violet `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                        }
                                    }#>
                                }
                                elseif ($object.level -gt 0) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -To     "[$($object.PSComputerName)]`n$($object.ParentProcessName)`nPID:$($object.ParentProcessID)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor  Blue `
                                        -ArrowsFromEnabled                        
                                    if ($object.ServiceInfo) {
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nService: $(($object.ServiceInfo -split ' ')[0])`n$((($object.ServiceInfo -split ' ')[1..$object.ServiceInfo.length] -join ' ') -replace '[','' -replace ']','')" `
                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                            -Shape  triangle `
                                            -size   10 `
                                            -ColorBorder AliceBlue `
                                            -ColorBackground  Cyan `
                                            -LinkColor        Cyan `
                                            -ArrowsFromEnabled
                                    }

                                    if ($object.NetworkConnections) {
                                        foreach ($connection in $($object.NetworkConnections -split "`n")){
                                            $connList = $connection.split('||').replace("[]","").trim() | Where-Object {$_ -ne ''}
                                            foreach ($conn in $connList) {
                                                if ($conn -match 'Establish') {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Red `
                                                        -ColorBackground  LightCoral `
                                                        -LinkColor        LightCoral `
                                                        -ArrowsFromEnabled
                                                }
                                                elseif ($conn -match 'Listen') {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled
                                                }
                                                else {
                                                    New-DiagramNode `
                                                        -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      DarkGray `
                                                        -ColorBackground  LightGray `
                                                        -LinkColor        LightGray `
                                                        -ArrowsFromEnabled
                                                }
                                            }
                                        }
                                    }
                                    <# THIS VERSION OF THE CODE ENDED UP SHOWING THE RELATIONSHIPS BETWEEN THE ENDPOINTS VIA NETWORK CONNECTIONS       
                                    if ($object.NetworkConnections) {
                                        foreach ($conn in $($object.NetworkConnections -split "`n")){
                                            if ($conn -match 'Establish') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Red `
                                                    -ColorBackground  LightCoral `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ($conn -match 'Listen') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Orange `
                                                    -ColorBackground  Yellow `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            else {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      DarkViolet `
                                                    -ColorBackground  Violet `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                        }
                                    }#>
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}