$AutoCreateMultiSeriesChartButtonAdd_Click = {
    # https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
    # https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/
    # Auto Charts Select Property Function

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    

    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        width         = $FormScale * 327
        height        = $FormScale * 205
        StartPosition = "CenterScreen"
        Text          = "Multi-Series Chart"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        Add_Closing = { $This.dispose() }
    }
                $AutoChartsMainLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text     = "Create A Multi-Series Chart From Past Collected Data"
                    Location = @{ X = $FormScale * 10
                                Y = $FormScale * 10 }
                    Size     = @{ Width  = $FormScale * 300
                                Height = $FormScale * 25 }
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)


                $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text      = "Select A Chart"
                    Location  = @{ X = $FormScale * 10
                                Y = $AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + $($FormScale * 5) }
                    Size      = @{ Width  = $FormScale * 292
                                Height = $FormScale * 25 }
                    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    ForeColor = 'Red'
                    AutoCompleteSource = "ListItems"
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                }
                $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Launch-AutoChartsViewCharts }})
                $AutoChartSelectChartComboBox.Add_Click({
                    if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
                    else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
                })
                $AutoChartsAvailable = @(
                    "Disk Drives by Model",
                    "Disk Drive Models per Endpoint",
                    "Interface Alias",
                    "Interfaces with IPs per Endpoint",
                    "Local User Accounts",
                    "Local Accounts per Endpoint",
                    "Mapped Drives by Device ID",
                    "Mapped Drive Device IDs per Endpoint",
                    "Mapped Drives by Volume Name",
                    "Mapped Drive Volume Names per Endpoint",
                    "Process Names",
                    "Process Paths",
                    "Process Company",
                    "Process Product",
                    "Processes per Endpoint",
                    "Process MD5 Hashes",
                    "Process Signer Certificate",
                    "Process Signer Company",
                    "Security Patches HotFixes",
                    "Security Patches Service Packs In Effect",
                    "Security Patches per Endpoint",
                    "Services Names",
                    "Services Paths",
                    "Services per Endpoint",
                    "Share Names",
                    "Share Paths",
                    "Shares per Endpoint",
                    "Software Installed by Names",
                    "Software Installed by Vendors",
                    "Software Installed per Endpoint",
                    "Startup Names",
                    "Startup Commands",
                    "Startups per Endpoint"
                    )
                ForEach ($Item in $AutoChartsAvailable) { [void] $AutoChartSelectChartComboBox.Items.Add($Item) }
                $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox)


                $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
                    Style    = "Continuous"
                    #Maximum = 10
                    Minimum  = 0
                    Location = @{ X = $FormScale * 10
                                Y = $AutoChartSelectChartComboBox.Location.y + $AutoChartSelectChartComboBox.Size.Height + $($FormScale * 10) }
                    Size     = @{ Width  = $FormScale * 290
                                Height = $FormScale * 10 }
                    Value   = 0
                }
                $AutoChartsSelectionForm.Controls.Add($script:AutoChartsProgressBar)


                # Create a group that will contain your radio buttons
                $AutoChartsCreateChartsFromGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
                    text     = "Filter Results Using:"
                    Location = @{ X = $FormScale * 10
                                Y = $script:AutoChartsProgressBar.Location.y + $script:AutoChartsProgressBar.Size.Height + $($FormScale * 8) }
                    Size     = @{ Width  = $FormScale * 185
                                Height = $FormScale * 65 }
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                    ### View Chart WMI Results Checkbox
                    $AutoChartsWmiCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Text     = "WMI Collections"
                        Location = @{ X = $FormScale * 10
                                    Y = $FormScale * 15 }
                        Size     = @{ Width  = $FormScale * 164
                                    Height = $FormScale * 25 }
                        Checked  = $false
                        Enabled  = $true
                        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    }
                    $AutoChartsWmiCollectionsCheckBox.Add_Click({ $AutoChartsPoShCollectionsCheckBox.Checked = $false })

                    ### View Chart WinRM Results Checkbox
                    $AutoChartsPoShCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Location = @{ X = $FormScale * 10
                                    Y = $FormScale * 38 }
                        Size     = @{ Width  = $FormScale * 165
                                    Height = $FormScale * 25 }
                        Checked  = $false
                        Enabled  = $true
                        Text     = "PoSh Collections"
                        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    }
                    $AutoChartsPoShCollectionsCheckBox.Add_Click({ $AutoChartsWmiCollectionsCheckBox.Checked  = $false })

                    $AutoChartsCreateChartsFromGroupBox.Controls.AddRange(@($AutoChartsWmiCollectionsCheckBox,$AutoChartsPoShCollectionsCheckBox))
                $AutoChartsSelectionForm.Controls.Add($AutoChartsCreateChartsFromGroupBox)


                $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
                    Text     = "View Chart"
                    Location = @{ X = $AutoChartsCreateChartsFromGroupBox.Location.X + $AutoChartsCreateChartsFromGroupBox.Size.Width + $($FormScale * 5)
                                Y = $AutoChartsCreateChartsFromGroupBox.Location.y + $($FormScale * 5) }
                    Size     = @{ Width  = $FormScale * 101
                                Height = $FormScale * 59 }
                }
                Apply-CommonButtonSettings -Button $AutoChartsExecuteButton
                $AutoChartsExecuteButton.Add_Click({
                    if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
                    else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
                    Launch-AutoChartsViewCharts
                })
                function Launch-AutoChartsViewCharts {
                    ## Auto Create Charts Form
                    $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
                    $script:AutoChartsForm               = New-Object Windows.Forms.Form
                    $script:AutoChartsForm.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    $script:AutoChartsForm.Width         = $PoShEasyWin.Size.Width  #1160
                    $script:AutoChartsForm.Height        = $PoShEasyWin.Size.Height #638
                    $script:AutoChartsForm.StartPosition = "CenterScreen"
                    $script:AutoChartsForm.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    $script:AutoChartsForm.Add_Closing = { $This.dispose() }


                    ## Auto Create Charts TabControl
                    # The TabControl controls the tabs within it
                    $AutoChartsTabControl               = New-Object System.Windows.Forms.TabControl
                    $AutoChartsTabControl.Name          = "Auto Charts"
                    $AutoChartsTabControl.Text          = "Auto Charts"
                    $AutoChartsTabControl.Location      = New-Object System.Drawing.Point($($FormScale * 5),$($FormScale * 5))
                    $AutoChartsTabControl.Size          = New-Object System.Drawing.Size($($FormScale * 1535),$($FormScale * 590))
                    $AutoChartsTabControl.ShowToolTips  = $True
                    $AutoChartsTabControl.SelectedIndex = 0
                    $AutoChartsTabControl.Anchor        = $AnchorAll
                    $AutoChartsTabControl.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    $script:AutoChartsForm.Controls.Add($AutoChartsTabControl)

                    # Accounts
                    if     ($AutoChartSelectChartComboBox.SelectedItem -eq "Local User Accounts") { Generate-AutoChartsCommand -QueryName "Local Users" -QueryTabName "Local User Accounts" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Local Accounts per Endpoint") { Generate-AutoChartsCommand -QueryName "Local Users" -QueryTabName "Local Accounts per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Interface / Network Settings
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Interface Alias") { Generate-AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Interface Alias" -PropertyX "InterfaceAlias" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Interfaces with IPs per Endpoint") { Generate-AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Interfaces with IPs per Endpoint" -PropertyX "PSComputerName" -PropertyY "IPAddress" }

                    # Mapped Drives
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Disk Drives by Model") { Generate-AutoChartsCommand -QueryName "Disk - Physical Info" -QueryTabName "Disk Drives by Model" -PropertyX "PSComputerName" -PropertyY "Model" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Disk Drive Models per Endpoint") { Generate-AutoChartsCommand -QueryName "Disk - Physical Info" -QueryTabName "Disk Drive Models per Endpoint" -PropertyX "Model" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Device ID") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drives by Device ID" -PropertyX "PSComputerName" -PropertyY "DeviceID" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Device IDs per Endpoint") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drive Device IDs per Endpoint" -PropertyX "DeviceID" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Volume Name") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drives by Volume Name" -PropertyX "PSComputerName" -PropertyY "VolumeName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Volume Names per Endpoint") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drive Volume Names per Endpoint" -PropertyX "VolumeName" -PropertyY "PSComputerName" }

                    # Processes
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Names") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Names" -PropertyX "Name" -PropertyY "PSComputerName"}
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Paths") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Paths" -PropertyX "Path" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Company") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Company" -PropertyX "Company" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Product") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Product" -PropertyX "Product" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Processes per Endpoint") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Processes per Endpoint" -PropertyX "PSComputerName" -PropertyY "ProcessID" }

                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process MD5 Hashes") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process MD5 Hashes" -PropertyX "MD5Hash" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Signer Certificate") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Signer Certificate" -PropertyX "SignerCertificate" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Signer Company") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Signer Company" -PropertyX "SignerCompany" -PropertyY "PSComputerName" }

                    # Services
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services Names") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Service Names" -PropertyX "Name"     -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services Paths") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Service Paths" -PropertyX "PathName" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services per Endpoint") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Services per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Security Patches
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches HotFixes") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Security Patches Hotfix"    -PropertyX "HotFixID" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches Service Packs In Effect") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Service Packs In Effect" -PropertyX "ServicePackInEffect" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches per Endpoint") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Security Patches per Endpoint"   -PropertyX "PSComputerName" -PropertyY "HotFixID" }

                    # Shares
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Share Names") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Share Names" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Share Paths") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Share Paths" -PropertyX "Path" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Shares per Endpoint") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Software Installed
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed by Names") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed by Names" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed by Vendors") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed by Vendors"             -PropertyX "Vendor" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed per Endpoint") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Startup / Autoruns
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startup Names") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Names"    -PropertyX "Name"    -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startup Commands") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Commands" -PropertyX "Command" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startups per Endpoint") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startups per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }
                }
                $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)
    [void] $AutoChartsSelectionForm.ShowDialog()

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$SendFilesButtonAdd_MouseHover = {
    Show-ToolTip -Title "Multi-Series Chart" -Icon "Info" -Message @"
+  Utilizes PowerShell (v3) charts to visualize data.
+  These charts are auto created from pre-selected CSV files and fields.
+  Multi-series charts are generated from CSV files of similar queries
    for analysis (baseline, previous, and most recents).
+  Multi-series charts will only display results from hosts that are
    found in each series; non-common hosts result will be hidden.
+  Charts can be filtered for data collected via WMI or PoSh commands.
+  Charts can be modified and an image can be saved.
"@
}


