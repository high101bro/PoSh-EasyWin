# Auto Create Charts Command Function
function Generate-AutoChartsCommand {
    param (
        $QueryName,
        $QueryTabName,
        $PropertyX,
        $PropertyY,
        $FilePath
    )

    $script:PropertyX = $PropertyX
    $script:PropertyY = $PropertyY

    # Name of Collected Data Directory
    $CollectedDataDirectory                 = "$PoShHome\Collected Data"

    # Location of separate queries
    $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"

    # Location of Uncompiled Results
    $script:IndividualHostResults           = "$script:CollectedDataTimeStampDirectory\Results By Endpoints"

    # Removes a tab if it already exists... Since the same variable is used when spawning multi-series tabs whenever multiple tabs are created, the previous ones break and are unable to close
    $AutoChartsTabControl.Controls.Remove($script:AutoChartsIndividualTabPage)

    if ($FilePath) {
        # If a filepath is provided it will select only that file and those 'younger' than it (derived by filename not file age)

        # This is the directory name of the file selected
        $FilePathDirSelected = $( (($script:AutoChartDataSourceCsvProcessesFileName | Split-Path).split('\'))[-1] )

        $inc = 0
        foreach ($dir in (gci -Path $CollectedDataDirectory)) {
            $inc++
            if ("$($dir.Name)" -match $FilePathDirSelected ) { break }
        }
        #$ListOfCollectedDataDirectories = gci -Path $FilePath | Select -First (++$inc) | Where-Object Extension -eq '.csv'
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory | Select -First $inc ).FullName

    }
    else {
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
    }


    # Filter results for just WMI Collections
    if ( $AutoChartsWmiCollectionsCheckBox.Checked ) {
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $script:CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName | Where {$_ -match 'WMI'}
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $script:CSVFileMatch += $CSVFile } }
        }
    }
    # Filter results for other than WMI Collections
    elseif ( $AutoChartsPoShCollectionsCheckBox.Checked ) {
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $script:CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName | Where {$_ -notmatch 'WMI'}
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $script:CSVFileMatch += $CSVFile } }
        }
    }
    # Don't filter results
    else {
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $script:CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
            foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match $QueryName) { $script:CSVFileMatch += $CSVFile } }
        }
    }

    # Checkes if the Appropriate Checkbox is selected, if so it selects the very first, previous, and most recent collections respectively
    # Each below will be the filename/path for their respective collection: baseline, previous, and most recent
    $script:CSVFilePathBaseline   = $script:CSVFileMatch | Select-Object -First 1
    $script:CSVFilePathPrevious   = $script:CSVFileMatch | Select-Object -Last 2 | Select-Object -First 1
    $script:CSVFilePathMostRecent = $script:CSVFileMatch | Select-Object -Last 1

    # Checks if the files selected are identicle, removing series as necessary that are to prevent erroneous double data
    if ($script:CSVFilePathMostRecent -eq $script:CSVFilePathPrevious) {$script:CSVFilePathPrevious = $null}
    if ($script:CSVFilePathMostRecent -eq $script:CSVFilePathBaseline) {$script:CSVFilePathBaseline = $null}
    if ($script:CSVFilePathPrevious   -eq $script:CSVFilePathBaseline) {$script:CSVFilePathPrevious = $null}


    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization


    #--------------------------
    # Auto Create Charts Object
    #--------------------------
    . "$Dependencies\Code\System.Windows.Forms\DataVisualization\Charting\AutoChartCharting.ps1"
    Clear-Variable -Name AutoChart -Scope script
    $script:AutoChartCharting = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
        Width           = $FormScale * 1115
        Height          = $FormScale * 552
        Left            = $FormScale * 5
        Top             = $FormScale * 7
        BackColor       = [System.Drawing.Color]::White
        BorderColor     = 'Black'
        BorderDashStyle = 'Solid'
        Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif',$($FormScale * 18), [System.Drawing.FontStyle]::Bold)
        Anchor          = $AnchorAll
        Add_MouseEnter  = $AutoChartChartingAdd_MouseEnter
    }
    #$script:AutoChartCharting.DataManipulator.Sort() = "Descending"


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
    $script:AutoChartTitle.Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif',$($FormScale * 16), [System.Drawing.FontStyle]::Bold)
    $script:AutoChartTitle.Alignment = "topcenter" #"topLeft"
    $script:AutoChartCharting.Titles.Add($script:AutoChartTitle)

    #-------------------------
    # Auto Create Charts Area
    #-------------------------
    $script:AutoChartsArea                        = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $script:AutoChartsArea.Name                   = "Chart Area"
    $script:AutoChartsArea.AxisX.Title            = $script:PropertyX
    if ( $script:PropertyY -eq "PSComputername" ) { $script:AutoChartsArea.AxisY.Title = "Hosts" }
    else {
        if ($script:PropertyY -eq 'Name') { $script:AutoChartsArea.AxisY.Title = "$QueryName" }
        else {$script:AutoChartsArea.AxisY.Title  = "$script:PropertyY"}
    }
    $script:AutoChartsArea.AxisX.Interval         = 1
    #$script:AutoChartsArea.AxisY.Interval        = 1
    $script:AutoChartsArea.AxisY.IntervalAutoMode = $true
    $script:AutoChartCharting.ChartAreas.Add($script:AutoChartsArea)

    #--------------------------
    # Auto Create Charts Legend
    #--------------------------
    $script:Legend                      = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $script:Legend.Enabled              = $True
    $script:Legend.Name                 = "Collection Legend"
    $script:Legend.Title                = "Legend"
    $script:Legend.TitleAlignment       = "topleft"
    $script:Legend.TitleFont            = New-Object System.Drawing.Font @('Microsoft Sans Serif',$($FormScale * 11), [System.Drawing.FontStyle]::Bold)
    $script:Legend.IsEquallySpacedItems = $True
    $script:Legend.BorderColor          = 'White'
    $script:AutoChartCharting.Legends.Add($script:Legend)

    #--------------------------------------------
    # Auto Create Charts Data Series Most Recent
    #--------------------------------------------
    $script:AutoChartCharting.Series.Add("Most Recent")
    $script:AutoChartCharting.Series["Most Recent"].Enabled           = $True
    $script:AutoChartCharting.Series["Most Recent"].ChartType         = 'Column'
    $script:AutoChartCharting.Series["Most Recent"].Color             = 'Blue'
    $script:AutoChartCharting.Series["Most Recent"].MarkerColor       = 'Blue'
    $script:AutoChartCharting.Series["Most Recent"].MarkerStyle       = 'Square' # None, Diamond, Square, Circle
    $script:AutoChartCharting.Series["Most Recent"].MarkerSize        = '10'
    $script:AutoChartCharting.Series["Most Recent"].BorderWidth       = 5
    $script:AutoChartCharting.Series["Most Recent"].IsVisibleInLegend = $true
    $script:AutoChartCharting.Series["Most Recent"].Chartarea         = "Chart Area"
    $script:AutoChartCharting.Series["Most Recent"].Legend            = "Legend"
    $script:AutoChartCharting.Series["Most Recent"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChartCharting.Series["Most Recent"]['PieLineColor']   = 'Black'
    $script:AutoChartCharting.Series["Most Recent"]['PieLabelStyle']  = 'Outside'

    #-----------------------------------------
    # Auto Create Charts Data Series Previous
    #-----------------------------------------
    $script:AutoChartCharting.Series.Add("Previous")
    $script:AutoChartCharting.Series["Previous"].Enabled           = $True
    $script:AutoChartCharting.Series["Previous"].ChartType         = 'Point'
    $script:AutoChartCharting.Series["Previous"].Color             = 'Red'
    $script:AutoChartCharting.Series["Previous"].MarkerColor       = 'Red'
    $script:AutoChartCharting.Series["Previous"].MarkerStyle       = 'Circle' # None, Diamond, Square, Circle
    $script:AutoChartCharting.Series["Previous"].MarkerSize        = '10'
    $script:AutoChartCharting.Series["Previous"].BorderWidth       = 5
    $script:AutoChartCharting.Series["Previous"].IsVisibleInLegend = $true
    $script:AutoChartCharting.Series["Previous"].Chartarea         = "Chart Area"
    $script:AutoChartCharting.Series["Previous"].Legend            = "Legend"
    $script:AutoChartCharting.Series["Previous"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChartCharting.Series["Previous"]['PieLineColor']   = 'Black'
    $script:AutoChartCharting.Series["Previous"]['PieLabelStyle']  = 'Outside'

    #-----------------------------------------
    # Auto Create Charts Data Series Baseline
    #-----------------------------------------
    $script:AutoChartCharting.Series.Add("Baseline")
    $script:AutoChartCharting.Series["Baseline"].Enabled           = $True
    $script:AutoChartCharting.Series["Baseline"].ChartType         = 'Point'
    $script:AutoChartCharting.Series["Baseline"].Color             = 'Orange'
    $script:AutoChartCharting.Series["Baseline"].MarkerColor       = 'Orange'
    $script:AutoChartCharting.Series["Baseline"].MarkerStyle       = 'Diamond' # None, Diamond, Square
    $script:AutoChartCharting.Series["Baseline"].MarkerSize        = '10'
    $script:AutoChartCharting.Series["Baseline"].BorderWidth       = 5
    $script:AutoChartCharting.Series["Baseline"].IsVisibleInLegend = $true
    $script:AutoChartCharting.Series["Baseline"].Chartarea         = "Chart Area"
    $script:AutoChartCharting.Series["Baseline"].Legend            = "Legend"
    $script:AutoChartCharting.Series["Baseline"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    $script:AutoChartCharting.Series["Baseline"]['PieLineColor']   = 'Black'
    $script:AutoChartCharting.Series["Baseline"]['PieLabelStyle']  = 'Outside'


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
    # Creates a sorted and unique listing of All Endpoints (PSComputerName), this will be used to compare each csv file against
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
        if ($script:PropertyY -eq "PSComputerName") {
            $DataSourceBaseline = @()
            foreach ($UniqueHostBaseline in $script:CsvUniqueHosts) {
                $DataSourceBaseline += $script:CsvFileCommonDataBaseline | Where-Object { $_.PSComputerName -eq $UniqueHostBaseline }
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourceBaseline += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $script:PropertyX -Unique

            # Important, gets a unique list for X and Y
            # In this case, X is the unique data name; ie process name, hash, file path, etc.
            $UniqueDataFieldsBaseline   = $DataSourceBaseline | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            # In this case, Y is the unique hostname/computername/endpoint names
            $UniqueComputerListBaseline = $DataSourceBaseline | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique

            # Counts the number of times that any given property possess a given value
            $Index = 1
            foreach ($DataFieldBaseline in $UniqueDataFieldsBaseline) {
                $CountBaseline          = 0
                $CsvComputersBaseline   = @()
                foreach ( $LineBaseline in $DataSourceBaseline ) {
                    if ($($LineBaseline.$script:PropertyX) -eq $($DataFieldBaseline.$script:PropertyX)) {
                        $CountBaseline += 1
                        if ( $CsvComputersBaseline -notcontains $($LineBaseline.$script:PropertyY) ) { $CsvComputersBaseline += $($LineBaseline.$script:PropertyY) }
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults
                $UniqueCountBaseline = $CsvComputersBaseline.Count - 1
                $DataResultsBaseline = New-Object PSObject -Property @{
                    DataField   = $DataFieldBaseline
                    TotalCount  = $CountBaseline
                    UniqueCount = $UniqueCountBaseline
                    Computers   = $CsvComputersBaseline
                    Index       = $Index
                }
                $script:OverallDataResultsBaseline += $DataResultsBaseline
                $Index += 1
            }
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsBaseline.count
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($script:PropertyX -eq "PSComputerName") {

            $DataSourceBaseline = @()
            $DataSourceBaseline = $script:CsvFileCommonDataBaseline

            $SelectedDataFieldBaseline  = $DataSourceBaseline | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique
            $UniqueComputerListBaseline = $DataSourceBaseline | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            $CurrentComputerBaseline    = ''
            $CheckIfFirstLineBaseline   = 'False'
            $ResultsCountBaseline       = 0
            $ComputerBaseline           = @()
            $YResultsBaseline           = @()
            foreach ( $LineBaseline in $DataSourceBaseline ) {
                if ( $CheckIfFirstLineBaseline -eq 'False' ) { $CurrentComputerBaseline  = $LineBaseline.$script:PropertyX ; $CheckIfFirstLineBaseline = 'True' }
                if ( $CheckIfFirstLineBaseline -eq 'True' ) {
                    if ( $LineBaseline.$script:PropertyX -eq $CurrentComputerBaseline ) {
                        if ( $YResultsBaseline -notcontains $LineBaseline.$script:PropertyY ) {
                            if ( $LineBaseline.$script:PropertyY -ne "" ) { $YResultsBaseline += $LineBaseline.$script:PropertyY ; $ResultsCountBaseline += 1 }
                            if ( $ComputerBaseline -notcontains $LineBaseline.$script:PropertyX ) { $ComputerBaseline = $LineBaseline.$script:PropertyX }
                        }
                    }
                    elseif ( $LineBaseline.$script:PropertyX -ne $CurrentComputerBaseline ) {
                        $CurrentComputerBaseline = $LineBaseline.$script:PropertyX
                        $DataResultsBaseline     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountBaseline ; Computer = $ComputerBaseline }
                        $script:OverallDataResultsBaseline += $DataResultsBaseline
                        $YResultsBaseline        = @()
                        $ResultsCountBaseline    = 0
                        $ComputerBaseline        = @()
                        if ( $YResultsBaseline -notcontains $LineBaseline.$script:PropertyY ) {
                            if ( $LineBaseline.$script:PropertyY -ne "" ) { $YResultsBaseline += $LineBaseline.$script:PropertyY ; $ResultsCountBaseline += 1 }
                            if ( $ComputerBaseline -notcontains $LineBaseline.$script:PropertyX ) { $ComputerBaseline = $LineBaseline.$script:PropertyX }
                        }
                    }
                }
            }
            $DataResultsBaseline = New-Object PSObject -Property @{ ResultsCount = $ResultsCountBaseline ; Computer = $ComputerBaseline }
            $script:OverallDataResultsBaseline += $DataResultsBaseline
        }
    }










    $script:OverallDataResultsPrevious = @()
    if (Test-Path $script:CSVFilePathPrevious) {
        # If the Second field/Y Axis equals PSComputername, it counts it
        if ($script:PropertyY -eq "PSComputerName") {
            $DataSourcePrevious = @()
            foreach ($UniqueHostPrevious in $script:CsvUniqueHosts) {
                $DataSourcePrevious += $script:CsvFileCommonDataPrevious | Where-Object { $_.PSComputerName -eq $UniqueHostPrevious }
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourcePrevious += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $script:PropertyX -Unique

            # Important, gets a unique list for X and Y
            $UniqueDataFieldsPrevious   = $DataSourcePrevious | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            $UniqueComputerListPrevious = $DataSourcePrevious | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique

            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            $Index = 1
            foreach ($DataFieldPrevious in $UniqueDataFieldsPrevious) {
                $CountPrevious          = 0
                $CsvComputersPrevious   = @()
                foreach ( $LinePrevious in $DataSourcePrevious ) {
                    if ($($LinePrevious.$script:PropertyX) -eq $($DataFieldPrevious.$script:PropertyX)) {
                        $CountPrevious += 1
                        if ( $CsvComputersPrevious -notcontains $($LinePrevious.$script:PropertyY) ) { $CsvComputersPrevious += $($LinePrevious.$script:PropertyY) }
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults
                $UniqueCountPrevious = $CsvComputersPrevious.Count - 1
                $DataResultsPrevious = New-Object PSObject -Property @{
                    DataField   = $DataFieldPrevious
                    TotalCount  = $CountPrevious
                    UniqueCount = $UniqueCountPrevious
                    Computers   = $CsvComputersPrevious
                    Index       = $Index
                }
                $script:OverallDataResultsPrevious += $DataResultsPrevious
                $Index += 1
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsPrevious.count
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($script:PropertyX -eq "PSComputerName") {

            $DataSourcePrevious = @()
            $DataSourcePrevious = $script:CsvFileCommonDataPrevious

            $SelectedDataFieldPrevious  = $DataSourcePrevious | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique
            $UniqueComputerListPrevious = $DataSourcePrevious | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            $CurrentComputerPrevious    = ''
            $CheckIfFirstLinePrevious   = 'False'
            $ResultsCountPrevious       = 0
            $ComputerPrevious           = @()
            $YResultsPrevious           = @()
            foreach ( $LinePrevious in $DataSourcePrevious ) {
                if ( $CheckIfFirstLinePrevious -eq 'False' ) { $CurrentComputerPrevious  = $LinePrevious.$script:PropertyX ; $CheckIfFirstLinePrevious = 'True' }
                if ( $CheckIfFirstLinePrevious -eq 'True' ) {
                    if ( $LinePrevious.$script:PropertyX -eq $CurrentComputerPrevious ) {
                        if ( $YResultsPrevious -notcontains $LinePrevious.$script:PropertyY ) {
                            if ( $LinePrevious.$script:PropertyY -ne "" ) { $YResultsPrevious += $LinePrevious.$script:PropertyY ; $ResultsCountPrevious += 1 }
                            if ( $ComputerPrevious -notcontains $LinePrevious.$script:PropertyX ) { $ComputerPrevious = $LinePrevious.$script:PropertyX }
                        }
                    }
                    elseif ( $LinePrevious.$script:PropertyX -ne $CurrentComputerPrevious ) {
                        $CurrentComputerPrevious = $LinePrevious.$script:PropertyX
                        $DataResultsPrevious     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountPrevious ; Computer = $ComputerPrevious }
                        $script:OverallDataResultsPrevious += $DataResultsPrevious
                        $YResultsPrevious        = @()
                        $ResultsCountPrevious    = 0
                        $ComputerPrevious        = @()
                        if ( $YResultsPrevious -notcontains $LinePrevious.$script:PropertyY ) {
                            if ( $LinePrevious.$script:PropertyY -ne "" ) { $YResultsPrevious += $LinePrevious.$script:PropertyY ; $ResultsCountPrevious += 1 }
                            if ( $ComputerPrevious -notcontains $LinePrevious.$script:PropertyX ) { $ComputerPrevious = $LinePrevious.$script:PropertyX }
                        }
                    }
                }
            }
            $DataResultsPrevious = New-Object PSObject -Property @{ ResultsCount = $ResultsCountPrevious ; Computer = $ComputerPrevious }
            $script:OverallDataResultsPrevious += $DataResultsPrevious
        }
    }











    $script:OverallDataResultsMostRecent = @()
    if (Test-Path $script:CSVFilePathMostRecent) {
        # If the Second field/Y Axis equals PSComputername, it counts it
        if ($script:PropertyY -eq "PSComputerName") {
            $DataSourceMostRecent = @()
            foreach ($UniqueHostMostRecent in $script:CsvUniqueHosts) {
                $DataSourceMostRecent += $script:CsvFileCommonDataMostRecent | Where-Object { $_.PSComputerName -eq $UniqueHostMostRecent }
            }
            # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            $DataSourceMostRecent += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $script:PropertyX -Unique

            # Important, gets a unique list for X and Y
            $UniqueDataFieldsMostRecent   = $DataSourceMostRecent | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            $UniqueComputerListMostRecent = $DataSourceMostRecent | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique

            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            $Index = 1
            foreach ($DataFieldMostRecent in $UniqueDataFieldsMostRecent) {
                $CountMostRecent          = 0
                $CsvComputersMostRecent   = @()
                foreach ( $LineMostRecent in $DataSourceMostRecent ) {
                    if ($($LineMostRecent.$script:PropertyX) -eq $($DataFieldMostRecent.$script:PropertyX)) {
                        $CountMostRecent += 1
                        if ( $CsvComputersMostRecent -notcontains $($LineMostRecent.$script:PropertyY) ) { $CsvComputersMostRecent += $($LineMostRecent.$script:PropertyY) }
                    }
                }
                # The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults
                $UniqueCountMostRecent = $CsvComputersMostRecent.Count - 1
                $DataResultsMostRecent = New-Object PSObject -Property @{
                    DataField   = $DataFieldMostRecent
                    TotalCount  = $CountMostRecent
                    UniqueCount = $UniqueCountMostRecent
                    Computers   = $CsvComputersMostRecent
                    Index       = $Index
                }
                $script:OverallDataResultsMostRecent += $DataResultsMostRecent
                $Index += 1
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $UniqueDataFieldsMostRecent.count
        }

        # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
        elseif ($script:PropertyX -eq "PSComputerName") {
            $DataSourceMostRecent = @()
            $DataSourceMostRecent = $script:CsvFileCommonDataMostRecent

            $SelectedDataFieldMostRecent  = $DataSourceMostRecent | Select-Object -Property $script:PropertyY | Sort-Object -Property $script:PropertyY -Unique
            $UniqueComputerListMostRecent = $DataSourceMostRecent | Select-Object -Property $script:PropertyX | Sort-Object -Property $script:PropertyX -Unique
            $CurrentComputerMostRecent    = ''
            $CheckIfFirstLineMostRecent   = 'False'
            $ResultsCountMostRecent       = 0
            $ComputerMostRecent           = @()
            $YResultsMostRecent           = @()
            foreach ( $LineMostRecent in $DataSourceMostRecent ) {
                if ( $CheckIfFirstLineMostRecent -eq 'False' ) { $CurrentComputerMostRecent  = $LineMostRecent.$script:PropertyX ; $CheckIfFirstLineMostRecent = 'True' }
                if ( $CheckIfFirstLineMostRecent -eq 'True' ) {
                    if ( $LineMostRecent.$script:PropertyX -eq $CurrentComputerMostRecent ) {
                        if ( $YResultsMostRecent -notcontains $LineMostRecent.$script:PropertyY ) {
                            if ( $LineMostRecent.$script:PropertyY -ne "" ) { $YResultsMostRecent += $LineMostRecent.$script:PropertyY ; $ResultsCountMostRecent += 1 }
                            if ( $ComputerMostRecent -notcontains $LineMostRecent.$script:PropertyX ) { $ComputerMostRecent = $LineMostRecent.$script:PropertyX }
                        }
                    }
                    elseif ( $LineMostRecent.$script:PropertyX -ne $CurrentComputerMostRecent ) {
                        $CurrentComputerMostRecent = $LineMostRecent.$script:PropertyX
                        $DataResultsMostRecent     = New-Object PSObject -Property @{ ResultsCount = $ResultsCountMostRecent ; Computer = $ComputerMostRecent }
                        $script:OverallDataResultsMostRecent += $DataResultsMostRecent
                        $YResultsMostRecent        = @()
                        $ResultsCountMostRecent    = 0
                        $ComputerMostRecent        = @()
                        if ( $YResultsMostRecent -notcontains $LineMostRecent.$script:PropertyY ) {
                            if ( $LineMostRecent.$script:PropertyY -ne "" ) { $YResultsMostRecent += $LineMostRecent.$script:PropertyY ; $ResultsCountMostRecent += 1 }
                            if ( $ComputerMostRecent -notcontains $LineMostRecent.$script:PropertyX ) { $ComputerMostRecent = $LineMostRecent.$script:PropertyX }
                        }
                    }
                }
            }
            $DataResultsMostRecent = New-Object PSObject -Property @{ ResultsCount = $ResultsCountMostRecent ; Computer = $ComputerMostRecent }
            $script:OverallDataResultsMostRecent += $DataResultsMostRecent
        }
    } # END if ( $script:CSVFilePathMostRecent )

    Clear-Variable -Name MergedCSVDataResults




function script:Update-MultiSeriesChart {
    param(
        [switch]$TrackBar
    )
    #robin
    # Creates an ordered list to organize the chart values to assign all three charts
    # The ordered list is based on the most recent results and is based on unique counts of the associated properties
    if ($script:PropertyY -eq "PSComputerName" ) {
        if (Test-Path $script:CSVFilePathMostRecent) {
            $script:AutoChartCharting.Series["Most Recent"].Points.Clear()
            $Order = 1
            $script:OverallDataResultsMostRecent | Sort-Object -Property UniqueCount,Index | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name 'ChartOrder' -Value $Order
                $Order += 1
            }
            if ($TrackBar){
                $script:OverallDataResultsMostRecent |
                Sort-Object -Property ChartOrder |
                Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                ForEach-Object {
                    $script:AutoChartCharting.Series["Most Recent"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                }
            }
            else {
                $script:OverallDataResultsMostRecent |
                Sort-Object -Property ChartOrder |
                ForEach-Object {
                    $script:AutoChartCharting.Series["Most Recent"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                    $script:AutoChartsProgressBar.Value += 1
                }
            }
        }
        $ChartOrder = $script:OverallDataResultsMostRecent | Sort-Object -Property ChartOrder | Select-Object -ExpandProperty Index

        if (Test-Path $script:CSVFilePathBaseline) {
            $script:AutoChartCharting.Series["Baseline"].Points.Clear()

            if ($TrackBar){
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsBaseline |
                    Sort-Object -Property UniqueCount,Index |
                    Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                    Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Baseline"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                        }
                    }
                }
            }
            else {
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsBaseline |
                    Sort-Object -Property UniqueCount,Index |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Baseline"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                            $script:AutoChartsProgressBar.Value += 1
                        }
                    }
                }
            }
        }

        if (Test-Path $script:CSVFilePathPrevious) {
            $script:AutoChartCharting.Series["Previous"].Points.Clear()

            if ($TrackBar){
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsPrevious |
                    Sort-Object -Property UniqueCount,Index  |
                    Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                    Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Previous"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                        }
                    }
                }
            }
            else {
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsPrevious |
                    Sort-Object -Property UniqueCount,Index  |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Previous"].Points.AddXY($_.DataField.$script:PropertyX,$_.UniqueCount)
                            $script:AutoChartsProgressBar.Value += 1
                        }
                    }
                }
            }
        }
    }

    elseif ($script:PropertyX -eq "PSComputerName") {
        if (Test-Path $script:CSVFilePathMostRecent) {
            $script:AutoChartCharting.Series["Most Recent"].Points.Clear()
            $Order = 1
            $script:OverallDataResultsMostRecent | Sort-Object -Property UniqueCount,Index | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name 'ChartOrder' -Value $Order
                $Order += 1
            }

            if ($TrackBar){
                $script:OverallDataResultsMostRecent |
                Sort-Object -Property ChartOrder |
                Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                ForEach-Object {
                    if ($_.Index -eq $Order){
                        $script:AutoChartCharting.Series["Most Recent"].Points.AddXY($_.Computer,$_.ResultsCount)
                    }
                }
            }
            else {
                $script:OverallDataResultsMostRecent | Sort-Object -Property ChartOrder | ForEach-Object {
                    $script:AutoChartCharting.Series["Most Recent"].Points.AddXY($_.Computer,$_.ResultsCount)
                    $script:AutoChartsProgressBar.Value += 1
                }
            }
        }
        $ChartOrder = $script:OverallDataResultsMostRecent | Sort-Object -Property ChartOrder | Select-Object -ExpandProperty Index

        if (Test-Path $script:CSVFilePathBaseline) {
            $script:AutoChartCharting.Series["Baseline"].Points.Clear()

            if ($TrackBar){
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsBaseline |
                    Sort-Object -Property UniqueCount,Index |
                    Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                    Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Baseline"].Points.AddXY($_.Computer,$_.ResultsCount)
                        }
                    }
                }
            }
            else {
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsBaseline |
                    Sort-Object -Property UniqueCount,Index |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Baseline"].Points.AddXY($_.Computer,$_.ResultsCount)
                            $script:AutoChartsProgressBar.Value += 1
                        }
                    }
                }
            }
        }

        if (Test-Path $script:CSVFilePathPrevious) {
            $script:AutoChartCharting.Series["Previous"].Points.Clear()

            if ($TrackBar){
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsPrevious |
                    Sort-Object -Property UniqueCount,Index |
                    Select-Object -skip $script:AutoChartsTrimOffFirstTrackBarValue |
                    Select-Object -SkipLast $script:AutoChartsTrimOffLastTrackBarValue |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Previous"].Points.AddXY($_.Computer,$_.ResultsCount)
                        }
                    }
                }
            }
            else {
                foreach ($Order in $ChartOrder) {
                    $script:OverallDataResultsPrevious |
                    Sort-Object -Property UniqueCount,Index |
                    ForEach-Object {
                        if ($_.Index -eq $Order){
                            $script:AutoChartCharting.Series["Previous"].Points.AddXY($_.Computer,$_.ResultsCount)
                            $script:AutoChartsProgressBar.Value += 1
                        }
                    }
                }
            }
        }
    }
}
script:Update-MultiSeriesChart








    ############################################################################################################
    # Auto Create Charts Processes
    ############################################################################################################
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $script:AutoChartsIndividualTabPage         = New-Object System.Windows.Forms.TabPage
    $script:AutoChartsIndividualTabPage.Text    = "$QueryTabName"
    $script:AutoChartsIndividualTabPage.Name    = "$QueryTabName"
    $script:AutoChartsIndividualTabPage.Anchor  = $AnchorAll
    $script:AutoChartsIndividualTabPage.Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    $script:AutoChartsIndividualTabPage.UseVisualStyleBackColor = $True
    $AutoChartsTabControl.Controls.Add($script:AutoChartsIndividualTabPage)
    $AutoChartsTabControl.SelectedTab = $script:AutoChartsIndividualTabPage

    ### Auto Chart Panel that contains all the options to manage open/close feature
    $script:AutoChartsOptionsButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Options v"
        Location  = @{ X = $script:AutoChartCharting.Location.X + $($FormScale * 10)
                    Y = $script:AutoChartCharting.Location.Y + $script:AutoChartCharting.Size.Height - $($FormScale * 29) }
        Size      = @{ Width  = $FormScale * 75
                    Height = $FormScale * 20 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left;
    }
    CommonButtonSettings -Button $script:AutoChartsOptionsButton
    $script:AutoChartsOptionsButton.Add_Click({
        if ($script:AutoChartsOptionsButton.Text -eq 'Options v') {
            $script:AutoChartsOptionsButton.Text = 'Options ^'
            $script:AutoChartCharting.Controls.Add($script:AutoChartsManipulationPanel)
        }
        elseif ($script:AutoChartsOptionsButton.Text -eq 'Options ^') {
            $script:AutoChartsOptionsButton.Text = 'Options v'
            $script:AutoChartCharting.Controls.Remove($script:AutoChartsManipulationPanel)
        }
    })
    $script:AutoChartsIndividualTabPage.Controls.Add($script:AutoChartsOptionsButton)


    $script:AutoChartsCloseTabButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Close Tab"
        Location  = @{ X = $script:AutoChartCharting.Location.X + $script:AutoChartCharting.Width - $($FormScale * 85)
                    Y = $script:AutoChartCharting.Location.Y + $($FormScale * 10) }
        Size      = @{ Width  = $FormScale * 75
                        Height = $FormScale * 20 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsCloseTabButton
    $script:AutoChartsCloseTabButton.Add_Click({
        $AutoChartsTabControl.Controls.Remove($script:AutoChartsIndividualTabPage)
    })
    $script:AutoChartsIndividualTabPage.Controls.Add($script:AutoChartsCloseTabButton)


    $script:AutoChartsIndividualTabPage.Controls.Add($script:AutoChartCharting)

    $script:AutoChartsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
        Location    = @{ X = 0
                        Y = $script:AutoChartCharting.Size.Height - $($FormScale * 150) }
        Size        = @{ Width  = $script:AutoChartCharting.Size.Width
                        Height = $FormScale * 150 }
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
        BackColor   = 'White'
        BorderStyle = 'FixedSingle'
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left;
    }


    #==============================================================================================================================
    # AutoCharts - Trim TrackBars
    #==============================================================================================================================
    #--------------------------------------
    # AutoCharts - Trim Off First GroupBox
    #--------------------------------------
    $script:AutoChartsTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text        = "Trim Off First: 0"
        Location    = @{ X = $FormScale * 10
                         Y = $($FormScale * 5) }
        Size        = @{ Width  = $FormScale * 290
                         Height = $FormScale * 67}
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        #--------------------------------------
        # AutoCharts - Trim Off First TrackBar
        #--------------------------------------
        $script:AutoChartsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Location    = @{ X = $($FormScale * 1)
                             Y = $($FormScale * 20) }
            Size        = @{ Width  = $FormScale * 285
                             Height = $FormScale * 22 }
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

            script:Update-MultiSeriesChart -TrackBar
        })
        $script:AutoChartsTrimOffFirstGroupBox.Controls.Add($script:AutoChartsTrimOffFirstTrackBar)
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTrimOffFirstGroupBox)


    #--------------------------------------
    # Auto Charts - Trim Off Last GroupBox
    #--------------------------------------
    $script:AutoChartsTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text        = "Trim Off Last: 0"
        Location    = @{ X = $script:AutoChartsTrimOffFirstGroupBox.Location.X + $script:AutoChartsTrimOffFirstGroupBox.Size.Width + $($FormScale * 10)
                         Y = $script:AutoChartsTrimOffFirstGroupBox.Location.Y }
        Size        = @{ Width  = $FormScale * 290
                         Height = $FormScale * 67 }
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        #-------------------------------------
        # AutoCharts - Trim Off Last TrackBar
        #-------------------------------------
        $script:AutoChartsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Location      = @{ X = $($FormScale * 1)
                               Y = $($FormScale * 20) }
            Size          = @{ Width  = $FormScale * 285
                               Height = $FormScale * 22}
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
            script:Update-MultiSeriesChart -TrackBar
        })
        $script:AutoChartsTrimOffLastGroupBox.Controls.Add($script:AutoChartsTrimOffLastTrackBar)
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTrimOffLastGroupBox)


    #----------------------------------
    # Auto Charts - Title Name Textbox
    #----------------------------------
    $script:AutoChartsTitleNameTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Location    = @{ X = $script:AutoChartsTrimOffFirstGroupBox.Location.X
                         Y = $script:AutoChartsTrimOffFirstGroupBox.Location.Y + $script:AutoChartsTrimOffFirstGroupBox.Size.Height + $($FormScale * 6)  }
        Size        = @{ Width  = $script:AutoChartsTrimOffFirstGroupBox.Size.Width
                         Height = $FormScale * 62 }
        Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
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
                         Y = $script:AutoChartsTrimOffLastGroupBox.Location.Y + $script:AutoChartsTrimOffLastGroupBox.Size.Height + $($FormScale * 6)  }
        Size        = @{ Width  = $script:AutoChartsTrimOffLastGroupBox.Size.Width - 1
                         Height = $FormScale * 62 }
#        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
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
            Size   = @{ Width  = $FormScale * 330
                        Height = $FormScale * 360 }
            Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            StartPosition = "CenterScreen"
            ControlBox = $true
            Add_Closing = { $This.dispose() }
        }
        #---------------------------------------------------
        # Investigate Difference Drop Down Label & ComboBox
        #---------------------------------------------------
        $AutoChartsInvestigateDifferenceDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Investigate the difference between computers."
            Location = @{ X = $FormScale * 10
                            Y = $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 290
                            Height = $FormScale * 45 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $AutoChartsInvestigateDifferenceDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Location = @{ X = $FormScale * 10
                            Y = $AutoChartsInvestigateDifferenceDropDownLabel.Location.y + $AutoChartsInvestigateDifferenceDropDownLabel.Size.Height }
            Width    = $FormScale * 290
            Height   = $FormScale * 30
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
            Location = @{ X = $FormScale * 10
                            Y = $AutoChartsInvestigateDifferenceDropDownComboBox.Location.y + $AutoChartsInvestigateDifferenceDropDownComboBox.Size.Height + $($FormScale * 10) }
            Width    = $FormScale * 100
            Height   = $FormScale * 20
        }
        CommonButtonSettings -Button $AutoChartsInvestigateDifferenceExecuteButton
        $AutoChartsInvestigateDifferenceExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { InvestigateDifference-AutoChart }})
        $AutoChartsInvestigateDifferenceExecuteButton.Add_Click({ InvestigateDifference-AutoChart })
        $AutoChartsInvestigateDifferenceForm.Controls.Add($AutoChartsInvestigateDifferenceExecuteButton)


        #---------------------------------------------------------
        # Investigate Difference Positive Results Label & TextBox
        #---------------------------------------------------------
        $AutoChartsInvestigateDifferencePositiveResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text       = "Positive Match (+)"
            Location   = @{ X = $FormScale * 10
                            Y = $AutoChartsInvestigateDifferenceExecuteButton.Location.y + $AutoChartsInvestigateDifferenceExecuteButton.Size.Height + $($FormScale * 10) }
            Size       = @{ Width  = $FormScale * 140
                            Height = $FormScale * 22 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $AutoChartsInvestigateDifferencePositiveResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location   = @{ X = $FormScale * 10
                            Y = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.y + $AutoChartsInvestigateDifferencePositiveResultsLabel.Size.Height }
            Size       = @{ Width  = $FormScale * 140
                            Height = $FormScale * 178 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
            Location   = @{ X = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.x + $AutoChartsInvestigateDifferencePositiveResultsLabel.Size.Width + $($FormScale * 10)
                            Y = $AutoChartsInvestigateDifferencePositiveResultsLabel.Location.y }
            Size       = @{ Width  = $FormScale * 140
                            Height = $FormScale * 22 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $AutoChartsInvestigateDifferenceForm.Controls.Add($AutoChartsInvestigateDifferenceNegativeResultsLabel)

        $AutoChartsInvestigateDifferenceNegativeResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location   = @{ X = $AutoChartsInvestigateDifferenceNegativeResultsLabel.Location.x
                            Y = $AutoChartsInvestigateDifferenceNegativeResultsLabel.Location.y + $AutoChartsInvestigateDifferenceNegativeResultsLabel.Size.Height }
            Size       = @{ Width  = $FormScale * 140
                            Height = $FormScale * 178 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
        Location  = @{ X = $script:AutoChartsTrimOffLastGroupBox.Location.X + $script:AutoChartsTrimOffLastGroupBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsTrimOffLastGroupBox.Location.Y + $($FormScale * 2) }
        Size      = @{ Width  = $FormScale * 125
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Checked   = $true
    }
    $script:AutoChartsTitleCheckBox.Add_Click({
        if   ( $script:AutoChartsTitleCheckBox.Checked ) { $script:AutoChartCharting.Titles.Add($script:AutoChartTitle) }
        else { $script:AutoChartCharting.Titles.Remove($script:AutoChartTitle) }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsTitleCheckBox)


    #================================
    # Auto Create Charts Save Button
    #================================
    $script:AutoChartsSaveChartImageButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Save Image"
        Location  = @{ X = $script:AutoChartsTitleCheckBox.Location.X + $script:AutoChartsTitleCheckBox.Size.Width + $($FormScale * 6)
                       Y = $script:AutoChartsTitleCheckBox.Location.Y }
        Size      = @{ Width = $FormScale * 100
                       Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsSaveChartImageButton
    $script:AutoChartsSaveChartImageButton.Add_Click({
        Save-ChartImage -Chart $script:AutoChartCharting  -Title $script:AutoChartTitle
    })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsSaveChartImageButton)


    #=======================================
    # Auto Create Charts Select Chart Label
    #=======================================
    $script:AutoChartsChartTypeFilterLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = 'Category Filter -->'
        Location = @{ X = $script:AutoChartsSaveChartImageButton.Location.X + $script:AutoChartsSaveChartImageButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsSaveChartImageButton.Location.Y + 4 }
        Size      = @{ Width  = $FormScale * 100
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeFilterLabel)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeFilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column'
        Location = @{ X = $script:AutoChartsChartTypeFilterLabel.Location.X + $script:AutoChartsChartTypeFilterLabel.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsChartTypeFilterLabel.Location.Y - $($FormScale * 4) }
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesFilterAvailable = @('Column','Bar','Pie','Doughnut','Radar','Polar','Funnel','Pyramid')
    ForEach ($Item in $script:AutoChartsChartTypesFilterAvailable) { $script:AutoChartsChartTypeFilterComboBox.Items.Add($Item) }

    $script:AutoChartsChartTypeFilterComboBox.add_SelectedIndexChanged({
        function Update-AvailableCharts ($AvailableCharts) {
            $script:AutoChartCharting.Series["Most Recent"].ChartType = $false
            $script:AutoChartCharting.Series["Previous"].ChartType    = $false
            $script:AutoChartCharting.Series["Baseline"].ChartType    = $false
            $script:AutoChartsChartTypeMostRecentComboBox.Items.Clear()
            $script:AutoChartsChartTypePreviousComboBox.Items.Clear()
            $script:AutoChartsChartTypeBaselineComboBox.Items.Clear()

            $script:AutoChartCharting.Series["Most Recent"].ChartType = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartCharting.Series["Previous"].ChartType    = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartCharting.Series["Baseline"].ChartType    = $script:AutoChartsChartTypeFilterComboBox.SelectedItem

            $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypePreviousComboBox.Text   = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypeBaselineComboBox.Text   = $script:AutoChartsChartTypeFilterComboBox.SelectedItem
            $script:AutoChartsChartTypeComboBox.Text           = 'None'

            if ($script:AutoChartCharting.Series["Most Recent"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Most Recent"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Most Recent"].BorderWidth = 1 }
            else { $script:AutoChartCharting.Series["Most Recent"].BorderWidth = 5 }
            if ($script:AutoChartCharting.Series["Previous"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Previous"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Previous"].BorderWidth = 1 }
            else { $script:AutoChartCharting.Series["Previous"].BorderWidth = 5 }
            if ($script:AutoChartCharting.Series["Baseline"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Baseline"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Baseline"].BorderWidth = 1 }
            else { $script:AutoChartCharting.Series["Baseline"].BorderWidth = 5 }

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
                       Y = $script:AutoChartsTitleCheckBox.Location.Y + $script:AutoChartsTitleCheckBox.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $FormScale * 125
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Blue"
        Checked   = $true
    }
    $script:AutoChartsDisplayMostRecentSeriesCheckBox.Add_Click({
        if ( $script:AutoChartCharting.Series["Most Recent"].Enabled -eq $True ) {
            $script:AutoChartCharting.Series.Remove("Most Recent")
            $script:AutoChartCharting.Series["Most Recent"].Enabled = $False
            $script:AutoChartsDisplayMostRecentSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChartCharting.Series.Add("Most Recent")
            $script:AutoChartCharting.Series["Most Recent"].Enabled = $True
            $script:AutoChartsDisplayMostRecentSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayMostRecentSeriesCheckBox)


    #==========================================
    # Auto Create - Most Recent Results Button
    #==========================================
    $script:AutoChartsResultsMostRecentButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location  = @{ X = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.X + $script:AutoChartsDisplayMostRecentSeriesCheckBox.Size.Width + $($FormScale * 6)
                       Y = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.Y }
        Size      = @{ Width  = $FormScale * 100
                       Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsResultsMostRecentButton
    $script:AutoChartsResultsMostRecentButton.Add_Click({ Import-CSV $script:CSVFilePathMostRecent | Out-GridView -Title "$script:CSVFilePathMostRecent" })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsMostRecentButton)

    # Autosaves the chart if checked
    $FileName = ($script:CSVFilePathMostRecent).split('\')[-1].replace('.csv','')
    $FileDate = ($script:CSVFilePathMostRecent).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChartCharting.SaveImage("$AutosavedChartsDirectory\$FileDate - $FileName.png", 'png') }


    #=====================================
    # Auto Create Investigate Most Recent
    #=====================================
    $script:AutoChartsInvestigateMostRecentButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location = @{ X = $script:AutoChartsResultsMostRecentButton.Location.X + $script:AutoChartsResultsMostRecentButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsResultsMostRecentButton.Location.Y}
        Size      = @{ Width  = $FormScale * 100
                       Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsInvestigateMostRecentButton
    $script:AutoChartsInvestigateMostRecentButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathMostRecent
    })
    $script:AutoChartsInvestigateMostRecentButton.Add_MouseHover({
    Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigateMostRecentButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeMostRecentComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column'
        Location = @{ X = $script:AutoChartsInvestigateMostRecentButton.Location.X + $script:AutoChartsInvestigateMostRecentButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsInvestigateMostRecentButton.Location.Y }
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Blue"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeMostRecentComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypeMostRecentComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Most Recent"].ChartType  = $script:AutoChartsChartTypeMostRecentComboBox.SelectedItem
        $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeMostRecentComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeMostRecentComboBox)


    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorMostRecentComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Blue"
        Location = @{ X = $script:AutoChartsChartTypeMostRecentComboBox.Location.X + $script:AutoChartsChartTypeMostRecentComboBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsChartTypeMostRecentComboBox.Location.Y}
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 20 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Blue"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailableMostRecent = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailableMostRecent) { $script:AutoChartsChangeColorMostRecentComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorMostRecentComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Most Recent"].Color               = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
        $script:AutoChartCharting.Series["Most Recent"].MarkerColor         = $script:AutoChartsChangeColorMostRecentComboBox.SelectedItem
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
                      Y = $script:AutoChartsDisplayMostRecentSeriesCheckBox.Location.Y + $script:AutoChartsDisplayMostRecentSeriesCheckBox.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $FormScale * 125
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Red"
        Checked   = $true
    }
    $script:AutoChartsDisplayPreviousSeriesCheckBox.Add_Click({
        if ( $script:AutoChartCharting.Series["Previous"].Enabled -eq $True ) {
            $script:AutoChartCharting.Series.Remove("Previous")
            $script:AutoChartCharting.Series["Previous"].Enabled = $False
            $script:AutoChartsDisplayPreviousSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChartCharting.Series.Add("Previous")
            $script:AutoChartCharting.Series["Previous"].Enabled = $True
            $script:AutoChartsDisplayPreviousSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayPreviousSeriesCheckBox)


    #=======================================
    # Auto Create - Previous Results Button
    #=======================================
    $script:AutoChartsResultsPreviousButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location = @{ X = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.X + $script:AutoChartsDisplayPreviousSeriesCheckBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.Y }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsResultsPreviousButton
    $script:AutoChartsResultsPreviousButton.Add_Click({ Import-CSV $script:CSVFilePathPrevious | Out-GridView -Title "$script:CSVFilePathPrevious" })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsPreviousButton)

    # Autosaves the chart if checked
    $FileName = ($script:CSVFilePathPrevious).split('\')[-1].replace('.csv','')
    $FileDate = ($script:CSVFilePathPrevious).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChartCharting.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }


    #=====================================
    # Auto Create Investigate Most Recent
    #=====================================
    $script:AutoChartsInvestigatePreviousButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location = @{ X = $script:AutoChartsResultsPreviousButton.Location.X + $script:AutoChartsResultsPreviousButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsResultsPreviousButton.Location.Y}
        Size      = @{ Width  = $FormScale * 100
                       Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsInvestigatePreviousButton
    $script:AutoChartsInvestigatePreviousButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathPrevious
    })
    $script:AutoChartsInvestigatePreviousButton.Add_MouseHover({
    Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigatePreviousButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypePreviousComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Point'
        Location = @{ X = $script:AutoChartsInvestigatePreviousButton.Location.X + $script:AutoChartsInvestigatePreviousButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsInvestigatePreviousButton.Location.Y }
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Red"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypePreviousComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypePreviousComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Most Recent"].ChartType  = $script:AutoChartsChartTypePreviousComboBox.SelectedItem
        $script:AutoChartsChartTypePreviousComboBox.Text = $script:AutoChartsChartTypePreviousComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypePreviousComboBox)


    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorPreviousComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Red"
        Location = @{ X = $script:AutoChartsChartTypePreviousComboBox.Location.X + $script:AutoChartsChartTypePreviousComboBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsChartTypePreviousComboBox.Location.Y}
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 20 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Red"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailablePrevious = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailablePrevious) { $script:AutoChartsChangeColorPreviousComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorPreviousComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Previous"].Color                = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
        $script:AutoChartCharting.Series["Previous"].MarkerColor          = $script:AutoChartsChangeColorPreviousComboBox.SelectedItem
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
                      Y = $script:AutoChartsDisplayPreviousSeriesCheckBox.Location.Y + $script:AutoChartsDisplayPreviousSeriesCheckBox.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $FormScale * 125
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Orange"
        Checked   = $true
    }
    $script:AutoChartsDisplayBaselineSeriesCheckBox.Add_Click({
        if ( $script:AutoChartCharting.Series["Baseline"].Enabled -eq $True ) {
            $script:AutoChartCharting.Series.Remove("Baseline")
            $script:AutoChartCharting.Series["Baseline"].Enabled = $False
            $script:AutoChartsDisplayBaselineSeriesCheckBox.Checked = $false
        }
        else {
            $script:AutoChartCharting.Series.Add("Baseline")
            $script:AutoChartCharting.Series["Baseline"].Enabled = $True
            $script:AutoChartsDisplayBaselineSeriesCheckBox.Checked = $true
        }
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsDisplayBaselineSeriesCheckBox)


    #=======================================
    # Auto Create - Baseline Results Button
    #=======================================
    $script:AutoChartsResultsBaselineButton = New-Object Windows.Forms.Button -Property @{
        Text      = "View Results"
        Location = @{ X = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.X + $script:AutoChartsDisplayBaselineSeriesCheckBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.Y }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsResultsBaselineButton
    $script:AutoChartsResultsBaselineButton.Add_Click({ Import-CSV $script:CSVFilePathBaseline | Out-GridView -Title "$script:CSVFilePathBaseline" })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsResultsBaselineButton)

    # Autosaves the chart if checked
    $FileName = ($script:CSVFilePathBaseline).split('\')[-1].replace('.csv','')
    $FileDate = ($script:CSVFilePathBaseline).split('\')[-2]
    if ($OptionsAutoSaveChartsAsImages.checked) { $script:AutoChartCharting.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }


    #==================================
    # Auto Create Investigate Baseline
    #==================================
    $script:AutoChartsInvestigateBaselineButton = New-Object Windows.Forms.Button -Property @{
        Text      = "Investigate"
        Location  = @{ X = $script:AutoChartsResultsBaselineButton.Location.X + $script:AutoChartsResultsBaselineButton.Size.Width + $($FormScale * 6)
                       Y = $script:AutoChartsResultsBaselineButton.Location.Y }
        Size      = @{ Width  = $FormScale * 100
                       Height = $FormScale * 22 }
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    CommonButtonSettings -Button $script:AutoChartsInvestigateBaselineButton
    $script:AutoChartsInvestigateBaselineButton.Add_Click({
        script:Investigate-CsvFileData -ImportCsvFileData $script:CSVFilePathBaseline
    })
    $script:AutoChartsInvestigateBaselineButton.Add_MouseHover({
    Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@      })
    $script:AutoChartsManipulationPanel.controls.Add($script:AutoChartsInvestigateBaselineButton)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeBaselineComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Point'
        Location = @{ X = $script:AutoChartsInvestigateBaselineButton.Location.X + $script:AutoChartsInvestigateBaselineButton.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsInvestigateBaselineButton.Location.Y }
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Orange"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypesAvailable = @('Column','Line','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Point','Range','RangeColumn','Spline','SplineArea','SplineRange','StackedArea','StackedColumn','StepLine','Stock')
    ForEach ($Item in $script:AutoChartsChartTypesAvailable) { $script:AutoChartsChartTypeBaselineComboBox.Items.Add($Item) }
    $script:AutoChartsChartTypeBaselineComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Baseline"].ChartType  = $script:AutoChartsChartTypeBaselineComboBox.SelectedItem
        $script:AutoChartsChartTypeBaselineComboBox.Text = $script:AutoChartsChartTypeBaselineComboBox.SelectedItem
    })
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeBaselineComboBox)


    #===============================
    # Change the color of the chart
    #===============================
    $script:AutoChartsChangeColorBaselineComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Orange"
        Location = @{ X = $script:AutoChartsChartTypeBaselineComboBox.Location.X + $script:AutoChartsChartTypeBaselineComboBox.Size.Width + $($FormScale * 6)
                      Y = $script:AutoChartsChartTypeBaselineComboBox.Location.Y}
        Size      = @{ Width  = $FormScale * 75
                       Height = $FormScale * 20 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Orange"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsColorsAvailableBaseline = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartsColorsAvailableBaseline) { $script:AutoChartsChangeColorBaselineComboBox.Items.Add($Item) }
    $script:AutoChartsChangeColorBaselineComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Baseline"].Color                = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
        $script:AutoChartCharting.Series["Baseline"].MarkerColor          = $script:AutoChartsChangeColorBaselineComboBox.SelectedItem
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
                       Y = $script:AutoChartsDisplayBaselineSeriesCheckBox.Location.Y + $script:AutoChartsDisplayBaselineSeriesCheckBox.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $FormScale * 125
                       Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
                      Y = $script:AutoChartsInvestigateBaselineButton.Location.Y + $script:AutoChartsInvestigateBaselineButton.Size.Height + $($FormScale * 6)  + $($FormScale * 2) }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 22 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChartsManipulationPanel.Controls.Add($script:AutoChartsChartTypeApplyAllLabel)


    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartsChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = 'Column'
        Location = @{ X = $script:AutoChartsChartTypeBaselineComboBox.Location.X
                        Y = $script:AutoChartsChartTypeBaselineComboBox.Location.Y + $script:AutoChartsChartTypeBaselineComboBox.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $FormScale * 75
                        Height = $FormScale * 22 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartsChartTypeComboBox.add_SelectedIndexChanged({
        $script:AutoChartCharting.Series["Most Recent"].ChartType = $false
        $script:AutoChartCharting.Series["Previous"].ChartType    = $false
        $script:AutoChartCharting.Series["Baseline"].ChartType    = $false
        $script:AutoChartCharting.Series["Most Recent"].ChartType = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartCharting.Series["Previous"].ChartType    = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartCharting.Series["Baseline"].ChartType    = $script:AutoChartsChartTypeComboBox.SelectedItem

        $script:AutoChartsChartTypeFilterComboBox.Text     = 'None'
        $script:AutoChartsChartTypeMostRecentComboBox.Text = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartsChartTypePreviousComboBox.Text   = $script:AutoChartsChartTypeComboBox.SelectedItem
        $script:AutoChartsChartTypeBaselineComboBox.Text   = $script:AutoChartsChartTypeComboBox.SelectedItem

        if ($script:AutoChartCharting.Series["Most Recent"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Most Recent"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Most Recent"].BorderWidth = 1 }
        else { $script:AutoChartCharting.Series["Most Recent"].BorderWidth = 5 }
        if ($script:AutoChartCharting.Series["Previous"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Previous"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Previous"].BorderWidth = 1 }
        else { $script:AutoChartCharting.Series["Previous"].BorderWidth = 5 }
        if ($script:AutoChartCharting.Series["Baseline"].ChartType -eq 'Pie' -or $script:AutoChartCharting.Series["Baseline"].ChartType -eq 'Doughnut') { $script:AutoChartCharting.Series["Baseline"].BorderWidth = 1 }
        else { $script:AutoChartCharting.Series["Baseline"].BorderWidth = 5 }
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
                        Y = $script:AutoChartsResultsBaselineButton.Location.Y + $script:AutoChartsResultsBaselineButton.Size.Height + $($FormScale * 6)  }
        Size      = @{ Width  = $script:AutoChartsResultsBaselineButton.Size.Width
                        Height = $FormScale * 22 }
    }
    CommonButtonSettings -Button $script:AutoCharts3DToggleButton
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


