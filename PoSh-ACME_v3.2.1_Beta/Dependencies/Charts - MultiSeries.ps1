# https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
# https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/

#======================================
# Auto Charts Select Property Function
#======================================
function AutoChartsMultiSeriesCharts {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    #----------------------------------
    # Auto Create Charts Selection Form
    #----------------------------------
    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        width         = 327
        height        = 205
        StartPosition = "CenterScreen"
        Text          = "Multi-Series Chart"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoScroll    = $True
    }
    #------------------------------
    # Auto Create Charts Main Label
    #------------------------------
    $AutoChartsMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Create A Multi-Series Chart From Past Collected Data"
        Location = @{ X = 10
                      Y = 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)


    #----------------------------------
    # Auto Chart Select Chart ComboBox
    #----------------------------------
    $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Select A Chart"
        Location  = @{ X = 10
                     Y = $AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + 5 }
        Size      = @{ Width  = 292
                       Height = 25 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Red'
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AutoChartsViewCharts }})
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


    #----------------------------
    # Auto Charts - Progress Bar
    #----------------------------
    $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Style    = "Continuous"
        #Maximum = 10
        Minimum  = 0
        Location = @{ X = 10
                      Y = $AutoChartSelectChartComboBox.Location.y + $AutoChartSelectChartComboBox.Size.Height + 10 }
        Size     = @{ Width  = 290
                      Height = 10 }
        Value   = 0
    }
    $AutoChartsSelectionForm.Controls.Add($script:AutoChartsProgressBar)


    #-----------------------------------------
    # Auto Create Using Results From GroupBox
    #-----------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsCreateChartsFromGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text     = "Filter Results Using:"
        Location = @{ X = 10
                      Y = $script:AutoChartsProgressBar.Location.y + $script:AutoChartsProgressBar.Size.Height + 8 }
        Size     = @{ Width  = 185
                      Height = 65 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
        ### View Chart WMI Results Checkbox
        $AutoChartsWmiCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = "WMI Collections"
            Location = @{ X = 10
                          Y = 15 }
            Size     = @{ Width  = 164
                          Height = 25 }
            Checked  = $false
            Enabled  = $true
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }        
        $AutoChartsWmiCollectionsCheckBox.Add_Click({ $AutoChartsPoShCollectionsCheckBox.Checked = $false })

        ### View Chart WinRM Results Checkbox
        $AutoChartsPoShCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = @{ X = 10
                          Y = 38 }
            Size     = @{ Width  = 165
                          Height = 25 }
            Checked  = $false
            Enabled  = $true
            Text     = "PoSh Collections"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $AutoChartsPoShCollectionsCheckBox.Add_Click({ $AutoChartsWmiCollectionsCheckBox.Checked  = $false })
        
        $AutoChartsCreateChartsFromGroupBox.Controls.AddRange(@($AutoChartsWmiCollectionsCheckBox,$AutoChartsPoShCollectionsCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsCreateChartsFromGroupBox) 


    #-----------------------------------
    # Auto Create Charts Execute Button
    #-----------------------------------
    $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "View Chart"
        Location = @{ X = $AutoChartsCreateChartsFromGroupBox.Location.X + $AutoChartsCreateChartsFromGroupBox.Size.Width + 5
                     Y = $AutoChartsCreateChartsFromGroupBox.Location.y + 5 }
        Size     = @{ Width  = 101
                      Height = 59 }
    }
    $AutoChartsExecuteButton.Add_Click({ 
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
        AutoChartsViewCharts
    })
    function AutoChartsViewCharts {
        #####################################################################################################################################
        #####################################################################################################################################
        ##
        ## Auto Create Charts Form 
        ##
        #####################################################################################################################################             
        #####################################################################################################################################
        $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
            [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $script:AutoChartsForm               = New-Object Windows.Forms.Form
        $script:AutoChartsForm.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        $script:AutoChartsForm.Width         = $PoShACME.Size.Width  #1160
        $script:AutoChartsForm.Height        = $PoShACME.Size.Height #638
        $script:AutoChartsForm.StartPosition = "CenterScreen"
        $script:AutoChartsForm.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)

        #####################################################################################################################################
        ##
        ## Auto Create Charts TabControl
        ##
        #####################################################################################################################################
        # The TabControl controls the tabs within it
        $AutoChartsTabControl               = New-Object System.Windows.Forms.TabControl
        $AutoChartsTabControl.Name          = "Auto Charts"
        $AutoChartsTabControl.Text          = "Auto Charts"
        $AutoChartsTabControl.Location      = New-Object System.Drawing.Point(5,5)
        $AutoChartsTabControl.Size          = New-Object System.Drawing.Size(1535,590) 
        $AutoChartsTabControl.ShowToolTips  = $True
        $AutoChartsTabControl.SelectedIndex = 0
        $AutoChartsTabControl.Anchor        = $AnchorAll
        $AutoChartsTabControl.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Device ID") { Generate-AutoChartsCommand -QueryName "Get-MappedDrives" -QueryTabName "Mapped Drives by Device ID" -PropertyX "PSComputerName" -PropertyY "DeviceID" }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Device IDs per Endpoint") { Generate-AutoChartsCommand -QueryName "Get-MappedDrives" -QueryTabName "Mapped Drive Device IDs per Endpoint" -PropertyX "DeviceID" -PropertyY "PSComputerName" }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Volume Name") { Generate-AutoChartsCommand -QueryName "Get-MappedDrives" -QueryTabName "Mapped Drives by Volume Name" -PropertyX "PSComputerName" -PropertyY "VolumeName" }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Volume Names per Endpoint") { Generate-AutoChartsCommand -QueryName "Get-MappedDrives" -QueryTabName "Mapped Drive Volume Names per Endpoint" -PropertyX "VolumeName" -PropertyY "PSComputerName" }

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
}


#=====================================
# Auto Create Charts Command Function
#=====================================
function Generate-AutoChartsCommand {
    param (
        $QueryName,
        $QueryTabName,
        $PropertyX,
        $PropertyY
    )
    # Name of Collected Data Directory
    $CollectedDataDirectory               = "$PoShHome\Collected Data"
    # Location of separate queries
    $CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    # Location of Uncompiled Results
    $IndividualHostResults                = "$CollectedDataTimeStampDirectory\Individual Host Results"

    # Filter results for just WMI Collections
    if ( $AutoChartsWmiCollectionsCheckBox.Checked ) { 
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName | Where {$_ -match 'WMI'} 
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $CSVFileMatch += $CSVFile } }
        }
    }
    # Filter results for other than WMI Collections    
    elseif ( $AutoChartsPoShCollectionsCheckBox.Checked ) { 
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName | Where {$_ -notmatch 'WMI'} 
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $CSVFileMatch += $CSVFile } }
        }
    }
    # Don't filter results
    else {
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $CSVFileMatch += $CSVFile } }
        }
    }

    # Checkes if the Appropriate Checkbox is selected, if so it selects the very first, previous, and most recent collections respectively
    # Each below will be the filename/path for their respective collection: baseline, previous, and most recent
    $script:CSVFilePathBaseline   = $CSVFileMatch | Select-Object -First 1
    $script:CSVFilePathPrevious   = $CSVFileMatch | Select-Object -Last 2 | Select-Object -First 1
    $script:CSVFilePathMostRecent = $CSVFileMatch | Select-Object -Last 1

    # Checks if the files selected are identicle, removing series as necessary that are to prevent erroneous double data
    if ($script:CSVFilePathMostRecent -eq $script:CSVFilePathPrevious) {$script:CSVFilePathPrevious = $null}
    if ($script:CSVFilePathMostRecent -eq $script:CSVFilePathBaseline) {$script:CSVFilePathBaseline = $null}
    if ($script:CSVFilePathPrevious   -eq $script:CSVFilePathBaseline) {$script:CSVFilePathPrevious = $null}   
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    #--------------------------
    # Auto Create Charts Object
    #--------------------------
    Clear-Variable -Name script:AutoChart
    $script:AutoChart                 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $script:AutoChart.Width           = 1115
    $script:AutoChart.Height          = 552
    $script:AutoChart.Left            = 5
    $script:AutoChart.Top             = 7
    $script:AutoChart.BackColor       = [System.Drawing.Color]::White
    $script:AutoChart.BorderColor     = 'Black'
    $script:AutoChart.BorderDashStyle = 'Solid'
    #$script:AutoChart.DataManipulator.Sort() = "Descending"
    $script:AutoChart.Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    $script:AutoChart.Anchor          = $AnchorAll
    $script:AutoChart.Add_MouseEnter({
        $script:AutoChartsOptionsButton.Text = 'Options v'
        $script:AutoChart.Controls.Remove($script:AutoChartsManipulationPanel)
    })
    
    #--------------------------
    # Auto Create Charts Title 
    #--------------------------
    $script:AutoChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    if (Test-Path "$script:CSVFilePathMostRecent") {
        $script:AutoChartTitle.Text = ($script:CSVFilePathMostRecent.split('\'))[-1] -replace '.csv',''
        $script:AutoChartTitle.ForeColor = "black"
    }
    else {
        $script:AutoChartTitle.Text = "`Missing Data!`n1). Run The Appropriate Query`n2). Ensure To Select At Least One Series"
        $script:AutoChartTitle.ForeColor = "Red"
    }
    $script:AutoChartTitle.Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    $script:AutoChartTitle.Alignment = "topcenter" #"topLeft"
    $script:AutoChart.Titles.Add($script:AutoChartTitle)

    #-------------------------
    # Auto Create Charts Area
    #-------------------------
    $script:AutoChartsArea                        = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $script:AutoChartsArea.Name                   = "Chart Area"
    $script:AutoChartsArea.AxisX.Title            = $PropertyX
    if ( $PropertyY -eq "PSComputername" ) { $script:AutoChartsArea.AxisY.Title = "Hosts" }
    else {
        if ($PropertyY -eq 'Name') { $script:AutoChartsArea.AxisY.Title = "$QueryName" }
        else {$script:AutoChartsArea.AxisY.Title  = "$PropertyY"}
    }
    $script:AutoChartsArea.AxisX.Interval         = 1
    #$script:AutoChartsArea.AxisY.Interval        = 1
    $script:AutoChartsArea.AxisY.IntervalAutoMode = $true
    $script:AutoChart.ChartAreas.Add($script:AutoChartsArea)

    #--------------------------
    # Auto Create Charts Legend 
    #--------------------------
    $script:Legend                      = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $script:Legend.Enabled              = $True
    $script:Legend.Name                 = "Collection Legend"
    $script:Legend.Title                = "Legend"
    $script:Legend.TitleAlignment       = "topleft"
    $script:Legend.TitleFont            = New-Object System.Drawing.Font @('Microsoft Sans Serif','11', [System.Drawing.FontStyle]::Bold)    
    $script:Legend.IsEquallySpacedItems = $True
    $script:Legend.BorderColor          = 'White'
    $script:AutoChart.Legends.Add($script:Legend)

    #--------------------------------------------
    # Auto Create Charts Data Series Most Recent
    #--------------------------------------------
    $script:AutoChart.Series.Add("Most Recent")  
    $script:AutoChart.Series["Most Recent"].Enabled           = $True
    $script:AutoChart.Series["Most Recent"].ChartType         = 'Column'
    $script:AutoChart.Series["Most Recent"].Color             = 'Blue'
    $script:AutoChart.Series["Most Recent"].MarkerColor       = 'Blue'
    $script:AutoChart.Series["Most Recent"].MarkerStyle       = 'Square' # None, Diamond, Square, Circle
    $script:AutoChart.Series["Most Recent"].MarkerSize        = '10'
    $script:AutoChart.Series["Most Recent"].BorderWidth       = 5
    $script:AutoChart.Series["Most Recent"].IsVisibleInLegend = $true
    $script:AutoChart.Series["Most Recent"].Chartarea         = "Chart Area"
    $script:AutoChart.Series["Most Recent"].Legend            = "Legend"
    $script:AutoChart.Series["Most Recent"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChart.Series["Most Recent"]['PieLineColor']   = 'Black'
    $script:AutoChart.Series["Most Recent"]['PieLabelStyle']  = 'Outside'

    #-----------------------------------------
    # Auto Create Charts Data Series Previous
    #-----------------------------------------
    $script:AutoChart.Series.Add("Previous")
    $script:AutoChart.Series["Previous"].Enabled           = $True
    $script:AutoChart.Series["Previous"].ChartType         = 'Point'
    $script:AutoChart.Series["Previous"].Color             = 'Red'
    $script:AutoChart.Series["Previous"].MarkerColor       = 'Red'  
    $script:AutoChart.Series["Previous"].MarkerStyle       = 'Circle' # None, Diamond, Square, Circle
    $script:AutoChart.Series["Previous"].MarkerSize        = '10'            
    $script:AutoChart.Series["Previous"].BorderWidth       = 5
    $script:AutoChart.Series["Previous"].IsVisibleInLegend = $true
    $script:AutoChart.Series["Previous"].Chartarea         = "Chart Area"
    $script:AutoChart.Series["Previous"].Legend            = "Legend"
    $script:AutoChart.Series["Previous"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChart.Series["Previous"]['PieLineColor']   = 'Black'
    $script:AutoChart.Series["Previous"]['PieLabelStyle']  = 'Outside'

    #-----------------------------------------
    # Auto Create Charts Data Series Baseline
    #-----------------------------------------
    $script:AutoChart.Series.Add("Baseline")
    $script:AutoChart.Series["Baseline"].Enabled           = $True
    $script:AutoChart.Series["Baseline"].ChartType         = 'Point'
    $script:AutoChart.Series["Baseline"].Color             = 'Orange'
    $script:AutoChart.Series["Baseline"].MarkerColor       = 'Orange'
    $script:AutoChart.Series["Baseline"].MarkerStyle       = 'Diamond' # None, Diamond, Square
    $script:AutoChart.Series["Baseline"].MarkerSize        = '10'
    $script:AutoChart.Series["Baseline"].BorderWidth       = 5
    $script:AutoChart.Series["Baseline"].IsVisibleInLegend = $true
    $script:AutoChart.Series["Baseline"].Chartarea         = "Chart Area"
    $script:AutoChart.Series["Baseline"].Legend            = "Legend"
    $script:AutoChart.Series["Baseline"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChart.Series["Baseline"]['PieLineColor']   = 'Black'
    $script:AutoChart.Series["Baseline"]['PieLabelStyle']  = 'Outside'

          
    #------------------------------------------------------------
    # Auto Create Charts - Code that counts computers that match
    #------------------------------------------------------------   
    # Compiles the data for only unique/similar hosts... hosts not common among all files are not aggregated
    $Script:MergedCSVUniquePropertyDataResults = @()
    $script:CsvFileCommonDataBaseline   = @()
    $script:CsvFileCommonDataPrevious   = @()
    $script:CsvFileCommonDataMostRecent = @()
    $script:CsvAllHosts = @()

    # Checks if the files exists, then stores the complete csv in a variable
    # Also creates an array of unique hosts per file, which will be LATER further be uniqued
    if (Test-Path $script:CSVFilePathBaseline) {
        $script:CsvFileDataBaseline  = Import-CSV -Path $script:CSVFilePathBaseline | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:CSVFilePathBaseline))};Label="FileName"}
        $CsvFileBaselineHosts = $script:CsvFileDataBaseline | Select-Object -ExpandProperty PSComputerName -Unique
        $script:CsvAllHosts  += $CsvFileBaselineHosts
    }
    else {
        Clear-Variable -Name CsvFileDataBaseline
        Clear-Variable -Name CsvFileBaselineHosts
    }
    if (Test-Path $script:CSVFilePathPrevious) {
        $script:CsvFileDataPrevious  = Import-CSV -Path $script:CSVFilePathPrevious | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:CSVFilePathPrevious))};Label="FileName"}
        $CsvFilePreviousHosts = $script:CsvFileDataPrevious | Select-Object -ExpandProperty PSComputerName -Unique
        $script:CsvAllHosts  += $CsvFilePreviousHosts
    }
    else {
        Clear-Variable -Name CSVFilePathPrevious
        Clear-Variable -Name CsvFilePreviousHosts
    }
    if (Test-Path $script:CSVFilePathMostRecent) {
        $script:CsvFileDataMostRecent  = Import-CSV -Path $script:CSVFilePathMostRecent | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:CSVFilePathMostRecent))};Label="FileName"}
        $CsvFileMostRecentHosts = $script:CsvFileDataMostRecent | Select-Object -ExpandProperty PSComputerName -Unique
        $script:CsvAllHosts    += $CsvFileMostRecentHosts
    }
    else {
        Clear-Variable -Name CSVFilePathMostRecent
        Clear-Variable -Name CsvFileMostRecentHosts
    }
    # Creates a sorted and unique listing of all hosts (PSComputerName), this will be used to compare each csv file against
    $script:CsvUniqueHosts  = @()
    $script:CsvUniqueHosts += $script:CsvAllHosts | Sort-Object -Unique

    # Checks to see if hosts in the overall unique list exist in each csv
    # If one is found that doesn't exist in the csv file, it is removed from the overall list
    # This is to ensure that the results when compared between baseline, previous and most recent match the same computers
    foreach ($UniqueHost in $script:CsvUniqueHosts) { 
        if (Test-Path $script:CSVFilePathBaseline) {
            if ($CsvFileBaselineHosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
        }
        if (Test-Path $script:CSVFilePathPrevious) {
            if ($CsvFilePreviousHosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
        }
        if (Test-Path $script:CSVFilePathMostRecent) {
            if ($CsvFileMostRecentHosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
        }
    }


    if (Test-Path $script:CSVFilePathBaseline) {
        foreach ($UniqueHost in $script:CsvUniqueHosts) { 
            $Script:MergedCSVUniquePropertyDataResults += $script:CsvFileDataBaseline | Where { $_.PSComputerName -eq $UniqueHost } 
            $script:CsvFileCommonDataBaseline += $script:CsvFileDataBaseline | Where { $_.PSComputerName -eq $UniqueHost } 
        }
    }
    if (Test-Path $script:CSVFilePathPrevious) {
        foreach ($UniqueHost in $script:CsvUniqueHosts) { 
            $Script:MergedCSVUniquePropertyDataResults += $script:CsvFileDataPrevious | Where { $_.PSComputerName -eq $UniqueHost } 
            $script:CsvFileCommonDataPrevious += $script:CsvFileDataPrevious | Where { $_.PSComputerName -eq $UniqueHost } 
        }
    }
    if (Test-Path $script:CSVFilePathMostRecent) {
        foreach ($UniqueHost in $script:CsvUniqueHosts) { 
            $Script:MergedCSVUniquePropertyDataResults += $script:CsvFileDataMostRecent | Where { $_.PSComputerName -eq $UniqueHost } 
            $script:CsvFileCommonDataMostRecent += $script:CsvFileDataMostRecent | Where { $_.PSComputerName -eq $UniqueHost } 
        }
    }

    # The purpose of the code below is to ultiately add any missing unique fields to each collection.
    # ex: If the most recent scan/collection contained an item not in the baseline, the baseline will now contain that item but at a zero value
    # This is needed to ensure columns align when viewing multiple scans at once       
    $script:OverallDataResultsBaseline = @()
    if (Test-Path $script:CSVFilePathBaseline) {
        # If the Second field/Y Axis equals PSComputername, it counts it
        if ($PropertyY -eq "PSComputerName") {
            $DataSourceBaseline = @()
            foreach ($UniqueHostBaseline in $script:CsvUniqueHosts) { 
                $DataSourceBaseline += $script:CsvFileCommonDataBaseline | Where-Object { $_.PSComputerName -eq $UniqueHostBaseline } 
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourceBaseline += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $PropertyX -Unique

            # Important, gets a unique list for X and Y
            $UniqueDataFieldsBaseline   = $DataSourceBaseline | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $UniqueComputerListBaseline = $DataSourceBaseline | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
        
            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            foreach ($DataFieldBaseline in $UniqueDataFieldsBaseline) {
                $CountBaseline          = 0
                $CsvComputersBaseline   = @()
                foreach ( $LineBaseline in $DataSourceBaseline ) {
                    if ($($LineBaseline.$PropertyX) -eq $($DataFieldBaseline.$PropertyX)) {
                        $CountBaseline += 1
                        if ( $CsvComputersBaseline -notcontains $($LineBaseline.$PropertyY) ) { $CsvComputersBaseline += $($LineBaseline.$PropertyY) }                        
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults 
                $UniqueCountBaseline = $CsvComputersBaseline.Count - 1 
                $DataResultsBaseline = New-Object PSObject -Property @{
                    DataField   = $DataFieldBaseline
                    TotalCount  = $CountBaseline
                    UniqueCount = $UniqueCountBaseline
                    Computers   = $CsvComputersBaseline 
                }
                $script:OverallDataResultsBaseline += $DataResultsBaseline
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsBaseline.count

            $script:OverallDataResultsBaseline | Sort-Object -Property UniqueCount | ForEach-Object {
                $script:AutoChart.Series["Baseline"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)
                $script:AutoChartsProgressBar.Value += 1
            }
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($PropertyX -eq "PSComputerName") {   

            $DataSourceBaseline = @()
            $DataSourceBaseline = $script:CsvFileCommonDataBaseline 

            $SelectedDataFieldBaseline  = $DataSourceBaseline | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
            $UniqueComputerListBaseline = $DataSourceBaseline | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $CurrentComputerBaseline    = ''
            $CheckIfFirstLineBaseline   = 'False'
            $ResultsCountBaseline       = 0
            $ComputerBaseline           = @()
            $YResultsBaseline           = @()
            foreach ( $LineBaseline in $DataSourceBaseline ) {
                if ( $CheckIfFirstLineBaseline -eq 'False' ) { $CurrentComputerBaseline  = $LineBaseline.$PropertyX ; $CheckIfFirstLineBaseline = 'True' }
                if ( $CheckIfFirstLineBaseline -eq 'True' ) { 
                    if ( $LineBaseline.$PropertyX -eq $CurrentComputerBaseline ) {
                        if ( $YResultsBaseline -notcontains $LineBaseline.$PropertyY ) {
                            if ( $LineBaseline.$PropertyY -ne "" ) { $YResultsBaseline += $LineBaseline.$PropertyY ; $ResultsCountBaseline += 1 }
                            if ( $ComputerBaseline -notcontains $LineBaseline.$PropertyX ) { $ComputerBaseline = $LineBaseline.$PropertyX }
                        }       
                    }
                    elseif ( $LineBaseline.$PropertyX -ne $CurrentComputerBaseline ) { 
                        $CurrentComputerBaseline = $LineBaseline.$PropertyX
                        $DataResultsBaseline     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountBaseline ; Computer = $ComputerBaseline }
                        $script:OverallDataResultsBaseline += $DataResultsBaseline
                        $YResultsBaseline        = @()
                        $ResultsCountBaseline    = 0
                        $ComputerBaseline        = @()
                        if ( $YResultsBaseline -notcontains $LineBaseline.$PropertyY ) {
                            if ( $LineBaseline.$PropertyY -ne "" ) { $YResultsBaseline += $LineBaseline.$PropertyY ; $ResultsCountBaseline += 1 }
                            if ( $ComputerBaseline -notcontains $LineBaseline.$PropertyX ) { $ComputerBaseline = $LineBaseline.$PropertyX }
                        }
                    }
                }
            }
            $DataResultsBaseline = New-Object PSObject -Property @{ ResultsCount = $ResultsCountBaseline ; Computer = $ComputerBaseline }    
            $script:OverallDataResultsBaseline += $DataResultsBaseline
            $script:OverallDataResultsBaseline | ForEach-Object {$script:AutoChart.Series["Baseline"].Points.AddXY($_.Computer,$_.ResultsCount)}        
        } 
    }

    $script:OverallDataResultsPrevious = @()
    if (Test-Path $script:CSVFilePathPrevious) {
        # If the Second field/Y Axis equals PSComputername, it counts it
        if ($PropertyY -eq "PSComputerName") {
            $DataSourcePrevious = @()
            foreach ($UniqueHostPrevious in $script:CsvUniqueHosts) { 
                $DataSourcePrevious += $script:CsvFileCommonDataPrevious | Where-Object { $_.PSComputerName -eq $UniqueHostPrevious } 
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourcePrevious += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $PropertyX -Unique

            # Important, gets a unique list for X and Y
            $UniqueDataFieldsPrevious   = $DataSourcePrevious | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $UniqueComputerListPrevious = $DataSourcePrevious | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
        
            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            foreach ($DataFieldPrevious in $UniqueDataFieldsPrevious) {
                $CountPrevious          = 0
                $CsvComputersPrevious   = @()
                foreach ( $LinePrevious in $DataSourcePrevious ) {
                    if ($($LinePrevious.$PropertyX) -eq $($DataFieldPrevious.$PropertyX)) {
                        $CountPrevious += 1
                        if ( $CsvComputersPrevious -notcontains $($LinePrevious.$PropertyY) ) { $CsvComputersPrevious += $($LinePrevious.$PropertyY) }                        
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults 
                $UniqueCountPrevious = $CsvComputersPrevious.Count - 1 
                $DataResultsPrevious = New-Object PSObject -Property @{
                    DataField   = $DataFieldPrevious
                    TotalCount  = $CountPrevious
                    UniqueCount = $UniqueCountPrevious
                    Computers   = $CsvComputersPrevious 
                }
                $script:OverallDataResultsPrevious += $DataResultsPrevious
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsPrevious.count

            $script:OverallDataResultsPrevious | Sort-Object -Property UniqueCount | ForEach-Object {
                $script:AutoChart.Series["Previous"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)
                $script:AutoChartsProgressBar.Value += 1
            }
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($PropertyX -eq "PSComputerName") {   

            $DataSourcePrevious = @()
            $DataSourcePrevious = $script:CsvFileCommonDataPrevious 

            $SelectedDataFieldPrevious  = $DataSourcePrevious | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
            $UniqueComputerListPrevious = $DataSourcePrevious | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $CurrentComputerPrevious    = ''
            $CheckIfFirstLinePrevious   = 'False'
            $ResultsCountPrevious       = 0
            $ComputerPrevious           = @()
            $YResultsPrevious           = @()
            foreach ( $LinePrevious in $DataSourcePrevious ) {
                if ( $CheckIfFirstLinePrevious -eq 'False' ) { $CurrentComputerPrevious  = $LinePrevious.$PropertyX ; $CheckIfFirstLinePrevious = 'True' }
                if ( $CheckIfFirstLinePrevious -eq 'True' ) { 
                    if ( $LinePrevious.$PropertyX -eq $CurrentComputerPrevious ) {
                        if ( $YResultsPrevious -notcontains $LinePrevious.$PropertyY ) {
                            if ( $LinePrevious.$PropertyY -ne "" ) { $YResultsPrevious += $LinePrevious.$PropertyY ; $ResultsCountPrevious += 1 }
                            if ( $ComputerPrevious -notcontains $LinePrevious.$PropertyX ) { $ComputerPrevious = $LinePrevious.$PropertyX }
                        }       
                    }
                    elseif ( $LinePrevious.$PropertyX -ne $CurrentComputerPrevious ) { 
                        $CurrentComputerPrevious = $LinePrevious.$PropertyX
                        $DataResultsPrevious     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountPrevious ; Computer = $ComputerPrevious }
                        $script:OverallDataResultsPrevious += $DataResultsPrevious
                        $YResultsPrevious        = @()
                        $ResultsCountPrevious    = 0
                        $ComputerPrevious        = @()
                        if ( $YResultsPrevious -notcontains $LinePrevious.$PropertyY ) {
                            if ( $LinePrevious.$PropertyY -ne "" ) { $YResultsPrevious += $LinePrevious.$PropertyY ; $ResultsCountPrevious += 1 }
                            if ( $ComputerPrevious -notcontains $LinePrevious.$PropertyX ) { $ComputerPrevious = $LinePrevious.$PropertyX }
                        }
                    }
                }
            }
            $DataResultsPrevious = New-Object PSObject -Property @{ ResultsCount = $ResultsCountPrevious ; Computer = $ComputerPrevious }    
            $script:OverallDataResultsPrevious += $DataResultsPrevious
            $script:OverallDataResultsPrevious | ForEach-Object {$script:AutoChart.Series["Previous"].Points.AddXY($_.Computer,$_.ResultsCount)}        
        } 
    }

    $script:OverallDataResultsMostRecent = @()
    if (Test-Path $script:CSVFilePathMostRecent) {
        # If the Second field/Y Axis equals PSComputername, it counts it
        if ($PropertyY -eq "PSComputerName") {
            $DataSourceMostRecent = @()
            foreach ($UniqueHostMostRecent in $script:CsvUniqueHosts) { 
                $DataSourceMostRecent += $script:CsvFileCommonDataMostRecent | Where-Object { $_.PSComputerName -eq $UniqueHostMostRecent } 
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourceMostRecent += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $PropertyX -Unique

            # Important, gets a unique list for X and Y
            $UniqueDataFieldsMostRecent   = $DataSourceMostRecent | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $UniqueComputerListMostRecent = $DataSourceMostRecent | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
        
            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            foreach ($DataFieldMostRecent in $UniqueDataFieldsMostRecent) {
                $CountMostRecent          = 0
                $CsvComputersMostRecent   = @()
                foreach ( $LineMostRecent in $DataSourceMostRecent ) {
                    if ($($LineMostRecent.$PropertyX) -eq $($DataFieldMostRecent.$PropertyX)) {
                        $CountMostRecent += 1
                        if ( $CsvComputersMostRecent -notcontains $($LineMostRecent.$PropertyY) ) { $CsvComputersMostRecent += $($LineMostRecent.$PropertyY) }                        
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults 
                $UniqueCountMostRecent = $CsvComputersMostRecent.Count - 1 
                $DataResultsMostRecent = New-Object PSObject -Property @{
                    DataField   = $DataFieldMostRecent
                    TotalCount  = $CountMostRecent
                    UniqueCount = $UniqueCountMostRecent
                    Computers   = $CsvComputersMostRecent 
                }
                $script:OverallDataResultsMostRecent += $DataResultsMostRecent
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsMostRecent.count

            $script:OverallDataResultsMostRecent | Sort-Object -Property UniqueCount | ForEach-Object {
                $script:AutoChart.Series["Most Recent"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)    
                $script:AutoChartsProgressBar.Value += 1
            }
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($PropertyX -eq "PSComputerName") {        
            $DataSourceMostRecent = @()
            $DataSourceMostRecent = $script:CsvFileCommonDataMostRecent 

            $SelectedDataFieldMostRecent  = $DataSourceMostRecent | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
            $UniqueComputerListMostRecent = $DataSourceMostRecent | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $CurrentComputerMostRecent    = ''
            $CheckIfFirstLineMostRecent   = 'False'
            $ResultsCountMostRecent       = 0
            $ComputerMostRecent           = @()
            $YResultsMostRecent           = @()
            foreach ( $LineMostRecent in $DataSourceMostRecent ) {
                if ( $CheckIfFirstLineMostRecent -eq 'False' ) { $CurrentComputerMostRecent  = $LineMostRecent.$PropertyX ; $CheckIfFirstLineMostRecent = 'True' }
                if ( $CheckIfFirstLineMostRecent -eq 'True' ) { 
                    if ( $LineMostRecent.$PropertyX -eq $CurrentComputerMostRecent ) {
                        if ( $YResultsMostRecent -notcontains $LineMostRecent.$PropertyY ) {
                            if ( $LineMostRecent.$PropertyY -ne "" ) { $YResultsMostRecent += $LineMostRecent.$PropertyY ; $ResultsCountMostRecent += 1 }
                            if ( $ComputerMostRecent -notcontains $LineMostRecent.$PropertyX ) { $ComputerMostRecent = $LineMostRecent.$PropertyX }
                        }       
                    }
                    elseif ( $LineMostRecent.$PropertyX -ne $CurrentComputerMostRecent ) { 
                        $CurrentComputerMostRecent = $LineMostRecent.$PropertyX
                        $DataResultsMostRecent     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountMostRecent ; Computer = $ComputerMostRecent }
                        $script:OverallDataResultsMostRecent += $DataResultsMostRecent
                        $YResultsMostRecent        = @()
                        $ResultsCountMostRecent    = 0
                        $ComputerMostRecent        = @()
                        if ( $YResultsMostRecent -notcontains $LineMostRecent.$PropertyY ) {
                            if ( $LineMostRecent.$PropertyY -ne "" ) { $YResultsMostRecent += $LineMostRecent.$PropertyY ; $ResultsCountMostRecent += 1 }
                            if ( $ComputerMostRecent -notcontains $LineMostRecent.$PropertyX ) { $ComputerMostRecent = $LineMostRecent.$PropertyX }
                        }
                    }
                }
            }
            $DataResultsMostRecent = New-Object PSObject -Property @{ ResultsCount = $ResultsCountMostRecent ; Computer = $ComputerMostRecent }    
            $script:OverallDataResultsMostRecent += $DataResultsMostRecent
            $script:OverallDataResultsMostRecent | ForEach-Object {$script:AutoChart.Series["Most Recent"].Points.AddXY($_.Computer,$_.ResultsCount)}        
        }        
    } # END if ( $script:CSVFilePathMostRecent )

    Clear-Variable -Name MergedCSVDataResults

    ############################################################################################################
    # Auto Create Charts Processes
    ############################################################################################################
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $script:AutoChartsIndividualTab01         = New-Object System.Windows.Forms.TabPage
    $script:AutoChartsIndividualTab01.Text    = "$QueryTabName"
    $script:AutoChartsIndividualTab01.UseVisualStyleBackColor = $True
    $script:AutoChartsIndividualTab01.Anchor  = $AnchorAll
    $script:AutoChartsIndividualTab01.Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $AutoChartsTabControl.Controls.Add($script:AutoChartsIndividualTab01)            


    ### Auto Chart Panel that contains all the options to manage open/close feature 
    $script:AutoChartsOptionsButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Options v"
        Location  = @{ X = $script:AutoChart.Location.X + 10
                    Y = $script:AutoChart.Location.Y + $script:AutoChart.Size.Height - 29 }
        Size      = @{ Width  = 75
                    Height = 20 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsOptionsButton.Add_Click({  
        if ($script:AutoChartsOptionsButton.Text -eq 'Options v') {
            $script:AutoChartsOptionsButton.Text = 'Options ^'
            $script:AutoChart.Controls.Add($script:AutoChartsManipulationPanel)
        }
        elseif ($script:AutoChartsOptionsButton.Text -eq 'Options ^') {
            $script:AutoChartsOptionsButton.Text = 'Options v'
            $script:AutoChart.Controls.Remove($script:AutoChartsManipulationPanel)
        }
    })
    $script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartsOptionsButton)
    $script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart)

    $script:AutoChartsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
        Location    = @{ X = 0
                        Y = $script:AutoChart.Size.Height - 150 }
        Size        = @{ Width  = $script:AutoChart.Size.Width
                        Height = 150 }
        Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
        ForeColor   = 'Black'
        BackColor   = 'White'
        BorderStyle = 'FixedSingle'
    }


    #==============================================================================================================================
    # AutoCharts - Trim TrackBars
    #==============================================================================================================================
    #--------------------------------------
    # AutoCharts - Trim Off First GroupBox
    #--------------------------------------
    $script:AutoChartsTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text        = "Trim Off First: 0"
        Location    = @{ X = 10
                         Y = 5 }
        Size        = @{ Width  = 290
                         Height = 67}
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
        ForeColor   = 'Black'
    }
        #--------------------------------------
        # AutoCharts - Trim Off First TrackBar
        #--------------------------------------
        $script:AutoChartsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Location    = @{ X = 1
                             Y = 20 }
            Size        = @{ Width  = 285
                             Height = 22 }                
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
            Value         = 0 
        }
        $script:AutoChartsTrimOffFirstTrackBar.SetRange(0, $($script:OverallDataResultsMostRecent.count))             
        $script:AutoChartsTrimOffFirstTrackBarValue   = 0
        $script:AutoChartsTrimOffFirstTrackBar.add_ValueChanged({
            $script:AutoChartsTrimOffFirstTrackBarValue = $script:AutoChartsTrimOffFirstTrackBar.Value
            $script:AutoChartsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChartsTrimOffFirstTrackBar.Value)"
            if ( $script:CsvFileDataMostRecent ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Most Recent"].Points.Clear()
                    $script:OverallDataResultsMostRecent | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Most Recent"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Most Recent"].Points.Clear()
                    $script:OverallDataResultsMostRecent | ForEach-Object {$script:AutoChart.Series["Most Recent"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
            if ( $script:CsvFileDataPrevious ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Previous"].Points.Clear()
                    $script:OverallDataResultsPrevious | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Previous"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Previous"].Points.Clear()
                    $script:OverallDataResultsPrevious | ForEach-Object {$script:AutoChart.Series["Previous"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
            if ( $script:CsvFileDataBaseline ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Baseline"].Points.Clear()
                    $script:OverallDataResultsBaseline | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Baseline"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Baseline"].Points.Clear()
                    $script:OverallDataResultsBaseline | ForEach-Object {$script:AutoChart.Series["Baseline"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
        })
        $script:AutoChartsTrimOffFirstGroupBox.Controls.Add($script:AutoChartsTrimOffFirstTrackBar)
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTrimOffFirstGroupBox)


    #--------------------------------------
    # Auto Charts - Trim Off Last GroupBox
    #--------------------------------------
    $script:AutoChartsTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text        = "Trim Off Last: 0"
        Location    = @{ X = $script:AutoChartsTrimOffFirstGroupBox.Location.X + $script:AutoChartsTrimOffFirstGroupBox.Size.Width + 10
                         Y = $script:AutoChartsTrimOffFirstGroupBox.Location.Y }
        Size        = @{ Width  = 290
                         Height = 67 }
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
        ForeColor   = 'Black'
    }
        #-------------------------------------
        # AutoCharts - Trim Off Last TrackBar
        #-------------------------------------
        $script:AutoChartsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Location      = @{ X = 1
                               Y = 20 }
            Size          = @{ Width  = 285
                               Height = 22}                
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
        }
        $script:AutoChartsTrimOffLastTrackBar.RightToLeft   = $true
        $script:AutoChartsTrimOffLastTrackBar.SetRange(0, $($script:OverallDataResultsMostRecent.count))
        $script:AutoChartsTrimOffLastTrackBar.Value = $($script:OverallDataResultsMostRecent.count)
        $script:AutoChartsTrimOffLastTrackBarValue   = 0
        $script:AutoChartsTrimOffLastTrackBar.add_ValueChanged({
            $script:AutoChartsTrimOffLastTrackBarValue = $($script:OverallDataResultsMostRecent.count) - $script:AutoChartsTrimOffLastTrackBar.Value
            $script:AutoChartsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:OverallDataResultsMostRecent.count) - $script:AutoChartsTrimOffLastTrackBar.Value)"
            if ( $script:CsvFileDataMostRecent ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Most Recent"].Points.Clear()
                    $script:OverallDataResultsMostRecent | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Most Recent"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Most Recent"].Points.Clear()
                    $script:OverallDataResultsMostRecent | ForEach-Object {$script:AutoChart.Series["Most Recent"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
            if ( $script:CsvFileDataPrevious ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Previous"].Points.Clear()
                    $script:OverallDataResultsPrevious | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Previous"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Previous"].Points.Clear()
                    $script:OverallDataResultsPrevious | ForEach-Object {$script:AutoChart.Series["Previous"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
            if ( $script:CsvFileDataBaseline ) {
                if ($PropertyY -eq "PSComputerName") {
                    $script:AutoChart.Series["Baseline"].Points.Clear()
                    $script:OverallDataResultsBaseline | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series["Baseline"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
                }
                elseif ($PropertyX -eq "PSComputerName") {   
                    $script:AutoChart.Series["Baseline"].Points.Clear()
                    $script:OverallDataResultsBaseline | ForEach-Object {$script:AutoChart.Series["Baseline"].Points.AddXY($_.Computer,$_.ResultsCount)}        
                }
            }
        })
        $script:AutoChartsTrimOffLastGroupBox.Controls.Add($script:AutoChartsTrimOffLastTrackBar)
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTrimOffLastGroupBox)


    #----------------------------------
    # Auto Charts - Title Name Textbox
    #----------------------------------
    $script:AutoChartsTitleNameTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Location    = @{ X = $script:AutoChartsTrimOffFirstGroupBox.Location.X
                         Y = $script:AutoChartsTrimOffFirstGroupBox.Location.Y + $script:AutoChartsTrimOffFirstGroupBox.Size.Height + 6 }
        Size        = @{ Width  = $script:AutoChartsTrimOffFirstGroupBox.Size.Width
                         Height = 62 }
        Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
        ForeColor   = 'Black'
        BackColor   = 'White'
        Multiline   = $true
        WordWrap    = $False
        BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTitleNameTextbox)
    $script:AutoChartsTitleNameTextbox.Text = ($script:CSVFilePathMostRecent.split('\'))[-1] -replace '.csv',''
    $script:AutoChartsTitleNameTextbox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { 
        $script:AutoChartTitle.Text = $script:AutoChartsTitleNameTextbox.Text  
    }})
        

    #------------------------------
    # Auto Charts - Notice Textbox
    #------------------------------
    $script:AutoChartsNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Location    = @{ X = $script:AutoChartsTrimOffLastGroupBox.Location.X
                         Y = $script:AutoChartsTrimOffLastGroupBox.Location.Y + $script:AutoChartsTrimOffLastGroupBox.Size.Height + 6 }
        Size        = @{ Width  = $script:AutoChartsTrimOffLastGroupBox.Size.Width - 1
                         Height = 62 }
#        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
        ForeColor   = 'Black'
        BackColor   = "White"
        Text        = "- Total Hosts In Series:      $(($script:CsvAllHosts | Sort-Object -Unique).Count)`r`n- Common Hosts Displayed:     $(($Script:MergedCSVUniquePropertyDataResults | Select-Object -ExpandProperty PSComputerName -Unique).Count)`r`n- Hosts Not Displayed:        $((($script:CsvAllHosts | Sort-Object -Unique).Count) - $(($Script:MergedCSVUniquePropertyDataResults | Select-Object -ExpandProperty PSComputerName -Unique).Count))`r`n- Number Of Unique Values:    $($script:OverallDataResultsMostRecent.count)"
        Multiline   = $true
        BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
        Enabled     = $False
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsNoticeTextbox)

    
    #==============================================================================================================================
    # AutoCharts - Investigate Difference
    #==============================================================================================================================
    function script:Investigate-CsvFileData ($ImportCsvFileData) {
        function InvestigateDifference-AutoChart {    
            # Clears out data
            $AutoChartsInvestigateDifferencePositiveResultsTextBox.Text = ""
            $AutoChartsInvestigateDifferenceNegativeResultsTextBox.Text = ""
    
            # List of Positive Endpoints that positively match
            $AutoChartsImportCsvPositiveResultsEndpoints = $AutoChartsInvestigateDifferenceImportCsv | Where-Object Name -eq $($AutoChartsInvestigateDifferenceDropDownComboBox.Text) | Select-Object -ExpandProperty PSComputerName -Unique

            #if using .listbox# ForEach ($Endpoint in $AutoChartsImportCsvPositiveResultsEndpoints) { $AutoChartsInvestigateDifferencePositiveResultsTextBox.Items.Add($Endpoint) }
            ForEach ($Endpoint in $AutoChartsImportCsvPositiveResultsEndpoints) { $AutoChartsInvestigateDifferencePositiveResultsTextBox.Text += "$Endpoint`r`n" }
    
            # List of all endpoints within the csv file
            $AutoChartsImportCsvAllEndpointsList = $AutoChartsInvestigateDifferenceImportCsv | Select-Object -ExpandProperty PSComputerName -Unique
            
            $AutoChartsImportCsvNegativeResults = @()
            # Creates a list of Endpoints with Negative Results
            foreach ($Endpoint in $AutoChartsImportCsvAllEndpointsList) {
                if ($Endpoint -notin $AutoChartsImportCsvPositiveResultsEndpoints) { $AutoChartsImportCsvNegativeResults += $Endpoint }
            }
            # Populates the listbox with Negative Endpoint Results
            #if useing .listbox# ForEach ($Endpoint in $AutoChartsImportCsvNegativeResults) { $AutoChartsInvestigateDifferenceNegativeResultsTextBox.Items.Add($Endpoint) }
            ForEach ($Endpoint in $AutoChartsImportCsvNegativeResults) { $AutoChartsInvestigateDifferenceNegativeResultsTextBox.Text += "$Endpoint`r`n" }
        
            # Updates the label to include the count
            $AutoChartsInvestigateDifferencePositiveResultsLabel.Text = "Positive Match ($($AutoChartsImportCsvPositiveResultsEndpoints.count))"
            $AutoChartsInvestigateDifferenceNegativeResultsLabel.Text = "Negative Match ($($AutoChartsImportCsvNegativeResults.count))"
        }
    
        $AutoChartsInvestigateDifferenceImportCsv = Import-Csv $ImportCsvFileData
        #$AutoChartsInvestigateDifferenceDropDownArray = $AutoChartsInvestigateDifferenceImportCsv | Select-Object -Property Name -ExpandProperty Name | Sort-Object -Unique | Select-Object -Skip $script:AutoChartsTrimOffFirstTrackBarValue | Select -SkipLast $script:AutoChartsTrimOffLastTrackBarValue
        $AutoChartsInvestigateDifferenceDropDownArray = $AutoChartsInvestigateDifferenceImportCsv | Select-Object -Property Name -ExpandProperty Name | Sort-Object -Unique

        #-----------------------------------------------
        # Investigate Difference Compare Csv Files Form
        #-----------------------------------------------
        $AutoChartsInvestigateDifferenceForm = New-Object System.Windows.Forms.Form -Property @{
            Text   = "Investigate Difference"
            Size   = @{ Width  = 330
                        Height = 360 }
            Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
            StartPosition = "CenterScreen"
            ControlBox = $true
        }
        #---------------------------------------------------
        # Investigate Difference Drop Down Label & ComboBox
        #---------------------------------------------------
        $AutoChartsInvestigateDifferenceDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Investigate the difference between computers."
            Location = @{ X = 10
                            Y = 5 }
            Size     = @{ Width  = 290
                            Height = 45 }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $AutoChartsInvestigateDifferenceDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Location = @{ X = 10
                            Y = $AutoChartsInvestigateDifferenceDropDownLabel.Location.y + $AutoChartsInvestigateDifferenceDropDownLabel.Size.Height }
            Width    = 290
            Height   = 30
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        }
        ForEach ($Item in $AutoChartsInvestigateDifferenceDropDownArray) { $AutoChartsInvestigateDifferenceDropDownComboBox.Items.Add($Item) }
        $AutoChartsInvestigateDifferenceDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { InvestigateDifference-AutoChart }})
        $AutoChartsInvestigateDifferenceDropDownComboBox.Add_Click({ InvestigateDifference-AutoChart })
        $AutoChartsInvestigateDifferenceForm.Controls.AddRange(@($AutoChartsInvestigateDifferenceDropDownLabel,$AutoChartsInvestigateDifferenceDropDownComboBox))

        #---------------------------------------
        # Investigate Difference Execute Button
        #---------------------------------------
        $AutoChartsInvestigateDifferenceExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = 10
                            Y = $AutoChartsInvestigateDifferenceDropDownComboBox.Location.y + $AutoChartsInvestigateDifferenceDropDownComboBox.Size.Height + 10 }
            Width    = 100 
            Height   = 20
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
            UseVisualStyleBackColor = $True
        }
        $AutoChartsInvestigateDifferenceExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { InvestigateDifference-AutoChart }})
        $AutoChartsInvestigateDifferenceExecuteButton.Add_Click({ InvestigateDifference-AutoChart })
        $AutoChartsInvestigateDifferenceForm.Controls.Add($AutoChartsInvestigateDifferenceExecuteButton)   

        #---------------------------------------------------------
        # Investigate Difference Positive Results Label & TextBox
        #---------------------------------------------------------
        $AutoChartsInvestigateDifferencePositiveResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text       = "Positive Match (+)"
            Location   = @{ X = 10
                            Y = $AutoChartsInvestigateDifferenceExecuteButton.Location.y + $AutoChartsInvestigateDifferenceExecuteButton.Size.Height + 10 }
            Size       = @{ Width  = 140
                            Height = 22 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }        
        $AutoChartsInvestigateDifferencePositiveResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location   = @{ X = 10
                            Y = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.y + $AutoChartsInvestigateDifferencePositiveResultsLabel.Size.Height }
            Size       = @{ Width  = 140
                            Height = 178 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ReadOnly   = $true
            BackColor  = 'White'
            WordWrap   = $false
            Multiline  = $true
            ScrollBars = "Vertical"
        }
        $AutoChartsInvestigateDifferenceForm.Controls.AddRange(@($AutoChartsInvestigateDifferencePositiveResultsLabel,$AutoChartsInvestigateDifferencePositiveResultsTextBox))
        #---------------------------------------------------------
        # Investigate Difference Negative Results Label & TextBox
        #---------------------------------------------------------
        $AutoChartsInvestigateDifferenceNegativeResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text       = "Negative Match (-)"
            Location   = @{ X = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.x + $AutoChartsInvestigateDifferencePositiveResultsLabel.Size.Width + 10
                            Y = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.y }
            Size       = @{ Width  = 140
                            Height = 22 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $AutoChartsInvestigateDifferenceForm.Controls.Add($AutoChartsInvestigateDifferenceNegativeResultsLabel)

        $AutoChartsInvestigateDifferenceNegativeResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location   = @{ X = $AutoChartsInvestigateDifferenceNegativeResultsLabel.Location.x
                            Y = $AutoChartsInvestigateDifferenceNegativeResultsLabel.Location.y + $AutoChartsInvestigateDifferenceNegativeResultsLabel.Size.Height }
            Size       = @{ Width  = 140
                            Height = 178 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ReadOnly   = $true
            BackColor  = 'White'
            WordWrap   = $false
            Multiline  = $true
            ScrollBars = "Vertical"
        }
        $AutoChartsInvestigateDifferenceForm.Controls.Add($AutoChartsInvestigateDifferenceNegativeResultsTextBox)
        $AutoChartsInvestigateDifferenceForm.ShowDialog()
    }


    #==================================================================================================================
    #==================================================================================================================
    # Auto Chart - Display Title Checkbox
    #==================================================================================================================
    #==================================================================================================================
    $script:AutoChartsTitleCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = 'Display Title'
        Location  = @{ X = $script:AutoChartsTrimOffLastGroupBox.Location.X + $script:AutoChartsTrimOffLastGroupBox.Size.Width + 6
                      Y = $script:AutoChartsTrimOffLastGroupBox.Location.Y + 2 }
        Size      = @{ Width  = 125
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Checked   = $true
    }
    $script:AutoChartsTitleCheckBox.Add_Click({
        if   ( $script:AutoChartsTitleCheckBox.Checked ) { $script:AutoChart.Titles.Add($script:AutoChartTitle) }
        else { $script:AutoChart.Titles.Remove($script:AutoChartTitle) }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTitleCheckBox)


    #================================
    # Auto Create Charts Save Button
    #================================
    $script:AutoChartsSaveChartImageButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Save Image"
        Location  = @{ X = $script:AutoChartsTitleCheckBox.Location.X + $script:AutoChartsTitleCheckBox.Size.Width + 6  
                       Y = $script:AutoChartsTitleCheckBox.Location.Y }
        Size      = @{ Width = 100
                       Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsSaveChartImageButton.Add_Click({
        $Result = script:Invoke-SaveChartAsImage
        If ($Result) { $script:AutoChart.SaveImage($Result.FileName, $Result.Extension) }
    })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsSaveChartImageButton)


    #=======================================
    # Auto Create Charts Select Chart Label
    #=======================================
    $script:AutoChartsChartTypeFilterLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = 'Category Filter -->' 
        Location = @{ X = $script:AutoChartsSaveChartImageButton.Location.X + $script:AutoChartsSaveChartImageButton.Size.Width + 6 
                      Y = $script:AutoChartsSaveChartImageButton.Location.Y + 4 }
        Size      = @{ Width  = 100
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeFilterLabel)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeFilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column' 
        Location = @{ X = $script:AutoChartsChartTypeFilterLabel.Location.X + $script:AutoChartsChartTypeFilterLabel.Size.Width + 6 
                      Y = $script:AutoChartsChartTypeFilterLabel.Location.Y - 4 }
        Size      = @{ Width  = 75
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesFilterAvailable = @('Column','Bar','Pie','Doughnut','Radar','Polar','Funnel','Pyramid')
    ForEach ($Item in $script:AutoChartsChartTypesFilterAvailable) { $script:AutoChartsChartTypeFilterComboBox.Items.Add($Item) }

    $script:AutoChartsChartTypeFilterComboBox.add_SelectedIndexChanged({
        function Update-AvailableCharts ($AvailableCharts) {
            $script:AutoChart.Series["Most Recent"].ChartType = $false
            $script:AutoChart.Series["Previous"].ChartType    = $false
            $script:AutoChart.Series["Baseline"].ChartType    = $false
            $script:AutoChartsChartTypeMostRecentComboBox.Items.Clear()
            $script:AutoChartsChartTypePreviousComboBox.Items.Clear()
            $script:AutoChartsChartTypeBaselineComboBox.Items.Clear()

            $script:AutoChart.Series["Most Recent"].ChartType = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChart.Series["Previous"].ChartType    = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChart.Series["Baseline"].ChartType    = $script:AutoChartsChartTypeFilterComboBox.SelectedItem

            $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypePreviousComboBox.Text   = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypeBaselineComboBox.Text   = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypeComboBox.Text           = 'None'

            if ($script:AutoChart.Series["Most Recent"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Most Recent"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Most Recent"].BorderWidth = 1 }
            else { $script:AutoChart.Series["Most Recent"].BorderWidth = 5 }
            if ($script:AutoChart.Series["Previous"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Previous"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Previous"].BorderWidth = 1 }
            else { $script:AutoChart.Series["Previous"].BorderWidth = 5 }
            if ($script:AutoChart.Series["Baseline"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Baseline"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Baseline"].BorderWidth = 1 }
            else { $script:AutoChart.Series["Baseline"].BorderWidth = 5 }

            #batman
            ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeMostRecentComboBox.Items.Add($Item) }
            ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypePreviousComboBox.Items.Add($Item) }
            ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeBaselineComboBox.Items.Add($Item) }
        }
        if ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Column' ) {
            $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Bar' ) {
            $script:AutoChartsChartTypesAvailable = @('Bar','Rangebar','StackedBar')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Pie' ) {
            $script:AutoChartsChartTypesAvailable = @('Pie')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Doughnut' ) {
            $script:AutoChartsChartTypesAvailable = @('Doughnut')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Radar' ) {
            $script:AutoChartsChartTypesAvailable = @('Radar')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Polar' ) {
            $script:AutoChartsChartTypesAvailable = @('Polar')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Funnel' ) {
            $script:AutoChartsChartTypesAvailable = @('Funnel')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
        elseif ( $script:AutoChartsChartTypeFilterComboBox.SelectedItem -eq 'Pyramid' ) {
            $script:AutoChartsChartTypesAvailable = @('Pyramid')
            Update-AvailableCharts -AvailableCharts $script:AutoChartsChartTypesAvailable
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeFilterComboBox)


    #==================================================================================================================
    #==================================================================================================================
    # Auto Chart - Display Most Recent Series Checkbox
    #==================================================================================================================
    #==================================================================================================================
    $script:AutoChartsDisplayMostRecentSeriesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = 'Most Recent Series'
        Location  = @{ X = $script:AutoChartsTitleCheckBox.Location.X
                       Y = $script:AutoChartsTitleCheckBox.Location.Y + $script:AutoChartsTitleCheckBox.Size.Height + 6 }
        Size      = @{ Width  = 125
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
        Checked   = $true
    }
    $script:AutoChartsDisplayMostRecentSeriesCheckBox.Add_Click({
        if ( $script:AutoChart.Series["Most Recent"].Enabled -eq $True ) {
            $script:AutoChart.Series.Remove("Most Recent")
            $script:AutoChart.Series["Most Recent"].Enabled = $False
            $script:AutoChartsDisplayMostRecentSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChart.Series.Add("Most Recent")
            $script:AutoChart.Series["Most Recent"].Enabled = $True
            $script:AutoChartsDisplayMostRecentSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayMostRecentSeriesCheckBox)


    #==========================================
    # Auto Create - Most Recent Results Button
    #==========================================
    $script:AutoChartsResultsMostRecentButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location  = @{ X = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.X + $script:AutoChartsDisplayMostRecentSeriesCheckBox.Size.Width + 6
                       Y = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.Y }
        Size      = @{ Width  = 100
                       Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsResultsMostRecentButton.Add_Click({ Import-CSV $script:CSVFilePathMostRecent | Out-GridView -Title "$script:CSVFilePathMostRecent" }) 
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsMostRecentButton)

    # Autosaves the chart if checked
    $FileName = ($script:CSVFilePathMostRecent).split('\')[-1]
    $FileDate = ($script:CSVFilePathMostRecent).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }
    

    #=====================================
    # Auto Create Investigate Most Recent
    #=====================================
    $script:AutoChartsInvestigateMostRecentButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location = @{ X = $script:AutoChartsResultsMostRecentButton.Location.X + $script:AutoChartsResultsMostRecentButton.Size.Width + 6 
                      Y = $script:AutoChartsResultsMostRecentButton.Location.Y}
        Size      = @{ Width  = 100
                       Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsInvestigateMostRecentButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathMostRecent
    })
    $script:AutoChartsInvestigateMostRecentButton.Add_MouseHover({
    ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigateMostRecentButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeMostRecentComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column' 
        Location = @{ X = $script:AutoChartsInvestigateMostRecentButton.Location.X + $script:AutoChartsInvestigateMostRecentButton.Size.Width + 6 
                      Y = $script:AutoChartsInvestigateMostRecentButton.Location.Y }
        Size      = @{ Width  = 75
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeMostRecentComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypeMostRecentComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Most Recent"].ChartType  = $script:AutoChartsChartTypeMostRecentComboBox.SelectedItem
        $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeMostRecentComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeMostRecentComboBox)

    
    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorMostRecentComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Blue"
        Location = @{ X = $script:AutoChartsChartTypeMostRecentComboBox.Location.X + $script:AutoChartsChartTypeMostRecentComboBox.Size.Width + 6 
                      Y = $script:AutoChartsChartTypeMostRecentComboBox.Location.Y}
        Size      = @{ Width  = 75
                       Height = 20 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailableMostRecent = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailableMostRecent) { $script:AutoChartsChangeColorMostRecentComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorMostRecentComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Most Recent"].Color               = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChart.Series["Most Recent"].MarkerColor         = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsDisplayMostRecentSeriesCheckBox.ForeColor = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsDisplayMostRecentMarkerCheckBox.ForeColor = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsResultsMostRecentButton.ForeColor         = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsInvestigateMostRecentButton.ForeColor     = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsChartTypeMostRecentComboBox.ForeColor     = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartsChangeColorMostRecentComboBox.ForeColor   = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChangeColorMostRecentComboBox)


    #==================================================================================================================
    #==================================================================================================================
    # Auto Chart - Display Previous Series Checkbox
    #==================================================================================================================
    #==================================================================================================================
    $script:AutoChartsDisplayPreviousSeriesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = 'Previous Series'
        Location = @{ X = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.X 
                      Y = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.Y + $script:AutoChartsDisplayMostRecentSeriesCheckBox.Size.Height + 6 }
        Size      = @{ Width  = 125
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
        Checked   = $true
    }
    $script:AutoChartsDisplayPreviousSeriesCheckBox.Add_Click({
        if ( $script:AutoChart.Series["Previous"].Enabled -eq $True ) {
            $script:AutoChart.Series.Remove("Previous")
            $script:AutoChart.Series["Previous"].Enabled = $False
            $script:AutoChartsDisplayPreviousSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChart.Series.Add("Previous")
            $script:AutoChart.Series["Previous"].Enabled = $True
            $script:AutoChartsDisplayPreviousSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayPreviousSeriesCheckBox)


    #=======================================
    # Auto Create - Previous Results Button
    #=======================================
    $script:AutoChartsResultsPreviousButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location = @{ X = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.X + $script:AutoChartsDisplayPreviousSeriesCheckBox.Size.Width + 6 
                      Y = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.Y }
        Size     = @{ Width  = 100
                      Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsResultsPreviousButton.Add_Click({ Import-CSV $script:CSVFilePathPrevious | Out-GridView -Title "$script:CSVFilePathPrevious" }) 
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsPreviousButton)

    # Autosaves the chart if checked
    $FileName           = ($script:CSVFilePathPrevious).split('\')[-1]
    $FileDate           = ($script:CSVFilePathPrevious).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }
    

    #=====================================
    # Auto Create Investigate Most Recent
    #=====================================
    $script:AutoChartsInvestigatePreviousButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location = @{ X = $script:AutoChartsResultsPreviousButton.Location.X + $script:AutoChartsResultsPreviousButton.Size.Width + 6 
                      Y = $script:AutoChartsResultsPreviousButton.Location.Y}
        Size      = @{ Width  = 100
                       Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsInvestigatePreviousButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathPrevious
    })
    $script:AutoChartsInvestigatePreviousButton.Add_MouseHover({
    ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigatePreviousButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypePreviousComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Point'
        Location = @{ X = $script:AutoChartsInvestigatePreviousButton.Location.X + $script:AutoChartsInvestigatePreviousButton.Size.Width + 6 
                      Y = $script:AutoChartsInvestigatePreviousButton.Location.Y }
        Size      = @{ Width  = 75
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypePreviousComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypePreviousComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Most Recent"].ChartType  = $script:AutoChartsChartTypePreviousComboBox.SelectedItem
        $script:AutoChartsChartTypePreviousComboBox.Text = $script:AutoChartsChartTypePreviousComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypePreviousComboBox)


    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorPreviousComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Red"
        Location = @{ X = $script:AutoChartsChartTypePreviousComboBox.Location.X + $script:AutoChartsChartTypePreviousComboBox.Size.Width + 6 
                      Y = $script:AutoChartsChartTypePreviousComboBox.Location.Y}
        Size      = @{ Width  = 75
                       Height = 20 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailablePrevious = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailablePrevious) { $script:AutoChartsChangeColorPreviousComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorPreviousComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Previous"].Color                = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChart.Series["Previous"].MarkerColor          = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsDisplayPreviousSeriesCheckBox.ForeColor = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsDisplayPreviousMarkerCheckBox.ForeColor = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsResultsPreviousButton.ForeColor         = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsInvestigatePreviousButton.ForeColor     = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsChartTypePreviousComboBox.ForeColor     = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartsChangeColorPreviousComboBox.ForeColor   = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChangeColorPreviousComboBox)


    #==================================================================================================================
    #==================================================================================================================
    # Auto Chart - Display Baseline Series Checkbox
    #==================================================================================================================
    #==================================================================================================================
    $script:AutoChartsDisplayBaselineSeriesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = 'Baseline Series'
        Location = @{ X = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.X 
                      Y = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.Y + $script:AutoChartsDisplayPreviousSeriesCheckBox.Size.Height + 6 }
        Size      = @{ Width  = 125
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Orange"
        Checked   = $true
    }
    $script:AutoChartsDisplayBaselineSeriesCheckBox.Add_Click({
        if ( $script:AutoChart.Series["Baseline"].Enabled -eq $True ) {
            $script:AutoChart.Series.Remove("Baseline")
            $script:AutoChart.Series["Baseline"].Enabled = $False
            $script:AutoChartsDisplayBaselineSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChart.Series.Add("Baseline")
            $script:AutoChart.Series["Baseline"].Enabled = $True
            $script:AutoChartsDisplayBaselineSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayBaselineSeriesCheckBox)


    #=======================================
    # Auto Create - Baseline Results Button
    #=======================================
    $script:AutoChartsResultsBaselineButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location = @{ X = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.X + $script:AutoChartsDisplayBaselineSeriesCheckBox.Size.Width + 6 
                      Y = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.Y }
        Size     = @{ Width  = 100
                      Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Orange"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsResultsBaselineButton.Add_Click({ Import-CSV $script:CSVFilePathBaseline | Out-GridView -Title "$script:CSVFilePathBaseline" }) 
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsBaselineButton)

    # Autosaves the chart if checked
    $FileName           = ($script:CSVFilePathBaseline).split('\')[-1]
    $FileDate           = ($script:CSVFilePathBaseline).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }


    #==================================
    # Auto Create Investigate Baseline
    #==================================
    $script:AutoChartsInvestigateBaselineButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location  = @{ X = $script:AutoChartsResultsBaselineButton.Location.X + $script:AutoChartsResultsBaselineButton.Size.Width + 6
                       Y = $script:AutoChartsResultsBaselineButton.Location.Y }
        Size      = @{ Width  = 100
                       Height = 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Orange"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoChartsInvestigateBaselineButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathBaseline
    })
    $script:AutoChartsInvestigateBaselineButton.Add_MouseHover({
    ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigateBaselineButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeBaselineComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Point' 
        Location = @{ X = $script:AutoChartsInvestigateBaselineButton.Location.X + $script:AutoChartsInvestigateBaselineButton.Size.Width + 6 
                      Y = $script:AutoChartsInvestigateBaselineButton.Location.Y }
        Size      = @{ Width  = 75
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Orange"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeBaselineComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypeBaselineComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Baseline"].ChartType  = $script:AutoChartsChartTypeBaselineComboBox.SelectedItem
        $script:AutoChartsChartTypeBaselineComboBox.Text = $script:AutoChartsChartTypeBaselineComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeBaselineComboBox)


    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorBaselineComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Orange"
        Location = @{ X = $script:AutoChartsChartTypeBaselineComboBox.Location.X + $script:AutoChartsChartTypeBaselineComboBox.Size.Width + 6 
                      Y = $script:AutoChartsChartTypeBaselineComboBox.Location.Y}
        Size      = @{ Width  = 75
                       Height = 20 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Orange"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailableBaseline = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailableBaseline) { $script:AutoChartsChangeColorBaselineComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorBaselineComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Baseline"].Color                = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChart.Series["Baseline"].MarkerColor          = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsDisplayBaselineSeriesCheckBox.ForeColor = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsDisplayBaselineMarkerCheckBox.ForeColor = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsResultsBaselineButton.ForeColor         = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsInvestigateBaselineButton.ForeColor     = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsChartTypeBaselineComboBox.ForeColor     = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartsChangeColorBaselineComboBox.ForeColor   = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChangeColorBaselineComboBox)


    #==================================================================================================================
    #==================================================================================================================
    # Auto Chart - Display Legend Checkbox
    #==================================================================================================================
    #==================================================================================================================
    $script:AutoChartsLegendCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = 'Display Legend' 
        Location  = @{ X = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.X 
                       Y = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.Y + $script:AutoChartsDisplayBaselineSeriesCheckBox.Size.Height + 6 }
        Size      = @{ Width  = 125
                       Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Checked   = $true
    }
    $script:AutoChartsLegendCheckBox.Add_Click({
        if   ( $script:AutoChartsLegendCheckBox.Checked ) { $script:Legend.Enabled = $true }
        else { $script:Legend.Enabled = $false }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsLegendCheckBox)


    #=======================================
    # Auto Create Charts Select Chart Label
    #=======================================
    $script:AutoChartsChartTypeApplyAllLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = 'Apply To All -->' 
        Location = @{ X = $script:AutoChartsInvestigateBaselineButton.Location.X
                      Y = $script:AutoChartsInvestigateBaselineButton.Location.Y + $script:AutoChartsInvestigateBaselineButton.Size.Height + 6 + 2 }
        Size     = @{ Width  = 100
                      Height = 22 }     
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeApplyAllLabel)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column' 
        Location = @{ X = $script:AutoChartsChartTypeBaselineComboBox.Location.X
                        Y = $script:AutoChartsChartTypeBaselineComboBox.Location.Y + $script:AutoChartsChartTypeBaselineComboBox.Size.Height + 6 }
        Size      = @{ Width  = 75
                        Height = 22 }     
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypeComboBox.add_SelectedIndexChanged({
        $script:AutoChart.Series["Most Recent"].ChartType = $false
        $script:AutoChart.Series["Previous"].ChartType    = $false
        $script:AutoChart.Series["Baseline"].ChartType    = $false
        $script:AutoChart.Series["Most Recent"].ChartType = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChart.Series["Previous"].ChartType    = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChart.Series["Baseline"].ChartType    = $script:AutoChartsChartTypeComboBox.SelectedItem

        $script:AutoChartsChartTypeFilterComboBox.Text     = 'None'
        $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartsChartTypePreviousComboBox.Text   = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartsChartTypeBaselineComboBox.Text   = $script:AutoChartsChartTypeComboBox.SelectedItem

        if ($script:AutoChart.Series["Most Recent"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Most Recent"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Most Recent"].BorderWidth = 1 }
        else { $script:AutoChart.Series["Most Recent"].BorderWidth = 5 }
        if ($script:AutoChart.Series["Previous"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Previous"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Previous"].BorderWidth = 1 }
        else { $script:AutoChart.Series["Previous"].BorderWidth = 5 }
        if ($script:AutoChart.Series["Baseline"].ChartType -eq 'Pie' -or $script:AutoChart.Series["Baseline"].ChartType -eq 'Doughnut') { $script:AutoChart.Series["Baseline"].BorderWidth = 1 }
        else { $script:AutoChart.Series["Baseline"].BorderWidth = 5 }
    })
    $script:AutoChartsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Point','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeComboBox.Items.Add($Item) }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeComboBox)


    #====================================================
    # Auto Charts Toggle 3D on/off and inclination angle
    #====================================================
    $script:AutoCharts3DToggleButton = New-Object Windows.Forms.Button -Property @{
        Text      = "3D Off"
        Location  = @{ X = $script:AutoChartsResultsBaselineButton.Location.X
                        Y = $script:AutoChartsResultsBaselineButton.Location.Y + $script:AutoChartsResultsBaselineButton.Size.Height + 6 }
        Size      = @{ Width  = $script:AutoChartsResultsBaselineButton.Size.Width
                        Height = 22 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        BackColor = "LightGray"
        UseVisualStyleBackColor = $True
    }
    $script:AutoCharts3DInclination = 0
    $script:AutoCharts3DToggleButton.Add_Click({            
        $script:AutoCharts3DInclination += 10
        if ( $script:AutoCharts3DToggleButton.Text -eq "3D Off" ) { 
            $script:AutoChartsArea.Area3DStyle.Enable3D    = $true
            $script:AutoChartsArea.Area3DStyle.Inclination = $script:AutoCharts3DInclination
            $script:AutoCharts3DToggleButton.Text  = "3D On ($script:AutoCharts3DInclination)"
        }
        elseif ( $script:AutoCharts3DInclination -le 90 ) {
            $script:AutoChartsArea.Area3DStyle.Inclination = $script:AutoCharts3DInclination
            $script:AutoCharts3DToggleButton.Text  = "3D On ($script:AutoCharts3DInclination)" 
        }
        else { 
            $script:AutoCharts3DToggleButton.Text  = "3D Off" 
            $script:AutoCharts3DInclination = 0
            $script:AutoChartsArea.Area3DStyle.Inclination = $script:AutoCharts3DInclination
            $script:AutoChartsArea.Area3DStyle.Enable3D    = $false
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoCharts3DToggleButton)


    # Launches the form
    $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
    [void]$script:AutoChartsForm.ShowDialog()
}
