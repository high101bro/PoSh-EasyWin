function script:Invoke-PSWriteHTMLProcessAndNetwork {
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


    New-HTMLTab -Name 'Processes And Network Connections' -IconBrands acquisitions-incorporated {
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
                                        -size 40 `
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
                                                $ConnComputer = $object.PSComputerName
                                                $ConnState    = ($conn -replace '\[','' -replace '\]','' -replace ';',':' -split ' ')[0]
                                                $ConnTime     = ($conn -split '\[')[2].trim(']')
                                                $ConnSource   = ($conn -split ' ')[1] -replace ';',':'
                                                $ConnDest     = ($conn -split ' ')[3] -replace ';',':'

                                                if ($conn -match 'Listen') {
                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`nPID:$($object.ProcessID)`n$ConnState - $ConnTime" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled

                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`n$ConnSource <--> $ConnSource" `
                                                        -To     "[$ConnComputer]`nPID:$($object.ProcessID)`n$ConnState - $ConnTime" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled
                                                }
                                                else {
                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                                        -size   20 `
                                                        -ColorBorder      Red `
                                                        -ColorBackground  LightCoral `
                                                        -LinkColor        LightCoral `
                                                        -ArrowsFromEnabled

                                                    if ($ConnSource -match '0.0.0.0' -or $ConnSource -match '127.0.0.'  -or $ConnSource -match '::') {
                                                        New-DiagramNode `
                                                            -Label  "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                            -To     "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        LightCoral `
                                                            -ArrowsFromEnabled

                                                        if ($ConnDest -match '0.0.0.0' -or $ConnDest -match '127.0.0.'  -or $ConnDest -match '::') {
                                                            New-DiagramNode `
                                                                -Label  "[$ConnComputer]`nlocalhost`n$ConnDest" `
                                                                -To     "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "$ConnDest" `
                                                                -To     "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                    else {
                                                        New-DiagramNode `
                                                            -Label  "$ConnSource" `
                                                            -To     "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        LightCoral `
                                                            -ArrowsFromEnabled

                                                        if ($ConnDest -match '0.0.0.0' -or $ConnDest -match '127.0.0.'  -or $ConnDest -match '::') {
                                                            New-DiagramNode `
                                                                -Label  "[$ConnComputer]`nlocalhost`n$ConnDest" `
                                                                -To     "$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "$ConnDest" `
                                                                -To     "$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
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
                                                $ConnComputer = $object.PSComputerName
                                                $ConnState    = ($conn -replace '\[','' -replace '\]','' -replace ';',':' -split ' ')[0]
                                                $ConnTime     = ($conn -split '\[')[2].trim(']')
                                                $ConnSource   = ($conn -split ' ')[1] -replace ';',':'
                                                $ConnDest     = ($conn -split ' ')[3] -replace ';',':'

                                                if ($conn -match 'Listen') {
                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`nPID:$($object.ProcessID)`n$ConnState - $ConnTime" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled

                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`n$ConnSource <--> $ConnSource" `
                                                        -To     "[$ConnComputer]`nPID:$($object.ProcessID)`n$ConnState - $ConnTime" `
                                                        -Shape  dot `
                                                        -size   10 `
                                                        -ColorBorder      Orange `
                                                        -ColorBackground  Yellow `
                                                        -LinkColor        Gold `
                                                        -ArrowsFromEnabled
                                                }
                                                else {
                                                    New-DiagramNode `
                                                        -Label  "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                                        -size   20 `
                                                        -ColorBorder      Red `
                                                        -ColorBackground  LightCoral `
                                                        -LinkColor        LightCoral `
                                                        -ArrowsFromEnabled
                                                    if ($ConnSource -match '0.0.0.0' -or $ConnSource -match '127.0.0.'  -or $ConnSource -match '::') {
                                                        New-DiagramNode `
                                                            -Label  "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                            -To     "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        LightCoral `
                                                            -ArrowsFromEnabled

                                                        if ($ConnDest -match '0.0.0.0' -or $ConnDest -match '127.0.0.'  -or $ConnDest -match '::') {
                                                            New-DiagramNode `
                                                                -Label  "[$ConnComputer]`nlocalhost`n$ConnDest" `
                                                                -To     "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "$ConnDest" `
                                                                -To     "[$ConnComputer]`nlocalhost`n$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                    else {
                                                        New-DiagramNode `
                                                            -Label  "$ConnSource" `
                                                            -To     "[$ConnComputer]`n$ConnState - $ConnTime" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        LightCoral `
                                                            -ArrowsFromEnabled

                                                        if ($ConnDest -match '0.0.0.0' -or $ConnDest -match '127.0.0.'  -or $ConnDest -match '::') {
                                                            New-DiagramNode `
                                                                -Label  "[$ConnComputer]`nlocalhost`n$ConnDest" `
                                                                -To     "$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "$ConnDest" `
                                                                -To     "$ConnSource" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }






    # param(
    #     $InputData = $null,
    #     [switch]$MenuPrompt
    # )
    # if ( $MenuPrompt ) { script:Launch-NetworkConnectionGUI }

    # $InputData = $InputData | Select-Object -Property RemoteIPPort, LocalIPPort, PSComputerName, State, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, ProcessName, ProcessId, ParentProcessId, CreationTime, Duration, CommandLine, ExecutablePath, MD5Hash, OwningProcess, CollectionMethod
    # $NetworkConnectionsLocalPortsListening    = $InputData | Select-Object LocalPort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Listen'} | Group-Object LocalPort | Sort-Object Count, Name
    # $NetworkConnectionsRemotePortsEstablished = $InputData | Select-Object RemotePort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Establish'} | Group-Object RemotePort | Sort-Object Count, Name
    # $NetworkConnectionsRemoteLocalIPsUnique   = $InputData | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
    # $NetworkConnectionsRemoteLocalIPsSum      = $InputData | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
    # $NetworkConnectionsRemotePublicIPsUnique  = $InputData | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name
    # $NetworkConnectionsRemotePublicIPsSum     = $InputData | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name

    # New-HTMLTab -Name 'TCP Connections' -IconBrands acquisitions-incorporated {
    #     ###########
    #     New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
    #         New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
    #             New-HTMLTable -DataTable $InputData {
    #                 New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
    #             } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
    #         }
    #     }
    #     ###########
    #     New-HTMLTab -Name 'Pane Search' -IconSolid th {
    #         New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
    #             New-HTMLTable -DataTable $InputData {
    #                 New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
    #             } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
    #         }
    #     }
    #     ###########
    #     New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
    #         New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
    #             New-HTMLTable -DataTable $InputData {
    #                 New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Network Connections Data' -FontSize 18
    #             } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
    #             New-HTMLCalendar {
    #                 foreach ($_ in $InputData) {
    #                     New-CalendarEvent -StartDate $_.CreationTime `
    #                     -Title "$($_.PSComputerName) [$($_.State)] $($_.RemoteAddress):$($_.RemotePort)" `
    #                     -Description "$($_.PSComputerName) || State: $($_.State) || $($_.LocalAddress):$($_.LocalPort) <--> $($_.RemoteAddress):$($_.RemotePort) || Start Time: $($_.StartTime) || Process: $($_.ProcessName):$($_.ProcessID)"
    #                 }
    #             } -InitialView dayGridMonth #timeGridDay
    #         }
    #     }
    #     ###########
    #     New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
    #         script:Generate-TablePieBarCharts -Title "Local Ports Listening" -Data $NetworkConnectionsLocalPortsListening
    #         script:Generate-TablePieBarCharts -Title "Remote Ports Established" -Data $NetworkConnectionsRemotePortsEstablished
    #         script:Generate-TablePieBarCharts -Title "Remote Local IPs Unique" -Data $NetworkConnectionsRemoteLocalIPsUnique
    #         script:Generate-TablePieBarCharts -Title "Remote Local IPs Sum" -Data $NetworkConnectionsRemoteLocalIPsSum
    #         script:Generate-TablePieBarCharts -Title "Remote Public IPs Unique" -Data $NetworkConnectionsRemotePublicIPsUnique
    #         script:Generate-TablePieBarCharts -Title "Remote Public IPs Sum" -Data $NetworkConnectionsRemotePublicIPsSum
    #     }
    #     ###########
    #     New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
    #         $DataTableID = Get-Random -Minimum 100000 -Maximum 2000000
    #         $InputData = $InputData | Select-Object RemoteIPPort, * -ErrorAction SilentlyContinue
    #         New-HTMLSection -HeaderText 'Network Connections' -CanCollapse {
    #             New-HTMLPanel -Width 40% {
    #                 New-HTMLTable -DataTable $InputData -DataTableID $DataTableID -SearchRegularExpression  {
    #                     New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18
    #                 }
    #             }
    #             New-HTMLPanel {

    #                 New-HTMLText `
    #                     -FontSize 12 `
    #                     -FontFamily 'Source Sans Pro' `
    #                     -Color Blue `
    #                     -Text 'Click On The Network Connection Icons To Automatically Locate Them Within The Table'

    #                 New-HTMLDiagram -Height '1000px' {
    #                     New-DiagramEvent -ID $DataTableID -ColumnID 1
    #                     New-DiagramEvent -ID $DataTableID -ColumnID 2
    #                     New-DiagramEvent -ID $DataTableID -ColumnID 3
    #                     New-DiagramOptionsInteraction -Hover $true
    #                     New-DiagramOptionsManipulation
    #                     New-DiagramOptionsPhysics -Enabled $true
    #                     New-DiagramOptionsLayout `
    #                         -RandomSeed 13

    #                     ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight

    #                     New-DiagramOptionsNodes `
    #                         -BorderWidth 1 `
    #                         -ColorBackground LightSteelBlue `
    #                         -ColorHighlightBorder Orange `
    #                         -ColorHoverBackground Orange
    #                     New-DiagramOptionsLinks `
    #                         -FontSize 12 `
    #                         -ColorHighlight Orange `
    #                         -ColorHover Orange `
    #                         -Length 5000
    #                         # -ArrowsToEnabled $true `
    #                         # -Color BlueViolet `
    #                         # -ArrowsToType arrow `
    #                         # -ArrowsFromEnabled $false `
    #                 New-DiagramOptionsEdges `
    #                         -ColorHighlight Orange `
    #                         -ColorHover Orange

    #                     $script:LocalAddressList = $InputData | Select-Object -ExpandProperty LocalAddress | Sort-Object -Unique
    #                     $script:NameNodeList = $InputData | Select-Object -ExpandProperty PSComputerName | Sort-Object -Unique


    #                     #$script:AllComputersList = @()
    #                     #[System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
    #                     #foreach ($root in $AllTreeViewNodes) {
    #                     #    foreach ($Category in $root.Nodes) {
    #                     #        foreach ($Entry in $Category.nodes) {
    #                     #            $script:AllComputersList += $Entry.text
    #                     #        }
    #                     #    }
    #                     #}
    #                     if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {

    #                             #####################################
    #                             # Hashtable of DNS Results // START #
    #                             #####################################
    #                             $StatusListBox.Items.Clear()
    #                             $StatusListBox.Items.Add("Conducting DNS Resolution - In Progress")
    #                             $PoShEasyWin.Refresh()

    #                             $script:DNSResolvedList = @{}
    #                             $RemoteAddresses = ($InputData).RemoteAddress | `
    #                                 Sort-Object -Unique `
    #                                 | Where-Object {$_ -ne '::' -and $_ -ne '::1' -and $_ -ne '0.0.0.0' -and $_ -ne '127.0.0.1'}
    #                             Get-Job  -Name "nslookup:*" | Remove-Job -Force
    #                             foreach ( $RemoteIP in $RemoteAddresses ) {
    #                                 if ($script:DNSResolvedList.ContainsKey($RemoteIP)) {
    #                                     $null
    #                                 }
    #                                 else {
    #                                     Start-Job -Name "nslookup:$RemoteIP" `
    #                                     -ScriptBlock {
    #                                         param($RemoteIP)
    #                                         return @{$RemoteIP = $((Resolve-DnsName $RemoteIP -QuickTimeout -ErrorAction SilentlyContinue).NameHost)}
    #                                     } -ArgumentList @($RemoteIP,$null)
    #                                 }
    #                             }

    #                             $script:ProgressBarQueriesProgressBar.Value = 0
    #                             $script:ProgressBarQueriesProgressBar.Maximum = (Get-Job -Name "nslookup:*").count
    #                             while ((Get-Job -Name "nslookup:*").State -match 'Running'){
    #                                 $Jobs = Get-Job -Name "nslookup:*"
    #                                 "$($Jobs.count) / $(($jobs.State -match 'Complete').count)"
    #                                 if ($($Jobs.count) -eq $(($jobs.State -match 'Complete').count)){break}

    #                                 $script:ProgressBarQueriesProgressBar.Value = ($jobs.State -match 'Complete').count
    #                                 $script:ProgressBarQueriesProgressBar.Refresh()
    #                                 Start-Sleep -Milliseconds 250
    #                             }
    #                             $script:ProgressBarQueriesProgressBar.Maximum = 1
    #                             $script:ProgressBarQueriesProgressBar.Value = 1
    #                             $StatusListBox.Items.Clear()
    #                             $StatusListBox.Items.Add("Conducting DNS Resolution - Completed")
    #                             $PoShEasyWin.Refresh()

    #                             $UnresolvedCount = 0
    #                             ForEach ($Job in (Get-Job -Name "nslookup:*")){
    #                                 $JobRecieved = $Job | Receive-Job
    #                                 if ($JobRecieved.Values -ne $null) {
    #                                     $script:DNSResolvedList.add("$($JobRecieved.Keys)", "$($JobRecieved.Values)")
    #                                 }
    #                                 else {
    #                                     $UnresolvedCount += 1
    #                                     $script:DNSResolvedList.add("$($JobRecieved.Keys)", "Unresolved: $($UnresolvedCount)")
    #                                 }
    #                             }
    #                             Get-Job  -Name "nslookup:*" | Remove-Job
    #                             ###################################
    #                             # Hashtable of DNS Results // END #
    #                             ###################################
    #                     }
    #                     #$DomainDNSHostnameList = @()
    #                     #foreach ($Endpoint in $script:DNSResolvedList.Values) {
    #                     #    $Endpoint = $Endpoint.split('.')[0]
    #                     #    if ( $Endpoint -in $script:AllComputersList -and $Endpoint -notin $DomainDNSHostnameList ) {
    #                     #        $DomainDNSHostnameList += $Endpoint
    #                     #    }
    #                     #}
    #                     #$DomainDNSHostnameList


    #                     $StatusListBox.Items.Clear()
    #                     $StatusListBox.Items.Add("Generating Graphs, Charts, & Tables")
    #                     $PoShEasyWin.Refresh()

    #                     $script:PoShEasyWinIPAddress = ($script:IPAddressesToExcludeTextboxtext).split() | Where-Object {$_ -ne '' -and $_ -ne $null}

    #                     if ($script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked -and $script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked){
    #                         $Filter = { ($_.RemoteAddress -notin $script:PoShEasyWinIPAddress -and $_.LocalAddress -notin $script:PoShEasyWinIPAddress) -and ($_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':') }
    #                     }
    #                     elseif ( $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked ) {
    #                         $Filter = { $_.RemoteAddress -notin $script:PoShEasyWinIPAddress -and $_.LocalAddress -notin $script:PoShEasyWinIPAddress}
    #                     }
    #                     elseif ($script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked) {
    #                         $Filter = { $_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':' }
    #                     }
    #                     else {
    #                         $Filter = { $_.LocalAddress -notmatch $false }
    #                     }


    #                     $InputData | Where-Object -FilterScript $filter | ForEach-Object {
    #                         function New-ComputerNode {

    #                             #if ($DNSHostname.split('.')[0] -in $script:AllComputersList) {
    #                             #if ( $_.RemoteAddress -in $DomainDNSIPList ) {
    #                             #    $ResolvedHoseName = ($script:DNSResolvedList[$_.RemoteAddress]).spit('.')[0]
    #                             #}

    #                             if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {
    #                                 if ( $script:DNSResolvedList[$_.RemoteAddress] ) {
    #                                     $ResolvedHoseName = "DNS Resolution:`n$( $script:DNSResolvedList[$_.RemoteAddress] )"
    #                                 }

    #                                 if ($ResolvedHoseName -notin $script:NameNodeList -and $_.RemoteAddress -notin $script:LocalAddressList) {
    #                                     New-DiagramNode `
    #                                         -Label  $ResolvedHoseName `
    #                                         -To     $_.RemoteAddress `
    #                                         -Image  "$Dependencies\Images\DNS.png" `
    #                                         -Size   25 `
    #                                         -FontSize   20 `
    #                                         -FontColor  Blue `
    #                                         -LinkColor  Blue

    #                                     $script:LocalAddressList += $_.RemoteAddress
    #                                     $script:NameNodeList += $ResolvedHoseName
    #                                     $script:NameNodeList += $DNSResolution
    #                                 }
    #                             }

    #                             if ($_.LocalAddress -match '127(\.\d){3}' -or $_.LocalAddress -match '0.0.0.0' ) {

    #                                 if ($_.LocalAddress -notin $NIClist) {
    #                                     New-DiagramNode `
    #                                         -Label  $_.PSComputerName `
    #                                         -To     "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
    #                                         -Image  "$Dependencies\Images\Computer.jpg" `
    #                                         -Size   65 `
    #                                         -FontSize   20 `
    #                                         -FontColor  Blue `
    #                                         -LinkColor  Blue `
    #                                         -ArrowsToEnabled
    #                                     $NIClist += $_.LocalAddress
    #                                 }
    #                                 New-DiagramNode `
    #                                     -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
    #                                     -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
    #                                     -Image  "$Dependencies\Images\NIC.jpg" `
    #                                     -Size   40 `
    #                                     -LinkColor Blue `
    #                                     -ArrowsToEnabled
    #                             }
    #                             else {
    #                                 if ($_.LocalAddress -notin $NIClist) {
    #                                     New-DiagramNode `
    #                                         -Label  $_.PSComputerName `
    #                                         -To     $_.LocalAddress `
    #                                         -Image  "$Dependencies\Images\Computer.jpg" `
    #                                         -Size   65 `
    #                                         -FontSize   20 `
    #                                         -FontColor  Blue `
    #                                         -LinkColor  Blue `
    #                                         -ArrowsToEnabled
    #                                     $NIClist += $_.LocalAddress
    #                                 }
    #                                 New-DiagramNode `
    #                                     -Label  $_.LocalAddress `
    #                                     -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
    #                                     -Image  "$Dependencies\Images\NIC.jpg" `
    #                                     -Size   40 `
    #                                     -LinkColor Blue `
    #                                     -ArrowsToEnabled
    #                             }
    #                         }

    #                         function New-ProcessConnectionNodes {
    #                             param(
    #                                 $IconColor,
    #                                 $LinkColor
    #                             )
    #                             if ($_.RemotePort -ne '0'){
    #                                 New-DiagramNode `
    #                                     -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
    #                                     -To     "$($_.LocalAddress):$($_.LocalPort)" `
    #                                     -Image  "$Dependencies\Images\Process.jpg" `
    #                                     -size   25 `
    #                                     -LinkColor $IconColor `
    #                                     -ArrowsToEnabled
    #                                 New-DiagramNode `
    #                                     -Label  "$($_.LocalAddress):$($_.LocalPort)" `
    #                                     -To     "$($_.RemoteAddress):$($_.RemotePort)" `
    #                                     -Size   20 `
    #                                     -IconSolid  Network-wired `
    #                                     -IconColor  $IconColor `
    #                                     -LinkColor  $IconColor `
    #                                     -ArrowsToEnabled
    #                                 New-DiagramNode `
    #                                     -Label  "$($_.RemoteAddress):$($_.RemotePort)" `
    #                                     -To     $_.RemoteAddress `
    #                                     -Size   20 `
    #                                     -IconSolid  Network-wired `
    #                                     -IconColor  $IconColor `
    #                                     -LinkColor  $IconColor `
    #                                     -ArrowsToEnabled
    #                                 New-DiagramNode `
    #                                     -Label  $_.RemoteIPPort  `
    #                                     -To     $_.RemoteAddress `
    #                                     -Size   20 `
    #                                     -IconSolid  Network-wired `
    #                                     -IconColor  $IconColor `
    #                                     -LinkColor  $IconColor `
    #                                     -ArrowsToEnabled
    #                                 New-DiagramNode `
    #                                     -Label  $_.RemoteAddress `
    #                                     -Image  "$Dependencies\Images\NIC.jpg" `
    #                                     -size   40 `
    #                                     -LinkColor $IconColor `
    #                                     -ArrowsToEnabled
    #                             }
    #                         }

    #                         # Only creates nodes for IPs that are not PoSh-EasyWin IPs
    #                         if ($_.state -match 'Established' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Established'){
    #                             New-ComputerNode
    #                             New-ProcessConnectionNodes -IconColor DarkBlue -LinkColor Blue
    #                         }
    #                         elseif ($_.state -match 'Bound' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Bound') {
    #                             New-ComputerNode
    #                             New-ProcessConnectionNodes -IconColor Brown -LinkColor DarkBrown
    #                         }
    #                         elseif ($_.state -match 'CloseWait' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'CloseWait') {
    #                             New-ComputerNode
    #                             New-ProcessConnectionNodes -IconColor Green -LinkColor DarkGreen
    #                         }
    #                         elseif ($_.state -match 'Timeout' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Timeout') {
    #                             New-ComputerNode
    #                             New-ProcessConnectionNodes -IconColor Violet -LinkColor DarkViolet
    #                         }
    #                         elseif ($_.State -match 'All Others' `
    #                             -and ($script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closed' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closing' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'DeleteTCB' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait1' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait2' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'LastAck' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynReceived' `
    #                              -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynSent' ) ) {
    #                             New-ComputerNode
    #                             New-ProcessConnectionNodes -IconColor Gray -LinkColor DarkGray
    #                         }
    #                         elseif ($_.state -match 'Listen' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Listen'){
    #                             New-DiagramNode `
    #                                 -Label  $_.PSComputerName `
    #                                 -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
    #                                 -Image  "$Dependencies\Images\Computer.jpg" `
    #                                 -Size   65 `
    #                                 -FontSize   20 `
    #                                 -FontColor  Orange `
    #                                 -LinkColor  Gold `
    #                                 -ArrowsToEnabled
    #                             New-DiagramNode `
    #                                 -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
    #                                 -To     "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
    #                                 -Image  "$Dependencies\Images\Process.jpg" `
    #                                 -size   25 `
    #                                 -LinkColor Gold `
    #                                 -ArrowsToEnabled
    #                             New-DiagramNode `
    #                                 -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
    #                                 -shape  dot `
    #                                 -Size   10 `
    #                                 -ColorBorder      Orange `
    #                                 -ColorBackground  Yellow `
    #                                 -LinkColor        Gold `
    #                                 -ArrowsToEnabled
    #                         }
    #                     }
    #                 }
    #             }
    #         }
    #     }
    # }
}










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeljjVpDG/Egdv7eWm1odT7/b
# 71OgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUc8hf32R2WczWGy6zas/kgAI0cnAwDQYJKoZI
# hvcNAQEBBQAEggEAVoNbYPsKiovm4dWXTkpLMFXNkdUubAtwvTnqep4Zv/HuNJ+K
# 1UmJhuGQFvI3S4M6ItQ1qmeK6177cmNhncwL1Fa1gggZCiwsvOrQzHeDU+aZ5Dm5
# iRA9UbRNJ9we5UVuxsHgXIJN3FNagPWgOUORGCNVjUv8LdaaBBk1ytRCPr7CQ4Sg
# yhpXMCYsA81XVZOI5+BlijJ4lBGLPlgfBGhKJKukvRojFSQdM4UBJkrXMWae56Al
# AW//WK1QhiR0ZKvSvHr2RH45dLbF+UllAxKSQT6GyonsQzJjawA7JhHEJj+tNvLS
# je4t4r4WOJ60xM8cVmdKT3EUMlhojZJ7TAHo2A==
# SIG # End signature block
