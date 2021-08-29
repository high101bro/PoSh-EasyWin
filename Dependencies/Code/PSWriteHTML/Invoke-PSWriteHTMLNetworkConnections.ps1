function script:Invoke-PSWriteHTMLNetworkConnections {
    param(
        $InputData = $null,
        [switch]$MenuPrompt
    )
    if ( $MenuPrompt ) { script:Launch-NetworkConnectionGUI }

    $InputData = $InputData | Select-Object -Property RemoteIPPort, LocalIPPort, PSComputerName, State, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, ProcessName, ProcessId, ParentProcessId, CreationTime, Duration, CommandLine, ExecutablePath, MD5Hash, OwningProcess, CollectionMethod
    $NetworkConnectionsLocalPortsListening    = $InputData | Select-Object LocalPort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Listen'} | Group-Object LocalPort | Sort-Object Count, Name
    $NetworkConnectionsRemotePortsEstablished = $InputData | Select-Object RemotePort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Establish'} | Group-Object RemotePort | Sort-Object Count, Name
    $NetworkConnectionsRemoteLocalIPsUnique   = $InputData | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
    $NetworkConnectionsRemoteLocalIPsSum      = $InputData | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
    $NetworkConnectionsRemotePublicIPsUnique  = $InputData | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name
    $NetworkConnectionsRemotePublicIPsSum     = $InputData | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name  

    New-HTMLTab -Name 'TCP Connections' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Pane Search' -IconSolid th {
            New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
            New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData {
                    New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Network Connections Data' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                New-HTMLCalendar {
                    foreach ($_ in $InputData) {
                        New-CalendarEvent -StartDate $_.CreationTime `
                        -Title "$($_.PSComputerName) [$($_.State)] $($_.RemoteAddress):$($_.RemotePort)" `
                        -Description "$($_.PSComputerName) || State: $($_.State) || $($_.LocalAddress):$($_.LocalPort) <--> $($_.RemoteAddress):$($_.RemotePort) || Start Time: $($_.StartTime) || Process: $($_.ProcessName):$($_.ProcessID)"
                    }
                } -InitialView dayGridMonth #timeGridDay
            }
        }
        ###########
        New-HTMLTab -Name 'Charts' -IconRegular chart-bar { 
            script:Generate-TablePieBarCharts -Title "Local Ports Listening" -Data $NetworkConnectionsLocalPortsListening
            script:Generate-TablePieBarCharts -Title "Remote Ports Established" -Data $NetworkConnectionsRemotePortsEstablished
            script:Generate-TablePieBarCharts -Title "Remote Local IPs Unique" -Data $NetworkConnectionsRemoteLocalIPsUnique
            script:Generate-TablePieBarCharts -Title "Remote Local IPs Sum" -Data $NetworkConnectionsRemoteLocalIPsSum
            script:Generate-TablePieBarCharts -Title "Remote Public IPs Unique" -Data $NetworkConnectionsRemotePublicIPsUnique
            script:Generate-TablePieBarCharts -Title "Remote Public IPs Sum" -Data $NetworkConnectionsRemotePublicIPsSum
        }        
        ###########
        New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
            $DataTableID = Get-Random -Minimum 100000 -Maximum 2000000
            $InputData = $InputData | Select-Object RemoteIPPort, * -ErrorAction SilentlyContinue
            New-HTMLSection -HeaderText 'Network Connections' -CanCollapse {
                New-HTMLPanel -Width 40% {
                    New-HTMLTable -DataTable $InputData -DataTableID $DataTableID -SearchRegularExpression  {
                        New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                    } 
                }
                New-HTMLPanel {
                    
                    New-HTMLText `
                        -FontSize 12 `
                        -FontFamily 'Source Sans Pro' `
                        -Color Blue `
                        -Text 'Click On The Network Connection Icons To Automatically Locate Them Within The Table'

                    New-HTMLDiagram -Height '1000px' {
                        New-DiagramEvent -ID $DataTableID -ColumnID 1
                        New-DiagramEvent -ID $DataTableID -ColumnID 2
                        New-DiagramEvent -ID $DataTableID -ColumnID 3
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

                        $script:LocalAddressList = $InputData | Select-Object -ExpandProperty LocalAddress | Sort-Object -Unique
                        $script:NameNodeList = $InputData | Select-Object -ExpandProperty PSComputerName | Sort-Object -Unique


                        #$script:AllComputersList = @()
                        #[System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                        #foreach ($root in $AllTreeViewNodes) {
                        #    foreach ($Category in $root.Nodes) {
                        #        foreach ($Entry in $Category.nodes) {
                        #            $script:AllComputersList += $Entry.text
                        #        }
                        #    }
                        #}
                        if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {

                                #####################################
                                # Hashtable of DNS Results // START #
                                #####################################
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Conducting DNS Resolution - In Progress")
                                $PoShEasyWin.Refresh()
                    
                                $script:DNSResolvedList = @{}
                                $RemoteAddresses = ($InputData).RemoteAddress | `
                                    Sort-Object -Unique `
                                    | Where-Object {$_ -ne '::' -and $_ -ne '::1' -and $_ -ne '0.0.0.0' -and $_ -ne '127.0.0.1'}
                                Get-Job  -Name "nslookup:*" | Remove-Job -Force
                                foreach ( $RemoteIP in $RemoteAddresses ) {
                                    if ($script:DNSResolvedList.ContainsKey($RemoteIP)) {
                                        $null
                                    }
                                    else {
                                        Start-Job -Name "nslookup:$RemoteIP" `
                                        -ScriptBlock {
                                            param($RemoteIP)
                                            return @{$RemoteIP = $((Resolve-DnsName $RemoteIP -QuickTimeout -ErrorAction SilentlyContinue).NameHost)}
                                        } -ArgumentList @($RemoteIP,$null)
                                    }
                                }

                                $script:ProgressBarQueriesProgressBar.Value = 0
                                $script:ProgressBarQueriesProgressBar.Maximum = (Get-Job -Name "nslookup:*").count
                                while ((Get-Job -Name "nslookup:*").State -match 'Running'){
                                    $Jobs = Get-Job -Name "nslookup:*"
                                    "$($Jobs.count) / $(($jobs.State -match 'Complete').count)"
                                    if ($($Jobs.count) -eq $(($jobs.State -match 'Complete').count)){break}

                                    $script:ProgressBarQueriesProgressBar.Value = ($jobs.State -match 'Complete').count
                                    $script:ProgressBarQueriesProgressBar.Refresh()
                                    Start-Sleep -Milliseconds 250
                                }
                                $script:ProgressBarQueriesProgressBar.Maximum = 1
                                $script:ProgressBarQueriesProgressBar.Value = 1
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Conducting DNS Resolution - Completed")
                                $PoShEasyWin.Refresh()

                                $UnresolvedCount = 0
                                ForEach ($Job in (Get-Job -Name "nslookup:*")){
                                    $JobRecieved = $Job | Receive-Job
                                    if ($JobRecieved.Values -ne $null) {
                                        $script:DNSResolvedList.add("$($JobRecieved.Keys)", "$($JobRecieved.Values)")
                                    }
                                    else {
                                        $UnresolvedCount += 1
                                        $script:DNSResolvedList.add("$($JobRecieved.Keys)", "Unresolved: $($UnresolvedCount)")
                                    }
                                }
                                Get-Job  -Name "nslookup:*" | Remove-Job
                                ###################################
                                # Hashtable of DNS Results // END #
                                ###################################
                        }
                        #$DomainDNSHostnameList = @()
                        #foreach ($Endpoint in $script:DNSResolvedList.Values) {
                        #    $Endpoint = $Endpoint.split('.')[0]
                        #    if ( $Endpoint -in $script:AllComputersList -and $Endpoint -notin $DomainDNSHostnameList ) {
                        #        $DomainDNSHostnameList += $Endpoint
                        #    }
                        #}
                        #$DomainDNSHostnameList

                        
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Generating Graphs, Charts, & Tables")
                        $PoShEasyWin.Refresh()

                        $script:PoShEasyWinIPAddress = ($script:IPAddressesToExcludeTextboxtext).split() | Where-Object {$_ -ne '' -and $_ -ne $null}

                        if ($script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked -and $script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked){
                            $Filter = { ($_.RemoteAddress -notin $script:PoShEasyWinIPAddress -and $_.LocalAddress -notin $script:PoShEasyWinIPAddress) -and ($_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':') }
                        }
                        elseif ( $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked ) {
                            $Filter = { $_.RemoteAddress -notin $script:PoShEasyWinIPAddress -and $_.LocalAddress -notin $script:PoShEasyWinIPAddress}
                        }
                        elseif ($script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked) {
                            $Filter = { $_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':' }
                        }
                        else {
                            $Filter = { $_.LocalAddress -notmatch $false }
                        }
            
                        # $script:PoShEasyWinIPAddress | ogv
                        # $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked | ogv
                        # $script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked | ogv

                        $InputData | Where-Object -FilterScript $filter | ForEach-Object {
                            function New-ComputerNode {

                                #if ($DNSHostname.split('.')[0] -in $script:AllComputersList) { 
                                #if ( $_.RemoteAddress -in $DomainDNSIPList ) {
                                #    $ResolvedHoseName = ($script:DNSResolvedList[$_.RemoteAddress]).spit('.')[0]
                                #}

                                if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {
                                    if ( $script:DNSResolvedList[$_.RemoteAddress] ) {
                                        $ResolvedHoseName = "DNS Resolution:`n$( $script:DNSResolvedList[$_.RemoteAddress] )"
                                    }

                                    if ($ResolvedHoseName -notin $script:NameNodeList -and $_.RemoteAddress -notin $script:LocalAddressList) {
                                        New-DiagramNode `
                                            -Label  $ResolvedHoseName `
                                            -To     $_.RemoteAddress `
                                            -Image  "$Dependencies\Images\DNS.png" `
                                            -Size   25 `
                                            -FontSize   20 `
                                            -FontColor  Blue `
                                            -LinkColor  Blue
                                        
                                        $script:LocalAddressList += $_.RemoteAddress
                                        $script:NameNodeList += $ResolvedHoseName
                                        $script:NameNodeList += $DNSResolution
                                    }
                                }

                                if ($_.LocalAddress -match '127(\.\d){3}' -or $_.LocalAddress -match '0.0.0.0' ) {
                                    
                                    if ($_.LocalAddress -notin $NIClist) {
                                        New-DiagramNode `
                                            -Label  $_.PSComputerName `
                                            -To     "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -Size   65 `
                                            -FontSize   20 `
                                            -FontColor  Blue `
                                            -LinkColor  Blue `
                                            -ArrowsToEnabled
                                        $NIClist += $_.LocalAddress
                                    }
                                    New-DiagramNode `
                                        -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
                                        -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -Size   40 `
                                        -LinkColor Blue `
                                        -ArrowsToEnabled
                                }
                                else {
                                    if ($_.LocalAddress -notin $NIClist) {
                                        New-DiagramNode `
                                            -Label  $_.PSComputerName `
                                            -To     $_.LocalAddress `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -Size   65 `
                                            -FontSize   20 `
                                            -FontColor  Blue `
                                            -LinkColor  Blue `
                                            -ArrowsToEnabled
                                        $NIClist += $_.LocalAddress
                                    }
                                    New-DiagramNode `
                                        -Label  $_.LocalAddress `
                                        -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -Size   40 `
                                        -LinkColor Blue `
                                        -ArrowsToEnabled
                                }
                            }

                            function New-ProcessConnectionNodes {
                                param(
                                    $IconColor,
                                    $LinkColor
                                )
                                if ($_.RemotePort -ne '0'){
                                    New-DiagramNode `
                                        -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                        -To     "$($_.LocalAddress):$($_.LocalPort)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   25 `
                                        -LinkColor $IconColor `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "$($_.LocalAddress):$($_.LocalPort)" `
                                        -To     "$($_.RemoteAddress):$($_.RemotePort)" `
                                        -Size   20 `
                                        -IconSolid  Network-wired `
                                        -IconColor  $IconColor `
                                        -LinkColor  $IconColor `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "$($_.RemoteAddress):$($_.RemotePort)" `
                                        -To     $_.RemoteAddress `
                                        -Size   20 `
                                        -IconSolid  Network-wired `
                                        -IconColor  $IconColor `
                                        -LinkColor  $IconColor `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  $_.RemoteIPPort  `
                                        -To     $_.RemoteAddress `
                                        -Size   20 `
                                        -IconSolid  Network-wired `
                                        -IconColor  $IconColor `
                                        -LinkColor  $IconColor `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  $_.RemoteAddress `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -size   40 `
                                        -LinkColor $IconColor `
                                        -ArrowsToEnabled
                                }                                        
                            }

                            # Only creates nodes for IPs that are not PoSh-EasyWin IPs
                            if ($_.state -match 'Established' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Established'){
                                New-ComputerNode
                                New-ProcessConnectionNodes -IconColor DarkBlue -LinkColor Blue
                            }
                            elseif ($_.state -match 'Bound' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Bound') {
                                New-ComputerNode
                                New-ProcessConnectionNodes -IconColor Brown -LinkColor DarkBrown
                            }
                            elseif ($_.state -match 'CloseWait' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'CloseWait') {
                                New-ComputerNode
                                New-ProcessConnectionNodes -IconColor Green -LinkColor DarkGreen
                            }
                            elseif ($_.state -match 'Timeout' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Timeout') {
                                New-ComputerNode
                                New-ProcessConnectionNodes -IconColor Violet -LinkColor DarkViolet
                            }
                            elseif ($_.State -match 'All Others' `
                                -and ($script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closed' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closing' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'DeleteTCB' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait1' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait2' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'LastAck' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynReceived' `
                                 -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynSent' ) ) {
                                New-ComputerNode
                                New-ProcessConnectionNodes -IconColor Gray -LinkColor DarkGray
                            }
                            elseif ($_.state -match 'Listen' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Listen'){
                                New-DiagramNode `
                                    -Label  $_.PSComputerName `
                                    -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   65 `
                                    -FontSize   20 `
                                    -FontColor  Orange `
                                    -LinkColor  Gold `
                                    -ArrowsToEnabled
                                New-DiagramNode `
                                    -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                    -To     "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
                                    -Image  "$Dependencies\Images\Process.jpg" `
                                    -size   25 `
                                    -LinkColor Gold `
                                    -ArrowsToEnabled
                                New-DiagramNode `
                                    -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
                                    -shape  dot `
                                    -Size   10 `
                                    -ColorBorder      Orange `
                                    -ColorBackground  Yellow `
                                    -LinkColor        Gold `
                                    -ArrowsToEnabled
                            }
                        }
                    }
                }
            }
        }
    }
} 