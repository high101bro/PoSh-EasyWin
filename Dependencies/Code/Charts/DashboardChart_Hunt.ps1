
$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Dashboard Overview'
    Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    AutoScroll    = $True
}
$AutoChartsTabControl.Controls.Add($script:AutoChartsIndividualTab01)

# Searches though the all Collection Data Directories to find files that match
$script:ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName



function Close-AllOptions {
    $script:AutoChart01OptionsButton.Text = 'Options v'
    $script:AutoChart01.Controls.Remove($script:AutoChart01ManipulationPanel)
    $script:AutoChart02OptionsButton.Text = 'Options v'
    $script:AutoChart02.Controls.Remove($script:AutoChart02ManipulationPanel)
    $script:AutoChart03OptionsButton.Text = 'Options v'
    $script:AutoChart03.Controls.Remove($script:AutoChart03ManipulationPanel)
    $script:AutoChart04OptionsButton.Text = 'Options v'
    $script:AutoChart04.Controls.Remove($script:AutoChart04ManipulationPanel)
    $script:AutoChart05OptionsButton.Text = 'Options v'
    $script:AutoChart05.Controls.Remove($script:AutoChart05ManipulationPanel)
    $script:AutoChart06OptionsButton.Text = 'Options v'
    $script:AutoChart06.Controls.Remove($script:AutoChart06ManipulationPanel)
    $script:AutoChart07OptionsButton.Text = 'Options v'
    $script:AutoChart07.Controls.Remove($script:AutoChart07ManipulationPanel)
    $script:AutoChart08OptionsButton.Text = 'Options v'
    $script:AutoChart08.Controls.Remove($script:AutoChart08ManipulationPanel)
    $script:AutoChart09OptionsButton.Text = 'Options v'
    $script:AutoChart09.Controls.Remove($script:AutoChart09ManipulationPanel)
    $script:AutoChart10OptionsButton.Text = 'Options v'
    $script:AutoChart10.Controls.Remove($script:AutoChart10ManipulationPanel)
    $script:AutoChart11OptionsButton.Text = 'Options v'
    $script:AutoChart11.Controls.Remove($script:AutoChart10ManipulationPanel)
    $script:AutoChart12OptionsButton.Text = 'Options v'
    $script:AutoChart12.Controls.Remove($script:AutoChart10ManipulationPanel)
    $script:AutoChart13OptionsButton.Text = 'Options v'
    $script:AutoChart13.Controls.Remove($script:AutoChart10ManipulationPanel)
    $script:AutoChart14OptionsButton.Text = 'Options v'
    $script:AutoChart14.Controls.Remove($script:AutoChart10ManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Dashboard Overview'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter'
}


$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartsMainLabel01)

$script:AutoChartDataSourceXmlPath = $null
function AutoChartOpenDataInShell {
    param(
        $MostRecentCollection
    )
    $ViewImportResults = $MostRecentCollection -replace '.csv','.xml'

    if (Test-Path $ViewImportResults) {
        $SavePath = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename
        $FileName = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename -Leaf

        script:Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}

















##############################################################################################
# AutoChart01
##############################################################################################

$script:AutoChartProcessesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Processes') { $script:AutoChartProcessesCSVFileMatch += $CSVFile } }
}
$script:AutoChartProcessesCSVFileMostRecentCollection = $script:AutoChartProcessesCSVFileMatch | Select-Object -Last 1
$script:AutoChartProcessesDataSource = Import-Csv $script:AutoChartProcessesCSVFileMostRecentCollection

### Auto Create Charts Object
$script:AutoChart01 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01.Titles.Add($script:AutoChart01Title)

### Create Charts Area
$script:AutoChart01Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01Area.Name        = 'Chart Area'
$script:AutoChart01Area.AxisX.Title = 'Hosts'
$script:AutoChart01Area.AxisX.Interval          = 1
$script:AutoChart01Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart01Area.Area3DStyle.Enable3D    = $false
$script:AutoChart01Area.Area3DStyle.Inclination = 75
$script:AutoChart01.ChartAreas.Add($script:AutoChart01Area)

### Auto Create Charts Data Series Recent
$script:AutoChart01.Series.Add("Unique Processes")
$script:AutoChart01.Series["Unique Processes"].Enabled           = $True
$script:AutoChart01.Series["Unique Processes"].BorderWidth       = 1
$script:AutoChart01.Series["Unique Processes"].IsVisibleInLegend = $false
$script:AutoChart01.Series["Unique Processes"].Chartarea         = 'Chart Area'
$script:AutoChart01.Series["Unique Processes"].Legend            = 'Legend'
$script:AutoChart01.Series["Unique Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01.Series["Unique Processes"]['PieLineColor']   = 'Black'
$script:AutoChart01.Series["Unique Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01.Series["Unique Processes"].ChartType         = 'Column'
$script:AutoChart01.Series["Unique Processes"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01CsvFileHosts      = $script:AutoChartProcessesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart01UniqueDataFields  = $script:AutoChartProcessesDataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01.Series["Unique Processes"].Points.Clear()

            if ($script:AutoChart01UniqueDataFields.count -gt 0){
                $script:AutoChart01Title.ForeColor = 'Black'
                $script:AutoChart01Title.Text = "Unique Processes"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart01OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01CsvComputers = @()
                    foreach ( $Line in $script:AutoChartProcessesDataSource ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart01CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart01UniqueCount = $script:AutoChart01CsvComputers.Count
                    $script:AutoChart01DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01UniqueCount
                        Computers   = $script:AutoChart01CsvComputers
                    }
                    $script:AutoChart01OverallDataResults += $script:AutoChart01DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01TrimOffLastTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
                $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
            }
            else {
                $script:AutoChart01Title.ForeColor = 'Red'
                $script:AutoChart01Title.Text = "Unique Processes`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01OptionsButton
$script:AutoChart01OptionsButton.Add_Click({
    if ($script:AutoChart01OptionsButton.Text -eq 'Options v') {
        $script:AutoChart01OptionsButton.Text = 'Options ^'
        $script:AutoChart01.Controls.Add($script:AutoChart01ManipulationPanel)
    }
    elseif ($script:AutoChart01OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01OptionsButton.Text = 'Options v'
        $script:AutoChart01.Controls.Remove($script:AutoChart01ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01)


$script:AutoChart01ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
    $script:AutoChart01TrimOffFirstTrackBarValue   = 0
    $script:AutoChart01TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01TrimOffFirstTrackBarValue = $script:AutoChart01TrimOffFirstTrackBar.Value
        $script:AutoChart01TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01TrimOffFirstTrackBar.Value)"
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01TrimOffFirstGroupBox.Controls.Add($script:AutoChart01TrimOffFirstTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X + $script:AutoChart01TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01TrimOffLastTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
    $script:AutoChart01TrimOffLastTrackBar.Value         = $($script:AutoChart01OverallDataResults.count)
    $script:AutoChart01TrimOffLastTrackBarValue   = 0
    $script:AutoChart01TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01TrimOffLastTrackBarValue = $($script:AutoChart01OverallDataResults.count) - $script:AutoChart01TrimOffLastTrackBar.Value
        $script:AutoChart01TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01OverallDataResults.count) - $script:AutoChart01TrimOffLastTrackBar.Value)"
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01TrimOffLastGroupBox.Controls.Add($script:AutoChart01TrimOffLastTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y + $script:AutoChart01TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01.Series["Unique Processes"].ChartType = $script:AutoChart01ChartTypeComboBox.SelectedItem
#    $script:AutoChart01.Series["Unique Processes"].Points.Clear()
#    $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ChartTypesAvailable) { $script:AutoChart01ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart013DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ChartTypeComboBox.Location.X + $script:AutoChart01ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart013DToggleButton
$script:AutoChart013DInclination = 0
$script:AutoChart013DToggleButton.Add_Click({

    $script:AutoChart013DInclination += 10
    if ( $script:AutoChart013DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)"
#        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart013DInclination -le 90 ) {
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)"
#        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart013DToggleButton.Text  = "3D Off"
        $script:AutoChart013DInclination = 0
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart013DToggleButton)

### Change the color of the chart
$script:AutoChart01ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart013DToggleButton.Location.X + $script:AutoChart013DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart013DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ColorsAvailable) { $script:AutoChart01ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01.Series["Unique Processes"].Color = $script:AutoChart01ChangeColorComboBox.SelectedItem
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01ImportCsvPosResults = $script:AutoChartProcessesDataSource | Where-Object 'Name' -eq $($script:AutoChart01InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart01InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ImportCsvAll = $script:AutoChartProcessesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart01ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvNegResults) { $script:AutoChart01InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ImportCsvPosResults.count))"
    $script:AutoChart01InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01TrimOffLastGroupBox.Location.X + $script:AutoChart01TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01CheckDiffButton
$script:AutoChart01CheckDiffButton.Add_Click({
    $script:AutoChart01InvestDiffDropDownArraY = $script:AutoChartProcessesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01InvestDiffDropDownLabel.Location.y + $script:AutoChart01InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01InvestDiffDropDownArray) { $script:AutoChart01InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01InvestDiffDropDownComboBox.Location.y + $script:AutoChart01InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01InvestDiffExecuteButton
    $script:AutoChart01InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01InvestDiffExecuteButton.Location.y + $script:AutoChart01InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y + $script:AutoChart01InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart01InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01InvestDiffPosResultsLabel.Location.x + $script:AutoChart01InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01InvestDiffNegResultsLabel.Location.y + $script:AutoChart01InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01InvestDiffForm.Controls.AddRange(@($script:AutoChart01InvestDiffDropDownLabel,$script:AutoChart01InvestDiffDropDownComboBox,$script:AutoChart01InvestDiffExecuteButton,$script:AutoChart01InvestDiffPosResultsLabel,$script:AutoChart01InvestDiffPosResultsTextBox,$script:AutoChart01InvestDiffNegResultsLabel,$script:AutoChart01InvestDiffNegResultsTextBox))
    $script:AutoChart01InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01InvestDiffForm.ShowDialog()
})
$script:AutoChart01CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01CheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01CheckDiffButton.Location.X + $script:AutoChart01CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartProcessesDataSourceFileName -QueryName "Processes" -QueryTabName "Unique Processes" -PropertyX "Name" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01ManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01CheckDiffButton.Location.X
                   Y = $script:AutoChart01CheckDiffButton.Location.Y + $script:AutoChart01CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01OpenInShell
$script:AutoChart01OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartProcessesCSVFileMostRecentCollection })
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01OpenInShell)


$script:AutoChart01ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01OpenInShell.Location.X + $script:AutoChart01OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ViewResults
$script:AutoChart01ViewResults.Add_Click({ $script:AutoChartProcessesDataSource | Out-GridView -Title "$script:AutoChartProcessesCSVFileMostRecentCollection" })
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01ViewResults)


### Save the chart to file
$script:AutoChart01SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01OpenInShell.Location.X
                  Y = $script:AutoChart01OpenInShell.Location.Y + $script:AutoChart01OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01 -Title $script:AutoChart01Title
})
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SaveButton.Location.X
                        Y = $script:AutoChart01SaveButton.Location.Y + $script:AutoChart01SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01NoticeTextbox)

$script:AutoChart01.Series["Unique Processes"].Points.Clear()
$script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01.Location.X + $script:AutoChart01.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02.Titles.Add($script:AutoChart02Title)

### Create Charts Area
$script:AutoChart02Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02Area.Name        = 'Chart Area'
$script:AutoChart02Area.AxisX.Title = 'Hosts'
$script:AutoChart02Area.AxisX.Interval          = 1
$script:AutoChart02Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart02Area.Area3DStyle.Enable3D    = $false
$script:AutoChart02Area.Area3DStyle.Inclination = 75
$script:AutoChart02.ChartAreas.Add($script:AutoChart02Area)

### Auto Create Charts Data Series Recent
$script:AutoChart02.Series.Add("Processes Per Host")
$script:AutoChart02.Series["Processes Per Host"].Enabled           = $True
$script:AutoChart02.Series["Processes Per Host"].BorderWidth       = 1
$script:AutoChart02.Series["Processes Per Host"].IsVisibleInLegend = $false
$script:AutoChart02.Series["Processes Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02.Series["Processes Per Host"].Legend            = 'Legend'
$script:AutoChart02.Series["Processes Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02.Series["Processes Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02.Series["Processes Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02.Series["Processes Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02.Series["Processes Per Host"].Color             = 'Red'

        function Generate-AutoChart02 {
            $script:AutoChart02CsvFileHosts     = ($script:AutoChartProcessesDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart02UniqueDataFields = ($script:AutoChartProcessesDataSource).ProcessID | Sort-Object -Property 'ProcessID'

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02UniqueDataFields.count -gt 0){
                $script:AutoChart02Title.ForeColor = 'Black'
                $script:AutoChart02Title.Text = "Processes Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartProcessesDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.ComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.ComputerName ) { $AutoChart02Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart02CurrentComputer ) {
                            $AutoChart02CurrentComputer = $Line.ComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer
                            }
                            $script:AutoChart02OverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.ComputerName ) { $AutoChart02Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }
                $script:AutoChart02OverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02OverallDataResults | ForEach-Object { $script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
                $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02TrimOffLastTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
                $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
            }
            else {
                $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
                $script:AutoChart02Title.ForeColor = 'Red'
                $script:AutoChart02Title.Text = "Processes Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02OptionsButton
$script:AutoChart02OptionsButton.Add_Click({
    if ($script:AutoChart02OptionsButton.Text -eq 'Options v') {
        $script:AutoChart02OptionsButton.Text = 'Options ^'
        $script:AutoChart02.Controls.Add($script:AutoChart02ManipulationPanel)
    }
    elseif ($script:AutoChart02OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02OptionsButton.Text = 'Options v'
        $script:AutoChart02.Controls.Remove($script:AutoChart02ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02)

$script:AutoChart02ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
    $script:AutoChart02TrimOffFirstTrackBarValue   = 0
    $script:AutoChart02TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02TrimOffFirstTrackBarValue = $script:AutoChart02TrimOffFirstTrackBar.Value
        $script:AutoChart02TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02TrimOffFirstTrackBar.Value)"
        $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02TrimOffFirstGroupBox.Controls.Add($script:AutoChart02TrimOffFirstTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X + $script:AutoChart02TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02TrimOffLastTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
    $script:AutoChart02TrimOffLastTrackBar.Value         = $($script:AutoChart02OverallDataResults.count)
    $script:AutoChart02TrimOffLastTrackBarValue   = 0
    $script:AutoChart02TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02TrimOffLastTrackBarValue = $($script:AutoChart02OverallDataResults.count) - $script:AutoChart02TrimOffLastTrackBar.Value
        $script:AutoChart02TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02OverallDataResults.count) - $script:AutoChart02TrimOffLastTrackBar.Value)"
        $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02TrimOffLastGroupBox.Controls.Add($script:AutoChart02TrimOffLastTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y + $script:AutoChart02TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02.Series["Processes Per Host"].ChartType = $script:AutoChart02ChartTypeComboBox.SelectedItem
#    $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
#    $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ChartTypesAvailable) { $script:AutoChart02ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart023DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ChartTypeComboBox.Location.X + $script:AutoChart02ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart023DToggleButton
$script:AutoChart023DInclination = 0
$script:AutoChart023DToggleButton.Add_Click({
    $script:AutoChart023DInclination += 10
    if ( $script:AutoChart023DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)"
#        $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart023DInclination -le 90 ) {
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)"
#        $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart023DToggleButton.Text  = "3D Off"
        $script:AutoChart023DInclination = 0
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart023DToggleButton)

### Change the color of the chart
$script:AutoChart02ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart023DToggleButton.Location.X + $script:AutoChart023DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart023DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ColorsAvailable) { $script:AutoChart02ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02.Series["Processes Per Host"].Color = $script:AutoChart02ChangeColorComboBox.SelectedItem
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02ImportCsvPosResults = $script:AutoChartProcessesDataSource | Where-Object 'Name' -eq $($script:AutoChart02InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart02InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ImportCsvAll = $script:AutoChartProcessesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart02ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvNegResults) { $script:AutoChart02InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ImportCsvPosResults.count))"
    $script:AutoChart02InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02TrimOffLastGroupBox.Location.X + $script:AutoChart02TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02CheckDiffButton
$script:AutoChart02CheckDiffButton.Add_Click({
    $script:AutoChart02InvestDiffDropDownArraY = $script:AutoChartProcessesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02InvestDiffDropDownLabel.Location.y + $script:AutoChart02InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02InvestDiffDropDownArray) { $script:AutoChart02InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02InvestDiffDropDownComboBox.Location.y + $script:AutoChart02InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02InvestDiffExecuteButton
    $script:AutoChart02InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02InvestDiffExecuteButton.Location.y + $script:AutoChart02InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y + $script:AutoChart02InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart02InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02InvestDiffPosResultsLabel.Location.x + $script:AutoChart02InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02InvestDiffNegResultsLabel.Location.y + $script:AutoChart02InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02InvestDiffForm.Controls.AddRange(@($script:AutoChart02InvestDiffDropDownLabel,$script:AutoChart02InvestDiffDropDownComboBox,$script:AutoChart02InvestDiffExecuteButton,$script:AutoChart02InvestDiffPosResultsLabel,$script:AutoChart02InvestDiffPosResultsTextBox,$script:AutoChart02InvestDiffNegResultsLabel,$script:AutoChart02InvestDiffNegResultsTextBox))
    $script:AutoChart02InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02InvestDiffForm.ShowDialog()
})
$script:AutoChart02CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02CheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02CheckDiffButton.Location.X + $script:AutoChart02CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartProcessesDataSourceFileName -QueryName "Processes" -QueryTabName "Processes per Endpoint" -PropertyX "ComputerName" -PropertyY "ProcessID" }
}
Apply-CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02ManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02CheckDiffButton.Location.X
                   Y = $script:AutoChart02CheckDiffButton.Location.Y + $script:AutoChart02CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02OpenInShell
$script:AutoChart02OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartProcessesCSVFileMostRecentCollection })
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02OpenInShell)


$script:AutoChart02ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02OpenInShell.Location.X + $script:AutoChart02OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ViewResults
$script:AutoChart02ViewResults.Add_Click({ $script:AutoChartProcessesDataSource | Out-GridView -Title "$script:AutoChartProcessesCSVFileMostRecentCollection" })
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02ViewResults)


### Save the chart to file
$script:AutoChart02SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02OpenInShell.Location.X
                  Y = $script:AutoChart02OpenInShell.Location.Y + $script:AutoChart02OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02 -Title $script:AutoChart02Title
})
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SaveButton.Location.X
                        Y = $script:AutoChart02SaveButton.Location.Y + $script:AutoChart02SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02NoticeTextbox)

$script:AutoChart02.Series["Processes Per Host"].Points.Clear()
$script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

$script:AutoChartServicesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Services') { $script:AutoChartServicesCSVFileMatch += $CSVFile } }
}
$script:AutoChartServicesCSVFileMostRecentCollection = $script:AutoChartServicesCSVFileMatch | Select-Object -Last 1
$script:AutoChartServicesDataSource = Import-Csv $script:AutoChartServicesCSVFileMostRecentCollection


### Auto Create Charts Object
$script:AutoChart03 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01.Location.X
                  Y = $script:AutoChart01.Location.Y + $script:AutoChart01.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03.Titles.Add($script:AutoChart03Title)

### Create Charts Area
$script:AutoChart03Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03Area.Name        = 'Chart Area'
$script:AutoChart03Area.AxisX.Title = 'Hosts'
$script:AutoChart03Area.AxisX.Interval          = 1
$script:AutoChart03Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart03Area.Area3DStyle.Enable3D    = $false
$script:AutoChart03Area.Area3DStyle.Inclination = 75
$script:AutoChart03.ChartAreas.Add($script:AutoChart03Area)

### Auto Create Charts Data Series Recent
$script:AutoChart03.Series.Add("Running Services")
$script:AutoChart03.Series["Running Services"].Enabled           = $True
$script:AutoChart03.Series["Running Services"].BorderWidth       = 1
$script:AutoChart03.Series["Running Services"].IsVisibleInLegend = $false
$script:AutoChart03.Series["Running Services"].Chartarea         = 'Chart Area'
$script:AutoChart03.Series["Running Services"].Legend            = 'Legend'
$script:AutoChart03.Series["Running Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03.Series["Running Services"]['PieLineColor']   = 'Black'
$script:AutoChart03.Series["Running Services"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03.Series["Running Services"].ChartType         = 'Column'
$script:AutoChart03.Series["Running Services"].Color             = 'Blue'

        function Generate-AutoChart03 ($Filter) {
            $script:AutoChart03CsvFileHosts     = $script:AutoChartServicesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart03UniqueDataFields = $script:AutoChartServicesDataSource | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03.Series["Running Services"].Points.Clear()

            if ($script:AutoChart03UniqueDataFields.count -gt 0){
                $script:AutoChart03Title.ForeColor = 'Black'
                $script:AutoChart03Title.Text = "$Filter Services"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart03OverallDataResults = @()

                $FilteredData = $script:AutoChartServicesDataSource | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"}

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03CsvComputers = @()

                    foreach ( $Line in $FilteredData ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart03CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart03CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart03UniqueCount = $script:AutoChart03CsvComputers.Count
                    $script:AutoChart03DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03UniqueCount
                        Computers   = $script:AutoChart03CsvComputers
                    }
                    $script:AutoChart03OverallDataResults += $script:AutoChart03DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
                $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
            }
            else {
                $script:AutoChart03Title.ForeColor = 'Red'
                $script:AutoChart03Title.Text = "$Filter Services`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart03 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03OptionsButton
$script:AutoChart03OptionsButton.Add_Click({
    if ($script:AutoChart03OptionsButton.Text -eq 'Options v') {
        $script:AutoChart03OptionsButton.Text = 'Options ^'
        $script:AutoChart03.Controls.Add($script:AutoChart03ManipulationPanel)
    }
    elseif ($script:AutoChart03OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03OptionsButton.Text = 'Options v'
        $script:AutoChart03.Controls.Remove($script:AutoChart03ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03OptionsButton)

# A filter combobox to modify what is displayed
$script:AutoChart03FilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running'
    Location  = @{ X = $script:AutoChart03OptionsButton.Location.X + 1
                    Y = $script:AutoChart03OptionsButton.Location.Y - $script:AutoChart03OptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03FilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart03 -Filter $script:AutoChart03FilterComboBox.SelectedItem
#    $script:AutoChart03.Series["Running Services"].Points.Clear()
#    $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart03FilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:AutoChart03FilterAvailable) { $script:AutoChart03FilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03FilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03)
$script:AutoChart03FilterComboBox.SelectedIndeX = 0


$script:AutoChart03ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
    $script:AutoChart03TrimOffFirstTrackBarValue   = 0
    $script:AutoChart03TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffFirstTrackBarValue = $script:AutoChart03TrimOffFirstTrackBar.Value
        $script:AutoChart03TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03TrimOffFirstTrackBar.Value)"
        $script:AutoChart03.Series["Running Services"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart03TrimOffFirstGroupBox.Controls.Add($script:AutoChart03TrimOffFirstTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + $script:AutoChart03TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }

    $script:AutoChart03TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
    $script:AutoChart03TrimOffLastTrackBar.Value         = $($script:AutoChart03OverallDataResults.count)
    $script:AutoChart03TrimOffLastTrackBarValue          = 0
    $script:AutoChart03TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffLastTrackBarValue = $($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value
        $script:AutoChart03TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value)"
        $script:AutoChart03.Series["Running Services"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart03TrimOffLastGroupBox.Controls.Add($script:AutoChart03TrimOffLastTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y + $script:AutoChart03TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03.Series["Running Services"].ChartType = $script:AutoChart03ChartTypeComboBox.SelectedItem
#    $script:AutoChart03.Series["Running Services"].Points.Clear()
#    $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart03ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ChartTypesAvailable) { $script:AutoChart03ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart033DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ChartTypeComboBox.Location.X + $script:AutoChart03ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart033DToggleButton
$script:AutoChart033DInclination = 0
$script:AutoChart033DToggleButton.Add_Click({

    $script:AutoChart033DInclination += 10
    if ( $script:AutoChart033DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)"
#        $script:AutoChart03.Series["Running Services"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart033DInclination -le 90 ) {
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)"
#        $script:AutoChart03.Series["Running Services"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart033DToggleButton.Text  = "3D Off"
        $script:AutoChart033DInclination = 0
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03.Series["Running Services"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart033DToggleButton)

### Change the color of the chart
$script:AutoChart03ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart033DToggleButton.Location.X + $script:AutoChart033DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart033DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ColorsAvailable) { $script:AutoChart03ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03.Series["Running Services"].Color = $script:AutoChart03ChangeColorComboBox.SelectedItem
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 ($Filter) {
    # List of Positive Endpoints that positively match
    $script:AutoChart03ImportCsvPosResults = $script:AutoChartServicesDataSource | Where-Object 'Name' -eq $($script:AutoChart03InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart03InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ImportCsvAll = $script:AutoChartServicesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart03ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvNegResults) { $script:AutoChart03InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ImportCsvPosResults.count))"
    $script:AutoChart03InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03TrimOffLastGroupBox.Location.X + $script:AutoChart03TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
Apply-CommonButtonSettings -Button $script:AutoChart03CheckDiffButton
$script:AutoChart03CheckDiffButton.Add_Click({
    $script:AutoChart03InvestDiffDropDownArraY = $script:AutoChartServicesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03InvestDiffDropDownLabel.Location.y + $script:AutoChart03InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03InvestDiffDropDownArray) { $script:AutoChart03InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03  -Filter $script:AutoChart03FilterComboBox.SelectedItem }})
    $script:AutoChart03InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 -Filter $script:AutoChart03FilterComboBox.SelectedItem })

    ### Investigate Difference Execute Button
    $script:AutoChart03InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03InvestDiffDropDownComboBox.Location.y + $script:AutoChart03InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03InvestDiffExecuteButton
    $script:AutoChart03InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 -Filter $script:AutoChart03FilterComboBox.SelectedItem }})
    $script:AutoChart03InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 -Filter $script:AutoChart03FilterComboBox.SelectedItem })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03InvestDiffExecuteButton.Location.y + $script:AutoChart03InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y + $script:AutoChart03InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart03InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03InvestDiffPosResultsLabel.Location.x + $script:AutoChart03InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03InvestDiffNegResultsLabel.Location.y + $script:AutoChart03InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03InvestDiffForm.Controls.AddRange(@($script:AutoChart03InvestDiffDropDownLabel,$script:AutoChart03InvestDiffDropDownComboBox,$script:AutoChart03InvestDiffExecuteButton,$script:AutoChart03InvestDiffPosResultsLabel,$script:AutoChart03InvestDiffPosResultsTextBox,$script:AutoChart03InvestDiffNegResultsLabel,$script:AutoChart03InvestDiffNegResultsTextBox))
    $script:AutoChart03InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03InvestDiffForm.ShowDialog()
})
$script:AutoChart03CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03CheckDiffButton)


$script:AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03CheckDiffButton.Location.X + $script:AutoChart03CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ExpandChartButton
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ExpandChartButton)


$script:AutoChart03OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03CheckDiffButton.Location.X
                   Y = $script:AutoChart03CheckDiffButton.Location.Y + $script:AutoChart03CheckDiffButton.Size.Height + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03OpenInShell
$script:AutoChart03OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartServicesCSVFileMostRecentCollection })
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03OpenInShell)


$script:AutoChart03Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03OpenInShell.Location.X + $script:AutoChart03OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03Results
$script:AutoChart03Results.Add_Click({ $script:AutoChartServicesDataSource | Out-GridView -Title "$script:AutoChartServicesCSVFileMostRecentCollection" })
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03Results)

### Save the chart to file
$script:AutoChart03SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03OpenInShell.Location.X
                  Y = $script:AutoChart03OpenInShell.Location.Y + $script:AutoChart03OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03 -Title $script:AutoChart03Title
})
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SaveButton.Location.X
                        Y = $script:AutoChart03SaveButton.Location.Y + $script:AutoChart03SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03NoticeTextbox)

$script:AutoChart03.Series["Running Services"].Points.Clear()
$script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02.Location.X
                  Y = $script:AutoChart02.Location.Y + $script:AutoChart02.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart04.Titles.Add($script:AutoChart04Title)

### Create Charts Area
$script:AutoChart04Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04Area.Name        = 'Chart Area'
$script:AutoChart04Area.AxisX.Title = 'Hosts'
$script:AutoChart04Area.AxisX.Interval          = 1
$script:AutoChart04Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart04Area.Area3DStyle.Enable3D    = $false
$script:AutoChart04Area.Area3DStyle.Inclination = 75
$script:AutoChart04.ChartAreas.Add($script:AutoChart04Area)

### Auto Create Charts Data Series Recent
$script:AutoChart04.Series.Add("Running Services Per Host")
$script:AutoChart04.Series["Running Services Per Host"].Enabled           = $True
$script:AutoChart04.Series["Running Services Per Host"].BorderWidth       = 1
$script:AutoChart04.Series["Running Services Per Host"].IsVisibleInLegend = $false
$script:AutoChart04.Series["Running Services Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart04.Series["Running Services Per Host"].Legend            = 'Legend'
$script:AutoChart04.Series["Running Services Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04.Series["Running Services Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart04.Series["Running Services Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04.Series["Running Services Per Host"].ChartType         = 'DoughNut'
$script:AutoChart04.Series["Running Services Per Host"].Color             = 'Blue'

        function Generate-AutoChart04 ($Filter) {
            $script:AutoChart04CsvFileHosts     = $script:AutoChartServicesDataSource | Select-Object -Property 'ComputerName' -ExpandProperty 'ComputerName' | Sort-Object -Unique
            $script:AutoChart04UniqueDataFields = $script:AutoChartServicesDataSource | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object  -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart04UniqueDataFields.count -gt 0){
                $script:AutoChart04Title.ForeColor = 'Black'
                $script:AutoChart04Title.Text = "$Filter Services Per Host"

                $AutoChart04CurrentComputer  = ''
                $AutoChart04CheckIfFirstLine = $false
                $AutoChart04ResultsCount     = 0
                $AutoChart04Computer         = @()
                $AutoChart04YResults         = @()
                $script:AutoChart04OverallDataResults = @()

                $FilteredData = $script:AutoChartServicesDataSource | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Sort-Object ComputerName

                foreach ( $Line in $FilteredData ) {
                    if ( $AutoChart04CheckIfFirstLine -eq $false ) { $AutoChart04CurrentComputer  = $Line.ComputerName ; $AutoChart04CheckIfFirstLine = $true }
                    if ( $AutoChart04CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart04CurrentComputer ) {
                            if ( $AutoChart04YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart04YResults += $Line.Name ; $AutoChart04ResultsCount += 1 }
                                if ( $AutoChart04Computer -notcontains $Line.ComputerName ) { $AutoChart04Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart04CurrentComputer ) {
                            $AutoChart04CurrentComputer = $Line.ComputerName
                            $AutoChart04YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart04ResultsCount
                                Computer     = $AutoChart04Computer
                            }
                            $script:AutoChart04OverallDataResults += $AutoChart04YDataResults
                            $AutoChart04YResults     = @()
                            $AutoChart04ResultsCount = 0
                            $AutoChart04Computer     = @()
                            if ( $AutoChart04YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart04YResults += $Line.Name ; $AutoChart04ResultsCount += 1 }
                                if ( $AutoChart04Computer -notcontains $Line.ComputerName ) { $AutoChart04Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart04YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart04ResultsCount ; Computer = $AutoChart04Computer }
                $script:AutoChart04OverallDataResults += $AutoChart04YDataResults
                $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | ForEach-Object { $script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
                $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart04TrimOffLastTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
                $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
            }
            else {
                $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
                $script:AutoChart04Title.ForeColor = 'Red'
                $script:AutoChart04Title.Text = "$Filter Services Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart04 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04OptionsButton
$script:AutoChart04OptionsButton.Add_Click({
    if ($script:AutoChart04OptionsButton.Text -eq 'Options v') {
        $script:AutoChart04OptionsButton.Text = 'Options ^'
        $script:AutoChart04.Controls.Add($script:AutoChart04ManipulationPanel)
    }
    elseif ($script:AutoChart04OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04OptionsButton.Text = 'Options v'
        $script:AutoChart04.Controls.Remove($script:AutoChart04ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04OptionsButton)

# A filter combobox to modify what is displayed
$script:AutoChart04FilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running'
    Location  = @{ X = $script:AutoChart04OptionsButton.Location.X + 1
                    Y = $script:AutoChart04OptionsButton.Location.Y - $script:AutoChart04OptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04FilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart04 -Filter $script:AutoChart04FilterComboBox.SelectedItem
#    $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
#    $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart04FilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:AutoChart04FilterAvailable) { $script:AutoChart04FilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04FilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04)
$script:AutoChart04FilterComboBox.SelectedIndeX = 0


$script:AutoChart04ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
    $script:AutoChart04TrimOffFirstTrackBarValue   = 0
    $script:AutoChart04TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04TrimOffFirstTrackBarValue = $script:AutoChart04TrimOffFirstTrackBar.Value
        $script:AutoChart04TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04TrimOffFirstTrackBar.Value)"
        $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart04TrimOffFirstGroupBox.Controls.Add($script:AutoChart04TrimOffFirstTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + $script:AutoChart04TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                        Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04TrimOffLastTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
    $script:AutoChart04TrimOffLastTrackBar.Value         = $($script:AutoChart04OverallDataResults.count)
    $script:AutoChart04TrimOffLastTrackBarValue   = 0
    $script:AutoChart04TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04TrimOffLastTrackBarValue = $($script:AutoChart04OverallDataResults.count) - $script:AutoChart04TrimOffLastTrackBar.Value
        $script:AutoChart04TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04OverallDataResults.count) - $script:AutoChart04TrimOffLastTrackBar.Value)"
        $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart04TrimOffLastGroupBox.Controls.Add($script:AutoChart04TrimOffLastTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y + $script:AutoChart04TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04.Series["Running Services Per Host"].ChartType = $script:AutoChart04ChartTypeComboBox.SelectedItem
#    $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
#    $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart04ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ChartTypesAvailable) { $script:AutoChart04ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart043DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ChartTypeComboBox.Location.X + $script:AutoChart04ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart043DToggleButton
$script:AutoChart043DInclination = 0
$script:AutoChart043DToggleButton.Add_Click({
    $script:AutoChart043DInclination += 10
    if ( $script:AutoChart043DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)"
#        $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart043DInclination -le 90 ) {
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)"
#        $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart043DToggleButton.Text  = "3D Off"
        $script:AutoChart043DInclination = 0
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart043DToggleButton)

### Change the color of the chart
$script:AutoChart04ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart043DToggleButton.Location.X + $script:AutoChart043DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart043DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ColorsAvailable) { $script:AutoChart04ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04.Series["Running Services Per Host"].Color = $script:AutoChart04ChangeColorComboBox.SelectedItem
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04ImportCsvPosResults = $script:AutoChartServicesDataSource | Where-Object 'Name' -eq $($script:AutoChart04InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart04InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ImportCsvAll = $script:AutoChartServicesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart04ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvNegResults) { $script:AutoChart04InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ImportCsvPosResults.count))"
    $script:AutoChart04InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04TrimOffLastGroupBox.Location.X + $script:AutoChart04TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04CheckDiffButton
$script:AutoChart04CheckDiffButton.Add_Click({
    $script:AutoChart04InvestDiffDropDownArraY = $script:AutoChartServicesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04InvestDiffDropDownLabel.Location.y + $script:AutoChart04InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04InvestDiffDropDownArray) { $script:AutoChart04InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04InvestDiffDropDownComboBox.Location.y + $script:AutoChart04InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04InvestDiffExecuteButton
    $script:AutoChart04InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04InvestDiffExecuteButton.Location.y + $script:AutoChart04InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y + $script:AutoChart04InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart04InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04InvestDiffPosResultsLabel.Location.x + $script:AutoChart04InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04InvestDiffNegResultsLabel.Location.y + $script:AutoChart04InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04InvestDiffForm.Controls.AddRange(@($script:AutoChart04InvestDiffDropDownLabel,$script:AutoChart04InvestDiffDropDownComboBox,$script:AutoChart04InvestDiffExecuteButton,$script:AutoChart04InvestDiffPosResultsLabel,$script:AutoChart04InvestDiffPosResultsTextBox,$script:AutoChart04InvestDiffNegResultsLabel,$script:AutoChart04InvestDiffNegResultsTextBox))
    $script:AutoChart04InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04InvestDiffForm.ShowDialog()
})
$script:AutoChart04CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04CheckDiffButton)


$script:AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04CheckDiffButton.Location.X + $script:AutoChart04CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Services per Endpoint" -PropertyX "ComputerName" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ExpandChartButton
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ExpandChartButton)


$script:AutoChart04OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04CheckDiffButton.Location.X
                   Y = $script:AutoChart04CheckDiffButton.Location.Y + $script:AutoChart04CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04OpenInShell
$script:AutoChart04OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartServicesCSVFileMostRecentCollection })
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04OpenInShell)


$script:AutoChart04Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04OpenInShell.Location.X + $script:AutoChart04OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04Results
$script:AutoChart04Results.Add_Click({ $script:AutoChartServicesDataSource | Out-GridView -Title "$script:AutoChartServicesCSVFileMostRecentCollection" })
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04Results)

### Save the chart to file
$script:AutoChart04SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04OpenInShell.Location.X
                  Y = $script:AutoChart04OpenInShell.Location.Y + $script:AutoChart04OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04 -Title $script:AutoChart04Title
})
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SaveButton.Location.X
                        Y = $script:AutoChart04SaveButton.Location.Y + $script:AutoChart04SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04NoticeTextbox)

$script:AutoChart04.Series["Running Services Per Host"].Points.Clear()
$script:AutoChart04OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}






















##############################################################################################
# AutoChart05
##############################################################################################

$script:AutoChartSoftwareCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Software') { $script:AutoChartSoftwareCSVFileMatch += $CSVFile } }
}
$script:AutoChartSoftwareCSVFileMostRecentCollection = $script:AutoChartSoftwareCSVFileMatch | Select-Object -Last 1
$script:AutoChartSoftwareDataSource = Import-Csv $script:AutoChartSoftwareCSVFileMostRecentCollection



### Auto Create Charts Object
$script:AutoChart05 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03.Location.X
                  Y = $script:AutoChart03.Location.Y + $script:AutoChart03.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05.Titles.Add($script:AutoChart05Title)

### Create Charts Area
$script:AutoChart05Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05Area.Name        = 'Chart Area'
$script:AutoChart05Area.AxisX.Title = 'Hosts'
$script:AutoChart05Area.AxisX.Interval          = 1
$script:AutoChart05Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart05Area.Area3DStyle.Enable3D    = $false
$script:AutoChart05Area.Area3DStyle.Inclination = 75
$script:AutoChart05.ChartAreas.Add($script:AutoChart05Area)

### Auto Create Charts Data Series Recent
$script:AutoChart05.Series.Add("Software Names")
$script:AutoChart05.Series["Software Names"].Enabled           = $True
$script:AutoChart05.Series["Software Names"].BorderWidth       = 1
$script:AutoChart05.Series["Software Names"].IsVisibleInLegend = $false
$script:AutoChart05.Series["Software Names"].Chartarea         = 'Chart Area'
$script:AutoChart05.Series["Software Names"].Legend            = 'Legend'
$script:AutoChart05.Series["Software Names"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05.Series["Software Names"]['PieLineColor']   = 'Black'
$script:AutoChart05.Series["Software Names"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05.Series["Software Names"].ChartType         = 'Column'
$script:AutoChart05.Series["Software Names"].Color             = 'Green'

        function Generate-AutoChart05 {
            $script:AutoChart05CsvFileHosts      = $script:AutoChartSoftwareDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart05UniqueDataFields  = $script:AutoChartSoftwareDataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05.Series["Software Names"].Points.Clear()

            if ($script:AutoChart05UniqueDataFields.count -gt 0){
                $script:AutoChart05Title.ForeColor = 'Black'
                $script:AutoChart05Title.Text = "Software Names"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart05OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05CsvComputers = @()
                    foreach ( $Line in $script:AutoChartSoftwareDataSource ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart05CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart05CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart05UniqueCount = $script:AutoChart05CsvComputers.Count
                    $script:AutoChart05DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05UniqueCount
                        Computers   = $script:AutoChart05CsvComputers
                    }
                    $script:AutoChart05OverallDataResults += $script:AutoChart05DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart05TrimOffLastTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
                $script:AutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
            }
            else {
                $script:AutoChart05Title.ForeColor = 'Red'
                $script:AutoChart05Title.Text = "Software Names`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05OptionsButton
$script:AutoChart05OptionsButton.Add_Click({
    if ($script:AutoChart05OptionsButton.Text -eq 'Options v') {
        $script:AutoChart05OptionsButton.Text = 'Options ^'
        $script:AutoChart05.Controls.Add($script:AutoChart05ManipulationPanel)
    }
    elseif ($script:AutoChart05OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05OptionsButton.Text = 'Options v'
        $script:AutoChart05.Controls.Remove($script:AutoChart05ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05)


$script:AutoChart05ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
    $script:AutoChart05TrimOffFirstTrackBarValue   = 0
    $script:AutoChart05TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05TrimOffFirstTrackBarValue = $script:AutoChart05TrimOffFirstTrackBar.Value
        $script:AutoChart05TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05TrimOffFirstTrackBar.Value)"
        $script:AutoChart05.Series["Software Names"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart05TrimOffFirstGroupBox.Controls.Add($script:AutoChart05TrimOffFirstTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X + $script:AutoChart05TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05TrimOffLastTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
    $script:AutoChart05TrimOffLastTrackBar.Value         = $($script:AutoChart05OverallDataResults.count)
    $script:AutoChart05TrimOffLastTrackBarValue   = 0
    $script:AutoChart05TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05TrimOffLastTrackBarValue = $($script:AutoChart05OverallDataResults.count) - $script:AutoChart05TrimOffLastTrackBar.Value
        $script:AutoChart05TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05OverallDataResults.count) - $script:AutoChart05TrimOffLastTrackBar.Value)"
        $script:AutoChart05.Series["Software Names"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart05TrimOffLastGroupBox.Controls.Add($script:AutoChart05TrimOffLastTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y + $script:AutoChart05TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05.Series["Software Names"].ChartType = $script:AutoChart05ChartTypeComboBox.SelectedItem
#    $script:AutoChart05.Series["Software Names"].Points.Clear()
#    $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart05ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ChartTypesAvailable) { $script:AutoChart05ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart053DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ChartTypeComboBox.Location.X + $script:AutoChart05ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart053DToggleButton
$script:AutoChart053DInclination = 0
$script:AutoChart053DToggleButton.Add_Click({

    $script:AutoChart053DInclination += 10
    if ( $script:AutoChart053DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)"
#        $script:AutoChart05.Series["Software Names"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart053DInclination -le 90 ) {
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)"
#        $script:AutoChart05.Series["Software Names"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart053DToggleButton.Text  = "3D Off"
        $script:AutoChart053DInclination = 0
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05.Series["Software Names"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart053DToggleButton)

### Change the color of the chart
$script:AutoChart05ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart053DToggleButton.Location.X + $script:AutoChart053DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart053DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ColorsAvailable) { $script:AutoChart05ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05.Series["Software Names"].Color = $script:AutoChart05ChangeColorComboBox.SelectedItem
})
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {
    # List of Positive Endpoints that positively match
    $script:AutoChart05ImportCsvPosResults = $script:AutoChartSoftwareDataSource | Where-Object 'Name' -eq $($script:AutoChart05InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart05InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ImportCsvPosResults) { $script:AutoChart05InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ImportCsvAll = $script:AutoChartSoftwareDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart05ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ImportCsvPosResults) { $script:AutoChart05ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ImportCsvNegResults) { $script:AutoChart05InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ImportCsvPosResults.count))"
    $script:AutoChart05InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05TrimOffLastGroupBox.Location.X + $script:AutoChart05TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart05CheckDiffButton
$script:AutoChart05CheckDiffButton.Add_Click({
    $script:AutoChart05InvestDiffDropDownArraY = $script:AutoChartSoftwareDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05InvestDiffDropDownLabel.Location.y + $script:AutoChart05InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05InvestDiffDropDownArray) { $script:AutoChart05InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05InvestDiffDropDownComboBox.Location.y + $script:AutoChart05InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart05InvestDiffExecuteButton
    $script:AutoChart05InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05InvestDiffExecuteButton.Location.y + $script:AutoChart05InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y + $script:AutoChart05InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart05InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05InvestDiffPosResultsLabel.Location.x + $script:AutoChart05InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05InvestDiffNegResultsLabel.Location.y + $script:AutoChart05InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05InvestDiffForm.Controls.AddRange(@($script:AutoChart05InvestDiffDropDownLabel,$script:AutoChart05InvestDiffDropDownComboBox,$script:AutoChart05InvestDiffExecuteButton,$script:AutoChart05InvestDiffPosResultsLabel,$script:AutoChart05InvestDiffPosResultsTextBox,$script:AutoChart05InvestDiffNegResultsLabel,$script:AutoChart05InvestDiffNegResultsTextBox))
    $script:AutoChart05InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05InvestDiffForm.ShowDialog()
})
$script:AutoChart05CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05CheckDiffButton)


$AutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05CheckDiffButton.Location.X + $script:AutoChart05CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSoftwareDataSourceFileName -QueryName "Software" -QueryTabName "Software Names" -PropertyX "Name" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05ManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05CheckDiffButton.Location.X
                   Y = $script:AutoChart05CheckDiffButton.Location.Y + $script:AutoChart05CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05OpenInShell
$script:AutoChart05OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSoftwareCSVFileMostRecentCollection })
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05OpenInShell)


$script:AutoChart05ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05OpenInShell.Location.X + $script:AutoChart05OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ViewResults
$script:AutoChart05ViewResults.Add_Click({ $script:AutoChartSoftwareDataSource | Out-GridView -Title "$script:AutoChartSoftwareCSVFileMostRecentCollection" })
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05ViewResults)


### Save the chart to file
$script:AutoChart05SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05OpenInShell.Location.X
                  Y = $script:AutoChart05OpenInShell.Location.Y + $script:AutoChart05OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05 -Title $script:AutoChart05Title
})
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05SaveButton.Location.X
                        Y = $script:AutoChart05SaveButton.Location.Y + $script:AutoChart05SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05NoticeTextbox)

$script:AutoChart05.Series["Software Names"].Points.Clear()
$script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}






















##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04.Location.X
                  Y = $script:AutoChart04.Location.Y + $script:AutoChart04.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06.Titles.Add($script:AutoChart06Title)

### Create Charts Area
$script:AutoChart06Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06Area.Name        = 'Chart Area'
$script:AutoChart06Area.AxisX.Title = 'Hosts'
$script:AutoChart06Area.AxisX.Interval          = 1
$script:AutoChart06Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart06Area.Area3DStyle.Enable3D    = $false
$script:AutoChart06Area.Area3DStyle.Inclination = 75
$script:AutoChart06.ChartAreas.Add($script:AutoChart06Area)

### Auto Create Charts Data Series Recent
$script:AutoChart06.Series.Add("Software Count Per Host")
$script:AutoChart06.Series["Software Count Per Host"].Enabled           = $True
$script:AutoChart06.Series["Software Count Per Host"].BorderWidth       = 1
$script:AutoChart06.Series["Software Count Per Host"].IsVisibleInLegend = $false
$script:AutoChart06.Series["Software Count Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart06.Series["Software Count Per Host"].Legend            = 'Legend'
$script:AutoChart06.Series["Software Count Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06.Series["Software Count Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart06.Series["Software Count Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06.Series["Software Count Per Host"].ChartType         = 'DoughNut'
$script:AutoChart06.Series["Software Count Per Host"].Color             = 'Green'

        function Generate-AutoChart06 {
            $script:AutoChart06CsvFileHosts     = ($script:AutoChartSoftwareDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart06UniqueDataFields = ($script:AutoChartSoftwareDataSource).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart06UniqueDataFields.count -gt 0){
                $script:AutoChart06Title.ForeColor = 'Black'
                $script:AutoChart06Title.Text = "Software Count Per Host"

                $AutoChart06CurrentComputer  = ''
                $AutoChart06CheckIfFirstLine = $false
                $AutoChart06ResultsCount     = 0
                $AutoChart06Computer         = @()
                $AutoChart06YResults         = @()
                $script:AutoChart06OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartSoftwareDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart06CheckIfFirstLine -eq $false ) { $AutoChart06CurrentComputer  = $Line.ComputerName ; $AutoChart06CheckIfFirstLine = $true }
                    if ( $AutoChart06CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart06CurrentComputer ) {
                            if ( $AutoChart06YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart06YResults += $Line.Name ; $AutoChart06ResultsCount += 1 }
                                if ( $AutoChart06Computer -notcontains $Line.ComputerName ) { $AutoChart06Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart06CurrentComputer ) {
                            $AutoChart06CurrentComputer = $Line.ComputerName
                            $AutoChart06YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart06ResultsCount
                                Computer     = $AutoChart06Computer
                            }
                            $script:AutoChart06OverallDataResults += $AutoChart06YDataResults
                            $AutoChart06YResults     = @()
                            $AutoChart06ResultsCount = 0
                            $AutoChart06Computer     = @()
                            if ( $AutoChart06YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart06YResults += $Line.Name ; $AutoChart06ResultsCount += 1 }
                                if ( $AutoChart06Computer -notcontains $Line.ComputerName ) { $AutoChart06Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart06YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart06ResultsCount ; Computer = $AutoChart06Computer }
                $script:AutoChart06OverallDataResults += $AutoChart06YDataResults
                $script:AutoChart06OverallDataResults | ForEach-Object { $script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
                $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart06TrimOffLastTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
                $script:AutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
            }
            else {
                $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
                $script:AutoChart06Title.ForeColor = 'Red'
                $script:AutoChart06Title.Text = "Software Count Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06OptionsButton
$script:AutoChart06OptionsButton.Add_Click({
    if ($script:AutoChart06OptionsButton.Text -eq 'Options v') {
        $script:AutoChart06OptionsButton.Text = 'Options ^'
        $script:AutoChart06.Controls.Add($script:AutoChart06ManipulationPanel)
    }
    elseif ($script:AutoChart06OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06OptionsButton.Text = 'Options v'
        $script:AutoChart06.Controls.Remove($script:AutoChart06ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06)

$script:AutoChart06ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
    $script:AutoChart06TrimOffFirstTrackBarValue   = 0
    $script:AutoChart06TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06TrimOffFirstTrackBarValue = $script:AutoChart06TrimOffFirstTrackBar.Value
        $script:AutoChart06TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06TrimOffFirstTrackBar.Value)"
        $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart06TrimOffFirstGroupBox.Controls.Add($script:AutoChart06TrimOffFirstTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X + $script:AutoChart06TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06TrimOffLastTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
    $script:AutoChart06TrimOffLastTrackBar.Value         = $($script:AutoChart06OverallDataResults.count)
    $script:AutoChart06TrimOffLastTrackBarValue   = 0
    $script:AutoChart06TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06TrimOffLastTrackBarValue = $($script:AutoChart06OverallDataResults.count) - $script:AutoChart06TrimOffLastTrackBar.Value
        $script:AutoChart06TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06OverallDataResults.count) - $script:AutoChart06TrimOffLastTrackBar.Value)"
        $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart06TrimOffLastGroupBox.Controls.Add($script:AutoChart06TrimOffLastTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y + $script:AutoChart06TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06.Series["Software Count Per Host"].ChartType = $script:AutoChart06ChartTypeComboBox.SelectedItem
#    $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
#    $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ChartTypesAvailable) { $script:AutoChart06ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart063DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ChartTypeComboBox.Location.X + $script:AutoChart06ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart063DToggleButton
$script:AutoChart063DInclination = 0
$script:AutoChart063DToggleButton.Add_Click({
    $script:AutoChart063DInclination += 10
    if ( $script:AutoChart063DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)"
#        $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart063DInclination -le 90 ) {
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)"
#        $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart063DToggleButton.Text  = "3D Off"
        $script:AutoChart063DInclination = 0
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart063DToggleButton)

### Change the color of the chart
$script:AutoChart06ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart063DToggleButton.Location.X + $script:AutoChart063DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart063DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ColorsAvailable) { $script:AutoChart06ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06.Series["Software Count Per Host"].Color = $script:AutoChart06ChangeColorComboBox.SelectedItem
})
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {
    # List of Positive Endpoints that positively match
    $script:AutoChart06ImportCsvPosResults = $script:AutoChartSoftwareDataSource | Where-Object 'Name' -eq $($script:AutoChart06InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart06InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ImportCsvPosResults) { $script:AutoChart06InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ImportCsvAll = $script:AutoChartSoftwareDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart06ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ImportCsvPosResults) { $script:AutoChart06ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ImportCsvNegResults) { $script:AutoChart06InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ImportCsvPosResults.count))"
    $script:AutoChart06InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06TrimOffLastGroupBox.Location.X + $script:AutoChart06TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart06CheckDiffButton
$script:AutoChart06CheckDiffButton.Add_Click({
    $script:AutoChart06InvestDiffDropDownArraY = $script:AutoChartSoftwareDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06InvestDiffDropDownLabel.Location.y + $script:AutoChart06InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06InvestDiffDropDownArray) { $script:AutoChart06InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06InvestDiffDropDownComboBox.Location.y + $script:AutoChart06InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart06InvestDiffExecuteButton
    $script:AutoChart06InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06InvestDiffExecuteButton.Location.y + $script:AutoChart06InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y + $script:AutoChart06InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart06InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06InvestDiffPosResultsLabel.Location.x + $script:AutoChart06InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06InvestDiffNegResultsLabel.Location.y + $script:AutoChart06InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06InvestDiffForm.Controls.AddRange(@($script:AutoChart06InvestDiffDropDownLabel,$script:AutoChart06InvestDiffDropDownComboBox,$script:AutoChart06InvestDiffExecuteButton,$script:AutoChart06InvestDiffPosResultsLabel,$script:AutoChart06InvestDiffPosResultsTextBox,$script:AutoChart06InvestDiffNegResultsLabel,$script:AutoChart06InvestDiffNegResultsTextBox))
    $script:AutoChart06InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06InvestDiffForm.ShowDialog()
})
$script:AutoChart06CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06CheckDiffButton)


$AutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06CheckDiffButton.Location.X + $script:AutoChart06CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSoftwareDataSourceFileName -QueryName "Software" -QueryTabName "Software Count Per Host" -PropertyX "ComputerName" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06ManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06CheckDiffButton.Location.X
                   Y = $script:AutoChart06CheckDiffButton.Location.Y + $script:AutoChart06CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06OpenInShell
$script:AutoChart06OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSoftwareCSVFileMostRecentCollection })
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06OpenInShell)


$script:AutoChart06ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06OpenInShell.Location.X + $script:AutoChart06OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ViewResults
$script:AutoChart06ViewResults.Add_Click({ $script:AutoChartSoftwareDataSource | Out-GridView -Title "$script:AutoChartSoftwareCSVFileMostRecentCollection" })
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06ViewResults)


### Save the chart to file
$script:AutoChart06SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06OpenInShell.Location.X
                  Y = $script:AutoChart06OpenInShell.Location.Y + $script:AutoChart06OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06 -Title $script:AutoChart06Title
})
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06SaveButton.Location.X
                        Y = $script:AutoChart06SaveButton.Location.Y + $script:AutoChart06SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06NoticeTextbox)

$script:AutoChart06.Series["Software Count Per Host"].Points.Clear()
$script:AutoChart06OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}





















##############################################################################################
# AutoChart07
##############################################################################################

$script:AutoChartNetworkSettingsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Network Settings') { $script:AutoChartNetworkSettingsCSVFileMatch += $CSVFile } }
}
$script:AutoChartNetworkSettingsCSVFileMostRecentCollection = $script:AutoChartNetworkSettingsCSVFileMatch | Select-Object -Last 1
$script:AutoChartNetworkSettingsDataSource = Import-Csv $script:AutoChartNetworkSettingsCSVFileMostRecentCollection


### Auto Create Charts Object
$script:AutoChart07 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05.Location.X
                  Y = $script:AutoChart05.Location.Y + $script:AutoChart05.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart07Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07.Titles.Add($script:AutoChart07Title)

### Create Charts Area
$script:AutoChart07Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07Area.Name        = 'Chart Area'
$script:AutoChart07Area.AxisX.Title = 'Hosts'
$script:AutoChart07Area.AxisX.Interval          = 1
$script:AutoChart07Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart07Area.Area3DStyle.Enable3D    = $false
$script:AutoChart07Area.Area3DStyle.Inclination = 75
$script:AutoChart07.ChartAreas.Add($script:AutoChart07Area)

### Auto Create Charts Data Series Recent
$script:AutoChart07.Series.Add("Interface Alias")
$script:AutoChart07.Series["Interface Alias"].Enabled           = $True
$script:AutoChart07.Series["Interface Alias"].BorderWidth       = 1
$script:AutoChart07.Series["Interface Alias"].IsVisibleInLegend = $false
$script:AutoChart07.Series["Interface Alias"].Chartarea         = 'Chart Area'
$script:AutoChart07.Series["Interface Alias"].Legend            = 'Legend'
$script:AutoChart07.Series["Interface Alias"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07.Series["Interface Alias"]['PieLineColor']   = 'Black'
$script:AutoChart07.Series["Interface Alias"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07.Series["Interface Alias"].ChartType         = 'Column'
$script:AutoChart07.Series["Interface Alias"].Color             = 'Orange'

        function Generate-AutoChart07 {
            $script:AutoChart07CsvFileHosts      = $script:AutoChartNetworkSettingsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart07UniqueDataFields  = $script:AutoChartNetworkSettingsDataSource | Select-Object -Property 'InterfaceAlias' | Sort-Object -Property 'InterfaceAlias' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07.Series["Interface Alias"].Points.Clear()

            if ($script:AutoChart07UniqueDataFields.count -gt 0){
                $script:AutoChart07Title.ForeColor = 'Black'
                $script:AutoChart07Title.Text = "Interface Alias"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart07OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart07CsvComputers = @()
                    foreach ( $Line in $script:AutoChartNetworkSettingsDataSource ) {
                        if ($($Line.InterfaceAlias) -eq $DataField.InterfaceAlias) {
                            $Count += 1
                            if ( $script:AutoChart07CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart07CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart07UniqueCount = $script:AutoChart07CsvComputers.Count
                    $script:AutoChart07DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07UniqueCount
                        Computers   = $script:AutoChart07CsvComputers
                    }
                    $script:AutoChart07OverallDataResults += $script:AutoChart07DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount) }
                $script:AutoChart07TrimOffLastTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
                $script:AutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
            }
            else {
                $script:AutoChart07Title.ForeColor = 'Red'
                $script:AutoChart07Title.Text = "Interface Alias`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart07OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07OptionsButton
$script:AutoChart07OptionsButton.Add_Click({
    if ($script:AutoChart07OptionsButton.Text -eq 'Options v') {
        $script:AutoChart07OptionsButton.Text = 'Options ^'
        $script:AutoChart07.Controls.Add($script:AutoChart07ManipulationPanel)
    }
    elseif ($script:AutoChart07OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07OptionsButton.Text = 'Options v'
        $script:AutoChart07.Controls.Remove($script:AutoChart07ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07)


$script:AutoChart07ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
    $script:AutoChart07TrimOffFirstTrackBarValue   = 0
    $script:AutoChart07TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07TrimOffFirstTrackBarValue = $script:AutoChart07TrimOffFirstTrackBar.Value
        $script:AutoChart07TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07TrimOffFirstTrackBar.Value)"
        $script:AutoChart07.Series["Interface Alias"].Points.Clear()
        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    })
    $script:AutoChart07TrimOffFirstGroupBox.Controls.Add($script:AutoChart07TrimOffFirstTrackBar)
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07TrimOffFirstGroupBox.Location.X + $script:AutoChart07TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart07TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07TrimOffLastTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
    $script:AutoChart07TrimOffLastTrackBar.Value         = $($script:AutoChart07OverallDataResults.count)
    $script:AutoChart07TrimOffLastTrackBarValue   = 0
    $script:AutoChart07TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07TrimOffLastTrackBarValue = $($script:AutoChart07OverallDataResults.count) - $script:AutoChart07TrimOffLastTrackBar.Value
        $script:AutoChart07TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07OverallDataResults.count) - $script:AutoChart07TrimOffLastTrackBar.Value)"
        $script:AutoChart07.Series["Interface Alias"].Points.Clear()
        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    })
$script:AutoChart07TrimOffLastGroupBox.Controls.Add($script:AutoChart07TrimOffLastTrackBar)
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart07TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07TrimOffFirstGroupBox.Location.Y + $script:AutoChart07TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07.Series["Interface Alias"].ChartType = $script:AutoChart07ChartTypeComboBox.SelectedItem
#    $script:AutoChart07.Series["Interface Alias"].Points.Clear()
#    $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
})
$script:AutoChart07ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ChartTypesAvailable) { $script:AutoChart07ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart073DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ChartTypeComboBox.Location.X + $script:AutoChart07ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart073DToggleButton
$script:AutoChart073DInclination = 0
$script:AutoChart073DToggleButton.Add_Click({

    $script:AutoChart073DInclination += 10
    if ( $script:AutoChart073DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart07Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart073DToggleButton.Text  = "3D On ($script:AutoChart073DInclination)"
#        $script:AutoChart07.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart073DInclination -le 90 ) {
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart073DToggleButton.Text  = "3D On ($script:AutoChart073DInclination)"
#        $script:AutoChart07.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
    else {
        $script:AutoChart073DToggleButton.Text  = "3D Off"
        $script:AutoChart073DInclination = 0
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart07Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
})
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart073DToggleButton)

### Change the color of the chart
$script:AutoChart07ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart073DToggleButton.Location.X + $script:AutoChart073DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart073DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ColorsAvailable) { $script:AutoChart07ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07.Series["Interface Alias"].Color = $script:AutoChart07ChangeColorComboBox.SelectedItem
})
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {
    # List of Positive Endpoints that positively match
    $script:AutoChart07ImportCsvPosResults = $script:AutoChartNetworkSettingsDataSource | Where-Object 'InterfaceAlias' -eq $($script:AutoChart07InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart07InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ImportCsvPosResults) { $script:AutoChart07InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ImportCsvAll = $script:AutoChartNetworkSettingsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart07ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07ImportCsvAll) { if ($Endpoint -notin $script:AutoChart07ImportCsvPosResults) { $script:AutoChart07ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ImportCsvNegResults) { $script:AutoChart07InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07ImportCsvPosResults.count))"
    $script:AutoChart07InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07TrimOffLastGroupBox.Location.X + $script:AutoChart07TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart07CheckDiffButton
$script:AutoChart07CheckDiffButton.Add_Click({
    $script:AutoChart07InvestDiffDropDownArraY = $script:AutoChartNetworkSettingsDataSource | Select-Object -Property 'InterfaceAlias' -ExpandProperty 'InterfaceAlias' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07InvestDiffDropDownLabel.Location.y + $script:AutoChart07InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07InvestDiffDropDownArray) { $script:AutoChart07InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:AutoChart07InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07InvestDiffDropDownComboBox.Location.y + $script:AutoChart07InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart07InvestDiffExecuteButton
    $script:AutoChart07InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07InvestDiffExecuteButton.Location.y + $script:AutoChart07InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07InvestDiffPosResultsLabel.Location.y + $script:AutoChart07InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart07InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07InvestDiffPosResultsLabel.Location.x + $script:AutoChart07InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07InvestDiffNegResultsLabel.Location.y + $script:AutoChart07InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07InvestDiffForm.Controls.AddRange(@($script:AutoChart07InvestDiffDropDownLabel,$script:AutoChart07InvestDiffDropDownComboBox,$script:AutoChart07InvestDiffExecuteButton,$script:AutoChart07InvestDiffPosResultsLabel,$script:AutoChart07InvestDiffPosResultsTextBox,$script:AutoChart07InvestDiffNegResultsLabel,$script:AutoChart07InvestDiffNegResultsTextBox))
    $script:AutoChart07InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07InvestDiffForm.ShowDialog()
})
$script:AutoChart07CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07CheckDiffButton)


$AutoChart07ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07CheckDiffButton.Location.X + $script:AutoChart07CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartNetworkSettingsDataSourceFileName -QueryName "Network Settings" -QueryTabName "Interface Alias" -PropertyX "InterfaceAlias" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart07ExpandChartButton
$script:AutoChart07ManipulationPanel.Controls.Add($AutoChart07ExpandChartButton)


$script:AutoChart07OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07CheckDiffButton.Location.X
                   Y = $script:AutoChart07CheckDiffButton.Location.Y + $script:AutoChart07CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07OpenInShell
$script:AutoChart07OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartNetworkSettingsCSVFileMostRecentCollection })
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07OpenInShell)


$script:AutoChart07ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07OpenInShell.Location.X + $script:AutoChart07OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ViewResults
$script:AutoChart07ViewResults.Add_Click({ $script:AutoChartNetworkSettingsDataSource | Out-GridView -Title "$script:AutoChartNetworkSettingsCSVFileMostRecentCollection" })
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07ViewResults)


### Save the chart to file
$script:AutoChart07SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07OpenInShell.Location.X
                  Y = $script:AutoChart07OpenInShell.Location.Y + $script:AutoChart07OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07 -Title $script:AutoChart07Title
})
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07SaveButton.Location.X
                        Y = $script:AutoChart07SaveButton.Location.Y + $script:AutoChart07SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07NoticeTextbox)

$script:AutoChart07.Series["Interface Alias"].Points.Clear()
$script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}






















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06.Location.X
                  Y = $script:AutoChart06.Location.Y + $script:AutoChart06.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart08Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart08.Titles.Add($script:AutoChart08Title)

### Create Charts Area
$script:AutoChart08Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08Area.Name        = 'Chart Area'
$script:AutoChart08Area.AxisX.Title = 'Hosts'
$script:AutoChart08Area.AxisX.Interval          = 1
$script:AutoChart08Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart08Area.Area3DStyle.Enable3D    = $false
$script:AutoChart08Area.Area3DStyle.Inclination = 75
$script:AutoChart08.ChartAreas.Add($script:AutoChart08Area)

### Auto Create Charts Data Series Recent
$script:AutoChart08.Series.Add("Interfaces with IPs Per Host")
$script:AutoChart08.Series["Interfaces with IPs Per Host"].Enabled           = $True
$script:AutoChart08.Series["Interfaces with IPs Per Host"].BorderWidth       = 1
$script:AutoChart08.Series["Interfaces with IPs Per Host"].IsVisibleInLegend = $false
$script:AutoChart08.Series["Interfaces with IPs Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart08.Series["Interfaces with IPs Per Host"].Legend            = 'Legend'
$script:AutoChart08.Series["Interfaces with IPs Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08.Series["Interfaces with IPs Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart08.Series["Interfaces with IPs Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08.Series["Interfaces with IPs Per Host"].ChartType         = 'DoughNut'
$script:AutoChart08.Series["Interfaces with IPs Per Host"].Color             = 'Orange'

        function Generate-AutoChart08 {
            $script:AutoChart08CsvFileHosts     = ($script:AutoChartNetworkSettingsDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart08UniqueDataFields = ($script:AutoChartNetworkSettingsDataSource).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart08UniqueDataFields.count -gt 0){
                $script:AutoChart08Title.ForeColor = 'Black'
                $script:AutoChart08Title.Text = "Interfaces with IPs Per Host"

                $AutoChart08CurrentComputer  = ''
                $AutoChart08CheckIfFirstLine = $false
                $AutoChart08ResultsCount     = 0
                $AutoChart08Computer         = @()
                $AutoChart08YResults         = @()
                $script:AutoChart08OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartNetworkSettingsDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart08CheckIfFirstLine -eq $false ) { $AutoChart08CurrentComputer  = $Line.ComputerName ; $AutoChart08CheckIfFirstLine = $true }
                    if ( $AutoChart08CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart08CurrentComputer ) {
                            if ( $AutoChart08YResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08YResults += $Line.IPAddress ; $AutoChart08ResultsCount += 1 }
                                if ( $AutoChart08Computer -notcontains $Line.ComputerName ) { $AutoChart08Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart08CurrentComputer ) {
                            $AutoChart08CurrentComputer = $Line.ComputerName
                            $AutoChart08YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart08ResultsCount
                                Computer     = $AutoChart08Computer
                            }
                            $script:AutoChart08OverallDataResults += $AutoChart08YDataResults
                            $AutoChart08YResults     = @()
                            $AutoChart08ResultsCount = 0
                            $AutoChart08Computer     = @()
                            if ( $AutoChart08YResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08YResults += $Line.IPAddress ; $AutoChart08ResultsCount += 1 }
                                if ( $AutoChart08Computer -notcontains $Line.ComputerName ) { $AutoChart08Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart08YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart08ResultsCount ; Computer = $AutoChart08Computer }
                $script:AutoChart08OverallDataResults += $AutoChart08YDataResults
                $script:AutoChart08OverallDataResults | ForEach-Object { $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
                $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart08TrimOffLastTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
                $script:AutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
            }
            else {
                $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
                $script:AutoChart08Title.ForeColor = 'Red'
                $script:AutoChart08Title.Text = "Interfaces with IPs Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart08OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08OptionsButton
$script:AutoChart08OptionsButton.Add_Click({
    if ($script:AutoChart08OptionsButton.Text -eq 'Options v') {
        $script:AutoChart08OptionsButton.Text = 'Options ^'
        $script:AutoChart08.Controls.Add($script:AutoChart08ManipulationPanel)
    }
    elseif ($script:AutoChart08OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08OptionsButton.Text = 'Options v'
        $script:AutoChart08.Controls.Remove($script:AutoChart08ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08)

$script:AutoChart08ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
    $script:AutoChart08TrimOffFirstTrackBarValue   = 0
    $script:AutoChart08TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08TrimOffFirstTrackBarValue = $script:AutoChart08TrimOffFirstTrackBar.Value
        $script:AutoChart08TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08TrimOffFirstTrackBar.Value)"
        $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
        $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart08TrimOffFirstGroupBox.Controls.Add($script:AutoChart08TrimOffFirstTrackBar)
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08TrimOffFirstGroupBox.Location.X + $script:AutoChart08TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart08TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08TrimOffLastTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
    $script:AutoChart08TrimOffLastTrackBar.Value         = $($script:AutoChart08OverallDataResults.count)
    $script:AutoChart08TrimOffLastTrackBarValue   = 0
    $script:AutoChart08TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08TrimOffLastTrackBarValue = $($script:AutoChart08OverallDataResults.count) - $script:AutoChart08TrimOffLastTrackBar.Value
        $script:AutoChart08TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08OverallDataResults.count) - $script:AutoChart08TrimOffLastTrackBar.Value)"
        $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
        $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart08TrimOffLastGroupBox.Controls.Add($script:AutoChart08TrimOffLastTrackBar)
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart08TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08TrimOffFirstGroupBox.Location.Y + $script:AutoChart08TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08.Series["Interfaces with IPs Per Host"].ChartType = $script:AutoChart08ChartTypeComboBox.SelectedItem
#    $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
#    $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart08ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ChartTypesAvailable) { $script:AutoChart08ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart083DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ChartTypeComboBox.Location.X + $script:AutoChart08ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart083DToggleButton
$script:AutoChart083DInclination = 0
$script:AutoChart083DToggleButton.Add_Click({
    $script:AutoChart083DInclination += 10
    if ( $script:AutoChart083DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart08Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart083DToggleButton.Text  = "3D On ($script:AutoChart083DInclination)"
#        $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart083DInclination -le 90 ) {
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart083DToggleButton.Text  = "3D On ($script:AutoChart083DInclination)"
#        $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart083DToggleButton.Text  = "3D Off"
        $script:AutoChart083DInclination = 0
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart08Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart083DToggleButton)

### Change the color of the chart
$script:AutoChart08ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart083DToggleButton.Location.X + $script:AutoChart083DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart083DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ColorsAvailable) { $script:AutoChart08ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08.Series["Interfaces with IPs Per Host"].Color = $script:AutoChart08ChangeColorComboBox.SelectedItem
})
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {
    # List of Positive Endpoints that positively match
    $script:AutoChart08ImportCsvPosResults = $script:AutoChartNetworkSettingsDataSource | Where-Object 'Name' -eq $($script:AutoChart08InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart08InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ImportCsvPosResults) { $script:AutoChart08InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ImportCsvAll = $script:AutoChartNetworkSettingsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart08ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08ImportCsvAll) { if ($Endpoint -notin $script:AutoChart08ImportCsvPosResults) { $script:AutoChart08ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ImportCsvNegResults) { $script:AutoChart08InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08ImportCsvPosResults.count))"
    $script:AutoChart08InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08TrimOffLastGroupBox.Location.X + $script:AutoChart08TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart08CheckDiffButton
$script:AutoChart08CheckDiffButton.Add_Click({
    $script:AutoChart08InvestDiffDropDownArraY = $script:AutoChartNetworkSettingsDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08InvestDiffDropDownLabel.Location.y + $script:AutoChart08InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08InvestDiffDropDownArray) { $script:AutoChart08InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:AutoChart08InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08InvestDiffDropDownComboBox.Location.y + $script:AutoChart08InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart08InvestDiffExecuteButton
    $script:AutoChart08InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08InvestDiffExecuteButton.Location.y + $script:AutoChart08InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08InvestDiffPosResultsLabel.Location.y + $script:AutoChart08InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart08InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08InvestDiffPosResultsLabel.Location.x + $script:AutoChart08InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08InvestDiffNegResultsLabel.Location.y + $script:AutoChart08InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08InvestDiffForm.Controls.AddRange(@($script:AutoChart08InvestDiffDropDownLabel,$script:AutoChart08InvestDiffDropDownComboBox,$script:AutoChart08InvestDiffExecuteButton,$script:AutoChart08InvestDiffPosResultsLabel,$script:AutoChart08InvestDiffPosResultsTextBox,$script:AutoChart08InvestDiffNegResultsLabel,$script:AutoChart08InvestDiffNegResultsTextBox))
    $script:AutoChart08InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08InvestDiffForm.ShowDialog()
})
$script:AutoChart08CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08CheckDiffButton)


$AutoChart08ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08CheckDiffButton.Location.X + $script:AutoChart08CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartNetworkSettingsDataSourceFileName -QueryName "Network Settings" -QueryTabName "Interfaces with IPs Per Host" -PropertyX "ComputerName" -PropertyY "IPAddress" }
}
Apply-CommonButtonSettings -Button $AutoChart08ExpandChartButton
$script:AutoChart08ManipulationPanel.Controls.Add($AutoChart08ExpandChartButton)


$script:AutoChart08OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08CheckDiffButton.Location.X
                   Y = $script:AutoChart08CheckDiffButton.Location.Y + $script:AutoChart08CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08OpenInShell
$script:AutoChart08OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartNetworkSettingsCSVFileMostRecentCollection })
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08OpenInShell)


$script:AutoChart08ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08OpenInShell.Location.X + $script:AutoChart08OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ViewResults
$script:AutoChart08ViewResults.Add_Click({ $script:AutoChartNetworkSettingsDataSource | Out-GridView -Title "$script:AutoChartNetworkSettingsCSVFileMostRecentCollection" })
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08ViewResults)


### Save the chart to file
$script:AutoChart08SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08OpenInShell.Location.X
                  Y = $script:AutoChart08OpenInShell.Location.Y + $script:AutoChart08OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08 -Title $script:AutoChart08Title
})
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08SaveButton.Location.X
                        Y = $script:AutoChart08SaveButton.Location.Y + $script:AutoChart08SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08NoticeTextbox)

$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.Clear()
$script:AutoChart08OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}






















##############################################################################################
# AutoChart09
##############################################################################################

$script:AutoChartStartupsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Startup') { $script:AutoChartStartupsCSVFileMatch += $CSVFile } }
}
$script:AutoChartStartupsCSVFileMostRecentCollection = $script:AutoChartStartupsCSVFileMatch | Select-Object -Last 1
$script:AutoChartStartupsDataSource = Import-Csv $script:AutoChartStartupsCSVFileMostRecentCollection


### Auto Create Charts Object
$script:AutoChart09 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07.Location.X
                  Y = $script:AutoChart07.Location.Y + $script:AutoChart07.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart09Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09.Titles.Add($script:AutoChart09Title)

### Create Charts Area
$script:AutoChart09Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09Area.Name        = 'Chart Area'
$script:AutoChart09Area.AxisX.Title = 'Hosts'
$script:AutoChart09Area.AxisX.Interval          = 1
$script:AutoChart09Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart09Area.Area3DStyle.Enable3D    = $false
$script:AutoChart09Area.Area3DStyle.Inclination = 75
$script:AutoChart09.ChartAreas.Add($script:AutoChart09Area)

### Auto Create Charts Data Series Recent
$script:AutoChart09.Series.Add("Startups")
$script:AutoChart09.Series["Startups"].Enabled           = $True
$script:AutoChart09.Series["Startups"].BorderWidth       = 1
$script:AutoChart09.Series["Startups"].IsVisibleInLegend = $false
$script:AutoChart09.Series["Startups"].Chartarea         = 'Chart Area'
$script:AutoChart09.Series["Startups"].Legend            = 'Legend'
$script:AutoChart09.Series["Startups"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09.Series["Startups"]['PieLineColor']   = 'Black'
$script:AutoChart09.Series["Startups"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09.Series["Startups"].ChartType         = 'Column'
$script:AutoChart09.Series["Startups"].Color             = 'Brown'

        function Generate-AutoChart09 {
            $script:AutoChart09CsvFileHosts      = $script:AutoChartStartupsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart09UniqueDataFields  = $script:AutoChartStartupsDataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09.Series["Startups"].Points.Clear()

            if ($script:AutoChart09UniqueDataFields.count -gt 0){
                $script:AutoChart09Title.ForeColor = 'Black'
                $script:AutoChart09Title.Text = "Startups"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart09OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09CsvComputers = @()
                    foreach ( $Line in $script:AutoChartStartupsDataSource ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart09CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart09CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart09UniqueCount = $script:AutoChart09CsvComputers.Count
                    $script:AutoChart09DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09UniqueCount
                        Computers   = $script:AutoChart09CsvComputers
                    }
                    $script:AutoChart09OverallDataResults += $script:AutoChart09DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart09TrimOffLastTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
                $script:AutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
            }
            else {
                $script:AutoChart09Title.ForeColor = 'Red'
                $script:AutoChart09Title.Text = "Startups`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart09OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09OptionsButton
$script:AutoChart09OptionsButton.Add_Click({
    if ($script:AutoChart09OptionsButton.Text -eq 'Options v') {
        $script:AutoChart09OptionsButton.Text = 'Options ^'
        $script:AutoChart09.Controls.Add($script:AutoChart09ManipulationPanel)
    }
    elseif ($script:AutoChart09OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09OptionsButton.Text = 'Options v'
        $script:AutoChart09.Controls.Remove($script:AutoChart09ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09)


$script:AutoChart09ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
    $script:AutoChart09TrimOffFirstTrackBarValue   = 0
    $script:AutoChart09TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09TrimOffFirstTrackBarValue = $script:AutoChart09TrimOffFirstTrackBar.Value
        $script:AutoChart09TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09TrimOffFirstTrackBar.Value)"
        $script:AutoChart09.Series["Startups"].Points.Clear()
        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart09TrimOffFirstGroupBox.Controls.Add($script:AutoChart09TrimOffFirstTrackBar)
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09TrimOffFirstGroupBox.Location.X + $script:AutoChart09TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart09TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09TrimOffLastTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
    $script:AutoChart09TrimOffLastTrackBar.Value         = $($script:AutoChart09OverallDataResults.count)
    $script:AutoChart09TrimOffLastTrackBarValue   = 0
    $script:AutoChart09TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09TrimOffLastTrackBarValue = $($script:AutoChart09OverallDataResults.count) - $script:AutoChart09TrimOffLastTrackBar.Value
        $script:AutoChart09TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09OverallDataResults.count) - $script:AutoChart09TrimOffLastTrackBar.Value)"
        $script:AutoChart09.Series["Startups"].Points.Clear()
        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart09TrimOffLastGroupBox.Controls.Add($script:AutoChart09TrimOffLastTrackBar)
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart09TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09TrimOffFirstGroupBox.Location.Y + $script:AutoChart09TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09.Series["Startups"].ChartType = $script:AutoChart09ChartTypeComboBox.SelectedItem
#    $script:AutoChart09.Series["Startups"].Points.Clear()
#    $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart09ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ChartTypesAvailable) { $script:AutoChart09ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart093DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ChartTypeComboBox.Location.X + $script:AutoChart09ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart093DToggleButton
$script:AutoChart093DInclination = 0
$script:AutoChart093DToggleButton.Add_Click({

    $script:AutoChart093DInclination += 10
    if ( $script:AutoChart093DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart09Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart093DToggleButton.Text  = "3D On ($script:AutoChart093DInclination)"
#        $script:AutoChart09.Series["Startups"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart093DInclination -le 90 ) {
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart093DToggleButton.Text  = "3D On ($script:AutoChart093DInclination)"
#        $script:AutoChart09.Series["Startups"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart093DToggleButton.Text  = "3D Off"
        $script:AutoChart093DInclination = 0
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart09Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09.Series["Startups"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart093DToggleButton)

### Change the color of the chart
$script:AutoChart09ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart093DToggleButton.Location.X + $script:AutoChart093DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart093DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ColorsAvailable) { $script:AutoChart09ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09.Series["Startups"].Color = $script:AutoChart09ChangeColorComboBox.SelectedItem
})
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {
    # List of Positive Endpoints that positively match
    $script:AutoChart09ImportCsvPosResults = $script:AutoChartStartupsDataSource | Where-Object 'Name' -eq $($script:AutoChart09InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart09InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ImportCsvPosResults) { $script:AutoChart09InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ImportCsvAll = $script:AutoChartStartupsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart09ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09ImportCsvAll) { if ($Endpoint -notin $script:AutoChart09ImportCsvPosResults) { $script:AutoChart09ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ImportCsvNegResults) { $script:AutoChart09InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09ImportCsvPosResults.count))"
    $script:AutoChart09InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09TrimOffLastGroupBox.Location.X + $script:AutoChart09TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart09CheckDiffButton
$script:AutoChart09CheckDiffButton.Add_Click({
    $script:AutoChart09InvestDiffDropDownArraY = $script:AutoChartStartupsDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09InvestDiffDropDownLabel.Location.y + $script:AutoChart09InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09InvestDiffDropDownArray) { $script:AutoChart09InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:AutoChart09InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09InvestDiffDropDownComboBox.Location.y + $script:AutoChart09InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart09InvestDiffExecuteButton
    $script:AutoChart09InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09InvestDiffExecuteButton.Location.y + $script:AutoChart09InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09InvestDiffPosResultsLabel.Location.y + $script:AutoChart09InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart09InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09InvestDiffPosResultsLabel.Location.x + $script:AutoChart09InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09InvestDiffNegResultsLabel.Location.y + $script:AutoChart09InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09InvestDiffForm.Controls.AddRange(@($script:AutoChart09InvestDiffDropDownLabel,$script:AutoChart09InvestDiffDropDownComboBox,$script:AutoChart09InvestDiffExecuteButton,$script:AutoChart09InvestDiffPosResultsLabel,$script:AutoChart09InvestDiffPosResultsTextBox,$script:AutoChart09InvestDiffNegResultsLabel,$script:AutoChart09InvestDiffNegResultsTextBox))
    $script:AutoChart09InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09InvestDiffForm.ShowDialog()
})
$script:AutoChart09CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09CheckDiffButton)


$AutoChart09ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09CheckDiffButton.Location.X + $script:AutoChart09CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartStartupsDataSourceFileName -QueryName "StartupCommand" -QueryTabName "Startups" -PropertyX "Name" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart09ExpandChartButton
$script:AutoChart09ManipulationPanel.Controls.Add($AutoChart09ExpandChartButton)


$script:AutoChart09OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09CheckDiffButton.Location.X
                   Y = $script:AutoChart09CheckDiffButton.Location.Y + $script:AutoChart09CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09OpenInShell
$script:AutoChart09OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartStartupsCSVFileMostRecentCollection })
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09OpenInShell)


$script:AutoChart09ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09OpenInShell.Location.X + $script:AutoChart09OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ViewResults
$script:AutoChart09ViewResults.Add_Click({ $script:AutoChartStartupsDataSource | Out-GridView -Title "$script:AutoChartStartupsCSVFileMostRecentCollection" })
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09ViewResults)


### Save the chart to file
$script:AutoChart09SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09OpenInShell.Location.X
                  Y = $script:AutoChart09OpenInShell.Location.Y + $script:AutoChart09OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09 -Title $script:AutoChart09Title
})
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09SaveButton.Location.X
                        Y = $script:AutoChart09SaveButton.Location.Y + $script:AutoChart09SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09NoticeTextbox)

$script:AutoChart09.Series["Startups"].Points.Clear()
$script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Startups"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}






















##############################################################################################
# AutoChart10
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08.Location.X
                  Y = $script:AutoChart08.Location.Y + $script:AutoChart08.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart10Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart10.Titles.Add($script:AutoChart10Title)

### Create Charts Area
$script:AutoChart10Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10Area.Name        = 'Chart Area'
$script:AutoChart10Area.AxisX.Title = 'Hosts'
$script:AutoChart10Area.AxisX.Interval          = 1
$script:AutoChart10Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart10Area.Area3DStyle.Enable3D    = $false
$script:AutoChart10Area.Area3DStyle.Inclination = 75
$script:AutoChart10.ChartAreas.Add($script:AutoChart10Area)

### Auto Create Charts Data Series Recent
$script:AutoChart10.Series.Add("Startups Per Host")
$script:AutoChart10.Series["Startups Per Host"].Enabled           = $True
$script:AutoChart10.Series["Startups Per Host"].BorderWidth       = 1
$script:AutoChart10.Series["Startups Per Host"].IsVisibleInLegend = $false
$script:AutoChart10.Series["Startups Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart10.Series["Startups Per Host"].Legend            = 'Legend'
$script:AutoChart10.Series["Startups Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10.Series["Startups Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart10.Series["Startups Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10.Series["Startups Per Host"].ChartType         = 'DoughNut'
$script:AutoChart10.Series["Startups Per Host"].Color             = 'Brown'

        function Generate-AutoChart10 {
            $script:AutoChart10CsvFileHosts     = ($script:AutoChartStartupsDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart10UniqueDataFields = ($script:AutoChartStartupsDataSource).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart10UniqueDataFields.count -gt 0){
                $script:AutoChart10Title.ForeColor = 'Black'
                $script:AutoChart10Title.Text = "Startups Per Host"

                $AutoChart10CurrentComputer  = ''
                $AutoChart10CheckIfFirstLine = $false
                $AutoChart10ResultsCount     = 0
                $AutoChart10Computer         = @()
                $AutoChart10YResults         = @()
                $script:AutoChart10OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartStartupsDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart10CheckIfFirstLine -eq $false ) { $AutoChart10CurrentComputer  = $Line.ComputerName ; $AutoChart10CheckIfFirstLine = $true }
                    if ( $AutoChart10CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart10CurrentComputer ) {
                            if ( $AutoChart10YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart10YResults += $Line.Name ; $AutoChart10ResultsCount += 1 }
                                if ( $AutoChart10Computer -notcontains $Line.ComputerName ) { $AutoChart10Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart10CurrentComputer ) {
                            $AutoChart10CurrentComputer = $Line.ComputerName
                            $AutoChart10YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart10ResultsCount
                                Computer     = $AutoChart10Computer
                            }
                            $script:AutoChart10OverallDataResults += $AutoChart10YDataResults
                            $AutoChart10YResults     = @()
                            $AutoChart10ResultsCount = 0
                            $AutoChart10Computer     = @()
                            if ( $AutoChart10YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart10YResults += $Line.Name ; $AutoChart10ResultsCount += 1 }
                                if ( $AutoChart10Computer -notcontains $Line.ComputerName ) { $AutoChart10Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart10YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart10ResultsCount ; Computer = $AutoChart10Computer }
                $script:AutoChart10OverallDataResults += $AutoChart10YDataResults
                $script:AutoChart10OverallDataResults | ForEach-Object { $script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
                $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart10TrimOffLastTrackBar.SetRange(0, $($script:AutoChart10OverallDataResults.count))
                $script:AutoChart10TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10OverallDataResults.count))
            }
            else {
                $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
                $script:AutoChart10Title.ForeColor = 'Red'
                $script:AutoChart10Title.Text = "Startups Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart10

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart10OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10OptionsButton
$script:AutoChart10OptionsButton.Add_Click({
    if ($script:AutoChart10OptionsButton.Text -eq 'Options v') {
        $script:AutoChart10OptionsButton.Text = 'Options ^'
        $script:AutoChart10.Controls.Add($script:AutoChart10ManipulationPanel)
    }
    elseif ($script:AutoChart10OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10OptionsButton.Text = 'Options v'
        $script:AutoChart10.Controls.Remove($script:AutoChart10ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10)

$script:AutoChart10ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart10TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10OverallDataResults.count))
    $script:AutoChart10TrimOffFirstTrackBarValue   = 0
    $script:AutoChart10TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10TrimOffFirstTrackBarValue = $script:AutoChart10TrimOffFirstTrackBar.Value
        $script:AutoChart10TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10TrimOffFirstTrackBar.Value)"
        $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
        $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart10TrimOffFirstGroupBox.Controls.Add($script:AutoChart10TrimOffFirstTrackBar)
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart10TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10TrimOffFirstGroupBox.Location.X + $script:AutoChart10TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart10TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10TrimOffLastTrackBar.SetRange(0, $($script:AutoChart10OverallDataResults.count))
    $script:AutoChart10TrimOffLastTrackBar.Value         = $($script:AutoChart10OverallDataResults.count)
    $script:AutoChart10TrimOffLastTrackBarValue   = 0
    $script:AutoChart10TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10TrimOffLastTrackBarValue = $($script:AutoChart10OverallDataResults.count) - $script:AutoChart10TrimOffLastTrackBar.Value
        $script:AutoChart10TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10OverallDataResults.count) - $script:AutoChart10TrimOffLastTrackBar.Value)"
        $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
        $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart10TrimOffLastGroupBox.Controls.Add($script:AutoChart10TrimOffLastTrackBar)
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart10TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart10TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10TrimOffFirstGroupBox.Location.Y + $script:AutoChart10TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10.Series["Startups Per Host"].ChartType = $script:AutoChart10ChartTypeComboBox.SelectedItem
#    $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
#    $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart10ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10ChartTypesAvailable) { $script:AutoChart10ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart10ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart103DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10ChartTypeComboBox.Location.X + $script:AutoChart10ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart103DToggleButton
$script:AutoChart103DInclination = 0
$script:AutoChart103DToggleButton.Add_Click({
    $script:AutoChart103DInclination += 10
    if ( $script:AutoChart103DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart10Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart10Area.Area3DStyle.Inclination = $script:AutoChart103DInclination
        $script:AutoChart103DToggleButton.Text  = "3D On ($script:AutoChart103DInclination)"
#        $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart103DInclination -le 90 ) {
        $script:AutoChart10Area.Area3DStyle.Inclination = $script:AutoChart103DInclination
        $script:AutoChart103DToggleButton.Text  = "3D On ($script:AutoChart103DInclination)"
#        $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart103DToggleButton.Text  = "3D Off"
        $script:AutoChart103DInclination = 0
        $script:AutoChart10Area.Area3DStyle.Inclination = $script:AutoChart103DInclination
        $script:AutoChart10Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart103DToggleButton)

### Change the color of the chart
$script:AutoChart10ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart103DToggleButton.Location.X + $script:AutoChart103DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart103DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10ColorsAvailable) { $script:AutoChart10ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10.Series["Startups Per Host"].Color = $script:AutoChart10ChangeColorComboBox.SelectedItem
})
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart10ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10 {
    # List of Positive Endpoints that positively match
    $script:AutoChart10ImportCsvPosResults = $script:AutoChartStartupsDataSource | Where-Object 'Name' -eq $($script:AutoChart10InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart10InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ImportCsvPosResults) { $script:AutoChart10InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10ImportCsvAll = $script:AutoChartStartupsDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart10ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10ImportCsvAll) { if ($Endpoint -notin $script:AutoChart10ImportCsvPosResults) { $script:AutoChart10ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ImportCsvNegResults) { $script:AutoChart10InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10ImportCsvPosResults.count))"
    $script:AutoChart10InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10TrimOffLastGroupBox.Location.X + $script:AutoChart10TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart10CheckDiffButton
$script:AutoChart10CheckDiffButton.Add_Click({
    $script:AutoChart10InvestDiffDropDownArraY = $script:AutoChartStartupsDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10InvestDiffDropDownLabel.Location.y + $script:AutoChart10InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10InvestDiffDropDownArray) { $script:AutoChart10InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Execute Button
    $script:AutoChart10InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10InvestDiffDropDownComboBox.Location.y + $script:AutoChart10InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart10InvestDiffExecuteButton
    $script:AutoChart10InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10InvestDiffExecuteButton.Location.y + $script:AutoChart10InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10InvestDiffPosResultsLabel.Location.y + $script:AutoChart10InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart10InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10InvestDiffPosResultsLabel.Location.x + $script:AutoChart10InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10InvestDiffNegResultsLabel.Location.y + $script:AutoChart10InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10InvestDiffForm.Controls.AddRange(@($script:AutoChart10InvestDiffDropDownLabel,$script:AutoChart10InvestDiffDropDownComboBox,$script:AutoChart10InvestDiffExecuteButton,$script:AutoChart10InvestDiffPosResultsLabel,$script:AutoChart10InvestDiffPosResultsTextBox,$script:AutoChart10InvestDiffNegResultsLabel,$script:AutoChart10InvestDiffNegResultsTextBox))
    $script:AutoChart10InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10InvestDiffForm.ShowDialog()
})
$script:AutoChart10CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10ManipulationPanel.controls.Add($script:AutoChart10CheckDiffButton)


$AutoChart10ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10CheckDiffButton.Location.X + $script:AutoChart10CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartStartupsDataSourceFileName -QueryName "StartupCommand" -QueryTabName "Startups per Endpoint" -PropertyX "ComputerName" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart10ExpandChartButton
$script:AutoChart10ManipulationPanel.Controls.Add($AutoChart10ExpandChartButton)


$script:AutoChart10OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10CheckDiffButton.Location.X
                   Y = $script:AutoChart10CheckDiffButton.Location.Y + $script:AutoChart10CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10OpenInShell
$script:AutoChart10OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartStartupsCSVFileMostRecentCollection })
$script:AutoChart10ManipulationPanel.controls.Add($script:AutoChart10OpenInShell)


$script:AutoChart10ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10OpenInShell.Location.X + $script:AutoChart10OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ViewResults
$script:AutoChart10ViewResults.Add_Click({ $script:AutoChartStartupsDataSource | Out-GridView -Title "$script:AutoChartStartupsCSVFileMostRecentCollection" })
$script:AutoChart10ManipulationPanel.controls.Add($script:AutoChart10ViewResults)


### Save the chart to file
$script:AutoChart10SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10OpenInShell.Location.X
                  Y = $script:AutoChart10OpenInShell.Location.Y + $script:AutoChart10OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10 -Title $script:AutoChart10Title
})
$script:AutoChart10ManipulationPanel.controls.Add($script:AutoChart10SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10SaveButton.Location.X
                        Y = $script:AutoChart10SaveButton.Location.Y + $script:AutoChart10SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10ManipulationPanel.Controls.Add($script:AutoChart10NoticeTextbox)

$script:AutoChart10.Series["Startups Per Host"].Points.Clear()
$script:AutoChart10OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart10TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

















##############################################################################################
# AutoChart11
##############################################################################################

$script:AutoChartSecurityPatchesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Security Patches') { $script:AutoChartSecurityPatchesCSVFileMatch += $CSVFile } }
}
$script:AutoChartSecurityPatchesCSVFileMostRecentCollection = $script:AutoChartSecurityPatchesCSVFileMatch | Select-Object -Last 1
$script:AutoChartSecurityPatchesDataSource = Import-Csv $script:AutoChartSecurityPatchesCSVFileMostRecentCollection


### Auto Create Charts Object
$script:AutoChart11 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart09.Location.X
                  Y = $script:AutoChart09.Location.Y + $script:AutoChart09.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart11.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart11Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart11.Titles.Add($script:AutoChart11Title)

### Create Charts Area
$script:AutoChart11Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart11Area.Name        = 'Chart Area'
$script:AutoChart11Area.AxisX.Title = 'Hosts'
$script:AutoChart11Area.AxisX.Interval          = 1
$script:AutoChart11Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart11Area.Area3DStyle.Enable3D    = $false
$script:AutoChart11Area.Area3DStyle.Inclination = 75
$script:AutoChart11.ChartAreas.Add($script:AutoChart11Area)

### Auto Create Charts Data Series Recent
$script:AutoChart11.Series.Add("Security Patches")
$script:AutoChart11.Series["Security Patches"].Enabled           = $True
$script:AutoChart11.Series["Security Patches"].BorderWidth       = 1
$script:AutoChart11.Series["Security Patches"].IsVisibleInLegend = $false
$script:AutoChart11.Series["Security Patches"].Chartarea         = 'Chart Area'
$script:AutoChart11.Series["Security Patches"].Legend            = 'Legend'
$script:AutoChart11.Series["Security Patches"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart11.Series["Security Patches"]['PieLineColor']   = 'Black'
$script:AutoChart11.Series["Security Patches"]['PieLabelStyle']  = 'Outside'
$script:AutoChart11.Series["Security Patches"].ChartType         = 'Column'
$script:AutoChart11.Series["Security Patches"].Color             = 'Gray'

        function Generate-AutoChart11 {
            $script:AutoChart11CsvFileHosts      = $script:AutoChartSecurityPatchesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart11UniqueDataFields  = $script:AutoChartSecurityPatchesDataSource | Select-Object -Property 'HotFixID' | Sort-Object -Property 'HotFixID' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart11UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart11.Series["Security Patches"].Points.Clear()

            if ($script:AutoChart11UniqueDataFields.count -gt 0){
                $script:AutoChart11Title.ForeColor = 'Black'
                $script:AutoChart11Title.Text = "Security Patches"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart11OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart11UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart11CsvComputers = @()
                    foreach ( $Line in $script:AutoChartSecurityPatchesDataSource ) {
                        if ($($Line.HotFixID) -eq $DataField.HotFixID) {
                            $Count += 1
                            if ( $script:AutoChart11CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart11CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart11UniqueCount = $script:AutoChart11CsvComputers.Count
                    $script:AutoChart11DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart11UniqueCount
                        Computers   = $script:AutoChart11CsvComputers
                    }
                    $script:AutoChart11OverallDataResults += $script:AutoChart11DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount) }
                $script:AutoChart11TrimOffLastTrackBar.SetRange(0, $($script:AutoChart11OverallDataResults.count))
                $script:AutoChart11TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart11OverallDataResults.count))
            }
            else {
                $script:AutoChart11Title.ForeColor = 'Red'
                $script:AutoChart11Title.Text = "Security Patches`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart11

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart11OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart11.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart11.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11OptionsButton
$script:AutoChart11OptionsButton.Add_Click({
    if ($script:AutoChart11OptionsButton.Text -eq 'Options v') {
        $script:AutoChart11OptionsButton.Text = 'Options ^'
        $script:AutoChart11.Controls.Add($script:AutoChart11ManipulationPanel)
    }
    elseif ($script:AutoChart11OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart11OptionsButton.Text = 'Options v'
        $script:AutoChart11.Controls.Remove($script:AutoChart11ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart11OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart11)


$script:AutoChart11ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart11.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart11.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart11TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart11TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart11TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart11OverallDataResults.count))
    $script:AutoChart11TrimOffFirstTrackBarValue   = 0
    $script:AutoChart11TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart11TrimOffFirstTrackBarValue = $script:AutoChart11TrimOffFirstTrackBar.Value
        $script:AutoChart11TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart11TrimOffFirstTrackBar.Value)"
        $script:AutoChart11.Series["Security Patches"].Points.Clear()
        $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    })
    $script:AutoChart11TrimOffFirstGroupBox.Controls.Add($script:AutoChart11TrimOffFirstTrackBar)
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart11TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart11TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart11TrimOffFirstGroupBox.Location.X + $script:AutoChart11TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart11TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart11TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart11TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart11TrimOffLastTrackBar.SetRange(0, $($script:AutoChart11OverallDataResults.count))
    $script:AutoChart11TrimOffLastTrackBar.Value         = $($script:AutoChart11OverallDataResults.count)
    $script:AutoChart11TrimOffLastTrackBarValue   = 0
    $script:AutoChart11TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart11TrimOffLastTrackBarValue = $($script:AutoChart11OverallDataResults.count) - $script:AutoChart11TrimOffLastTrackBar.Value
        $script:AutoChart11TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart11OverallDataResults.count) - $script:AutoChart11TrimOffLastTrackBar.Value)"
        $script:AutoChart11.Series["Security Patches"].Points.Clear()
        $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    })
$script:AutoChart11TrimOffLastGroupBox.Controls.Add($script:AutoChart11TrimOffLastTrackBar)
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart11TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart11ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart11TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart11TrimOffFirstGroupBox.Location.Y + $script:AutoChart11TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart11ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart11.Series["Security Patches"].ChartType = $script:AutoChart11ChartTypeComboBox.SelectedItem
#    $script:AutoChart11.Series["Security Patches"].Points.Clear()
#    $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
})
$script:AutoChart11ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart11ChartTypesAvailable) { $script:AutoChart11ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart11ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart113DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart11ChartTypeComboBox.Location.X + $script:AutoChart11ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart11ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart113DToggleButton
$script:AutoChart113DInclination = 0
$script:AutoChart113DToggleButton.Add_Click({

    $script:AutoChart113DInclination += 10
    if ( $script:AutoChart113DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart11Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart11Area.Area3DStyle.Inclination = $script:AutoChart113DInclination
        $script:AutoChart113DToggleButton.Text  = "3D On ($script:AutoChart113DInclination)"
#        $script:AutoChart11.Series["Security Patches"].Points.Clear()
#        $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart113DInclination -le 90 ) {
        $script:AutoChart11Area.Area3DStyle.Inclination = $script:AutoChart113DInclination
        $script:AutoChart113DToggleButton.Text  = "3D On ($script:AutoChart113DInclination)"
#        $script:AutoChart11.Series["Security Patches"].Points.Clear()
#        $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    else {
        $script:AutoChart113DToggleButton.Text  = "3D Off"
        $script:AutoChart113DInclination = 0
        $script:AutoChart11Area.Area3DStyle.Inclination = $script:AutoChart113DInclination
        $script:AutoChart11Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart11.Series["Security Patches"].Points.Clear()
#        $script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
})
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart113DToggleButton)

### Change the color of the chart
$script:AutoChart11ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart113DToggleButton.Location.X + $script:AutoChart113DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart113DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart11ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart11ColorsAvailable) { $script:AutoChart11ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart11ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart11.Series["Security Patches"].Color = $script:AutoChart11ChangeColorComboBox.SelectedItem
})
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart11ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart11 {
    # List of Positive Endpoints that positively match
    $script:AutoChart11ImportCsvPosResults = $script:AutoChartSecurityPatchesDataSource | Where-Object 'HotFixID' -eq $($script:AutoChart11InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart11InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart11ImportCsvPosResults) { $script:AutoChart11InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart11ImportCsvAll = $script:AutoChartSecurityPatchesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart11ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart11ImportCsvAll) { if ($Endpoint -notin $script:AutoChart11ImportCsvPosResults) { $script:AutoChart11ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart11InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart11ImportCsvNegResults) { $script:AutoChart11InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart11InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart11ImportCsvPosResults.count))"
    $script:AutoChart11InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart11ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart11CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart11TrimOffLastGroupBox.Location.X + $script:AutoChart11TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart11TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart11CheckDiffButton
$script:AutoChart11CheckDiffButton.Add_Click({
    $script:AutoChart11InvestDiffDropDownArraY = $script:AutoChartSecurityPatchesDataSource | Select-Object -Property 'HotFixID' -ExpandProperty 'HotFixID' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart11InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart11InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart11InvestDiffDropDownLabel.Location.y + $script:AutoChart11InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart11InvestDiffDropDownArray) { $script:AutoChart11InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart11InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart11 }})
    $script:AutoChart11InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart11 })

    ### Investigate Difference Execute Button
    $script:AutoChart11InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart11InvestDiffDropDownComboBox.Location.y + $script:AutoChart11InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart11InvestDiffExecuteButton
    $script:AutoChart11InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart11 }})
    $script:AutoChart11InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart11 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart11InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart11InvestDiffExecuteButton.Location.y + $script:AutoChart11InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart11InvestDiffPosResultsLabel.Location.y + $script:AutoChart11InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart11InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart11InvestDiffPosResultsLabel.Location.x + $script:AutoChart11InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart11InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart11InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart11InvestDiffNegResultsLabel.Location.y + $script:AutoChart11InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart11InvestDiffForm.Controls.AddRange(@($script:AutoChart11InvestDiffDropDownLabel,$script:AutoChart11InvestDiffDropDownComboBox,$script:AutoChart11InvestDiffExecuteButton,$script:AutoChart11InvestDiffPosResultsLabel,$script:AutoChart11InvestDiffPosResultsTextBox,$script:AutoChart11InvestDiffNegResultsLabel,$script:AutoChart11InvestDiffNegResultsTextBox))
    $script:AutoChart11InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart11InvestDiffForm.ShowDialog()
})
$script:AutoChart11CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart11ManipulationPanel.controls.Add($script:AutoChart11CheckDiffButton)


$AutoChart11ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart11CheckDiffButton.Location.X + $script:AutoChart11CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart11CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSecurityPatchesDataSourceFileName -QueryName "Security Patches" -QueryTabName "Security Patches" -PropertyX "HotFixID" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart11ExpandChartButton
$script:AutoChart11ManipulationPanel.Controls.Add($AutoChart11ExpandChartButton)


$script:AutoChart11OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart11CheckDiffButton.Location.X
                   Y = $script:AutoChart11CheckDiffButton.Location.Y + $script:AutoChart11CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11OpenInShell
$script:AutoChart11OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSecurityPatchesCSVFileMostRecentCollection })
$script:AutoChart11ManipulationPanel.controls.Add($script:AutoChart11OpenInShell)


$script:AutoChart11ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart11OpenInShell.Location.X + $script:AutoChart11OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart11OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ViewResults
$script:AutoChart11ViewResults.Add_Click({ $script:AutoChartSecurityPatchesDataSource | Out-GridView -Title "$script:AutoChartSecurityPatchesCSVFileMostRecentCollection" })
$script:AutoChart11ManipulationPanel.controls.Add($script:AutoChart11ViewResults)


### Save the chart to file
$script:AutoChart11SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart11OpenInShell.Location.X
                  Y = $script:AutoChart11OpenInShell.Location.Y + $script:AutoChart11OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart11SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart11 -Title $script:AutoChart11Title
})
$script:AutoChart11ManipulationPanel.controls.Add($script:AutoChart11SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart11NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart11SaveButton.Location.X
                        Y = $script:AutoChart11SaveButton.Location.Y + $script:AutoChart11SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart11CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart11ManipulationPanel.Controls.Add($script:AutoChart11NoticeTextbox)

$script:AutoChart11.Series["Security Patches"].Points.Clear()
$script:AutoChart11OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}




















##############################################################################################
# AutoChart12
##############################################################################################

### Auto Create Charts Object
$script:AutoChart12 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart10.Location.X
                  Y = $script:AutoChart10.Location.Y + $script:AutoChart10.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart12.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart12Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart12.Titles.Add($script:AutoChart12Title)

### Create Charts Area
$script:AutoChart12Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart12Area.Name        = 'Chart Area'
$script:AutoChart12Area.AxisX.Title = 'Hosts'
$script:AutoChart12Area.AxisX.Interval          = 1
$script:AutoChart12Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart12Area.Area3DStyle.Enable3D    = $false
$script:AutoChart12Area.Area3DStyle.Inclination = 75
$script:AutoChart12.ChartAreas.Add($script:AutoChart12Area)

### Auto Create Charts Data Series Recent
$script:AutoChart12.Series.Add("Security Patches Per Host")
$script:AutoChart12.Series["Security Patches Per Host"].Enabled           = $True
$script:AutoChart12.Series["Security Patches Per Host"].BorderWidth       = 1
$script:AutoChart12.Series["Security Patches Per Host"].IsVisibleInLegend = $false
$script:AutoChart12.Series["Security Patches Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart12.Series["Security Patches Per Host"].Legend            = 'Legend'
$script:AutoChart12.Series["Security Patches Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart12.Series["Security Patches Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart12.Series["Security Patches Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart12.Series["Security Patches Per Host"].ChartType         = 'DoughNut'
$script:AutoChart12.Series["Security Patches Per Host"].Color             = 'Gray'

        function Generate-AutoChart12 {
            $script:AutoChart12CsvFileHosts     = ($script:AutoChartSecurityPatchesDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart12UniqueDataFields = ($script:AutoChartSecurityPatchesDataSource).HotFixID | Sort-Object -Property 'HotFixID'

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart12UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart12UniqueDataFields.count -gt 0){
                $script:AutoChart12Title.ForeColor = 'Black'
                $script:AutoChart12Title.Text = "Security Patches Per Host"

                $AutoChart12CurrentComputer  = ''
                $AutoChart12CheckIfFirstLine = $false
                $AutoChart12ResultsCount     = 0
                $AutoChart12Computer         = @()
                $AutoChart12YResults         = @()
                $script:AutoChart12OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartSecurityPatchesDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart12CheckIfFirstLine -eq $false ) { $AutoChart12CurrentComputer  = $Line.ComputerName ; $AutoChart12CheckIfFirstLine = $true }
                    if ( $AutoChart12CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart12CurrentComputer ) {
                            if ( $AutoChart12YResults -notcontains $Line.HotFixID ) {
                                if ( $Line.HotFixID -ne "" ) { $AutoChart12YResults += $Line.HotFixID ; $AutoChart12ResultsCount += 1 }
                                if ( $AutoChart12Computer -notcontains $Line.ComputerName ) { $AutoChart12Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart12CurrentComputer ) {
                            $AutoChart12CurrentComputer = $Line.ComputerName
                            $AutoChart12YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart12ResultsCount
                                Computer     = $AutoChart12Computer
                            }
                            $script:AutoChart12OverallDataResults += $AutoChart12YDataResults
                            $AutoChart12YResults     = @()
                            $AutoChart12ResultsCount = 0
                            $AutoChart12Computer     = @()
                            if ( $AutoChart12YResults -notcontains $Line.HotFixID ) {
                                if ( $Line.HotFixID -ne "" ) { $AutoChart12YResults += $Line.HotFixID ; $AutoChart12ResultsCount += 1 }
                                if ( $AutoChart12Computer -notcontains $Line.ComputerName ) { $AutoChart12Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart12YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart12ResultsCount ; Computer = $AutoChart12Computer }
                $script:AutoChart12OverallDataResults += $AutoChart12YDataResults
                $script:AutoChart12OverallDataResults | ForEach-Object { $script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart12TrimOffLastTrackBar.SetRange(0, $($script:AutoChart12OverallDataResults.count))
                $script:AutoChart12TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart12OverallDataResults.count))
            }
            else {
                $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart12Title.ForeColor = 'Red'
                $script:AutoChart12Title.Text = "Security Patches Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart12

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart12OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart12.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart12.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12OptionsButton
$script:AutoChart12OptionsButton.Add_Click({
    if ($script:AutoChart12OptionsButton.Text -eq 'Options v') {
        $script:AutoChart12OptionsButton.Text = 'Options ^'
        $script:AutoChart12.Controls.Add($script:AutoChart12ManipulationPanel)
    }
    elseif ($script:AutoChart12OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart12OptionsButton.Text = 'Options v'
        $script:AutoChart12.Controls.Remove($script:AutoChart12ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart12OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart12)

$script:AutoChart12ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart12.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart12.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart12TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart12TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart12TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart12OverallDataResults.count))
    $script:AutoChart12TrimOffFirstTrackBarValue   = 0
    $script:AutoChart12TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart12TrimOffFirstTrackBarValue = $script:AutoChart12TrimOffFirstTrackBar.Value
        $script:AutoChart12TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart12TrimOffFirstTrackBar.Value)"
        $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart12TrimOffFirstGroupBox.Controls.Add($script:AutoChart12TrimOffFirstTrackBar)
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart12TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart12TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart12TrimOffFirstGroupBox.Location.X + $script:AutoChart12TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart12TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart12TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart12TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart12TrimOffLastTrackBar.SetRange(0, $($script:AutoChart12OverallDataResults.count))
    $script:AutoChart12TrimOffLastTrackBar.Value         = $($script:AutoChart12OverallDataResults.count)
    $script:AutoChart12TrimOffLastTrackBarValue   = 0
    $script:AutoChart12TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart12TrimOffLastTrackBarValue = $($script:AutoChart12OverallDataResults.count) - $script:AutoChart12TrimOffLastTrackBar.Value
        $script:AutoChart12TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart12OverallDataResults.count) - $script:AutoChart12TrimOffLastTrackBar.Value)"
        $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart12TrimOffLastGroupBox.Controls.Add($script:AutoChart12TrimOffLastTrackBar)
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart12TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart12ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart12TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart12TrimOffFirstGroupBox.Location.Y + $script:AutoChart12TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart12ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart12.Series["Security Patches Per Host"].ChartType = $script:AutoChart12ChartTypeComboBox.SelectedItem
#    $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
#    $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart12ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart12ChartTypesAvailable) { $script:AutoChart12ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart12ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart123DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart12ChartTypeComboBox.Location.X + $script:AutoChart12ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart12ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart123DToggleButton
$script:AutoChart123DInclination = 0
$script:AutoChart123DToggleButton.Add_Click({
    $script:AutoChart123DInclination += 10
    if ( $script:AutoChart123DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart12Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart12Area.Area3DStyle.Inclination = $script:AutoChart123DInclination
        $script:AutoChart123DToggleButton.Text  = "3D On ($script:AutoChart123DInclination)"
#        $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart123DInclination -le 90 ) {
        $script:AutoChart12Area.Area3DStyle.Inclination = $script:AutoChart123DInclination
        $script:AutoChart123DToggleButton.Text  = "3D On ($script:AutoChart123DInclination)"
#        $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart123DToggleButton.Text  = "3D Off"
        $script:AutoChart123DInclination = 0
        $script:AutoChart12Area.Area3DStyle.Inclination = $script:AutoChart123DInclination
        $script:AutoChart12Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart123DToggleButton)

### Change the color of the chart
$script:AutoChart12ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart123DToggleButton.Location.X + $script:AutoChart123DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart123DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart12ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart12ColorsAvailable) { $script:AutoChart12ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart12ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart12.Series["Security Patches Per Host"].Color = $script:AutoChart12ChangeColorComboBox.SelectedItem
})
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart12ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart12 {
    # List of Positive Endpoints that positively match
    $script:AutoChart12ImportCsvPosResults = $script:AutoChartSecurityPatchesDataSource | Where-Object 'Name' -eq $($script:AutoChart12InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart12InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart12ImportCsvPosResults) { $script:AutoChart12InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart12ImportCsvAll = $script:AutoChartSecurityPatchesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart12ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart12ImportCsvAll) { if ($Endpoint -notin $script:AutoChart12ImportCsvPosResults) { $script:AutoChart12ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart12InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart12ImportCsvNegResults) { $script:AutoChart12InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart12InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart12ImportCsvPosResults.count))"
    $script:AutoChart12InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart12ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart12CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart12TrimOffLastGroupBox.Location.X + $script:AutoChart12TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart12TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart12CheckDiffButton
$script:AutoChart12CheckDiffButton.Add_Click({
    $script:AutoChart12InvestDiffDropDownArraY = $script:AutoChartSecurityPatchesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart12InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart12InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart12InvestDiffDropDownLabel.Location.y + $script:AutoChart12InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart12InvestDiffDropDownArray) { $script:AutoChart12InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart12InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart12 }})
    $script:AutoChart12InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart12 })

    ### Investigate Difference Execute Button
    $script:AutoChart12InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart12InvestDiffDropDownComboBox.Location.y + $script:AutoChart12InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart12InvestDiffExecuteButton
    $script:AutoChart12InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart12 }})
    $script:AutoChart12InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart12 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart12InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart12InvestDiffExecuteButton.Location.y + $script:AutoChart12InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart12InvestDiffPosResultsLabel.Location.y + $script:AutoChart12InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart12InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart12InvestDiffPosResultsLabel.Location.x + $script:AutoChart12InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart12InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart12InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart12InvestDiffNegResultsLabel.Location.y + $script:AutoChart12InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart12InvestDiffForm.Controls.AddRange(@($script:AutoChart12InvestDiffDropDownLabel,$script:AutoChart12InvestDiffDropDownComboBox,$script:AutoChart12InvestDiffExecuteButton,$script:AutoChart12InvestDiffPosResultsLabel,$script:AutoChart12InvestDiffPosResultsTextBox,$script:AutoChart12InvestDiffNegResultsLabel,$script:AutoChart12InvestDiffNegResultsTextBox))
    $script:AutoChart12InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart12InvestDiffForm.ShowDialog()
})
$script:AutoChart12CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart12ManipulationPanel.controls.Add($script:AutoChart12CheckDiffButton)


$AutoChart12ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart12CheckDiffButton.Location.X + $script:AutoChart12CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart12CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSecurityPatchesDataSourceFileName -QueryName "Security Patches" -QueryTabName "Security Patches Per Host" -PropertyX "ComputerName" -PropertyY "HotFixID" }
}
Apply-CommonButtonSettings -Button $AutoChart12ExpandChartButton
$script:AutoChart12ManipulationPanel.Controls.Add($AutoChart12ExpandChartButton)


$script:AutoChart12OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart12CheckDiffButton.Location.X
                   Y = $script:AutoChart12CheckDiffButton.Location.Y + $script:AutoChart12CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12OpenInShell
$script:AutoChart12OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSecurityPatchesCSVFileMostRecentCollection })
$script:AutoChart12ManipulationPanel.controls.Add($script:AutoChart12OpenInShell)


$script:AutoChart12ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart12OpenInShell.Location.X + $script:AutoChart12OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart12OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ViewResults
$script:AutoChart12ViewResults.Add_Click({ $script:AutoChartSecurityPatchesDataSource | Out-GridView -Title "$script:AutoChartSecurityPatchesCSVFileMostRecentCollection" })
$script:AutoChart12ManipulationPanel.controls.Add($script:AutoChart12ViewResults)


### Save the chart to file
$script:AutoChart12SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart12OpenInShell.Location.X
                  Y = $script:AutoChart12OpenInShell.Location.Y + $script:AutoChart12OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart12SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart12 -Title $script:AutoChart12Title
})
$script:AutoChart12ManipulationPanel.controls.Add($script:AutoChart12SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart12NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart12SaveButton.Location.X
                        Y = $script:AutoChart12SaveButton.Location.Y + $script:AutoChart12SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart12CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart12ManipulationPanel.Controls.Add($script:AutoChart12NoticeTextbox)

$script:AutoChart12.Series["Security Patches Per Host"].Points.Clear()
$script:AutoChart12OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart12TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
















##############################################################################################
# AutoChart13
##############################################################################################

$script:AutoChartSmbSharesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'SMB Shares') { $script:AutoChartSmbSharesCSVFileMatch += $CSVFile } }
}
$script:AutoChartSmbSharesCSVFileMostRecentCollection = $script:AutoChartSmbSharesCSVFileMatch | Select-Object -Last 1
$script:AutoChartSmbSharesDataSource = Import-Csv $script:AutoChartSmbSharesCSVFileMostRecentCollection


### Auto Create Charts Object
$script:AutoChart13 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart11.Location.X
                  Y = $script:AutoChart11.Location.Y + $script:AutoChart11.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart13.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart13Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart13.Titles.Add($script:AutoChart13Title)

### Create Charts Area
$script:AutoChart13Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart13Area.Name        = 'Chart Area'
$script:AutoChart13Area.AxisX.Title = 'Hosts'
$script:AutoChart13Area.AxisX.Interval          = 1
$script:AutoChart13Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart13Area.Area3DStyle.Enable3D    = $false
$script:AutoChart13Area.Area3DStyle.Inclination = 75
$script:AutoChart13.ChartAreas.Add($script:AutoChart13Area)

### Auto Create Charts Data Series Recent
$script:AutoChart13.Series.Add("Share Names")
$script:AutoChart13.Series["Share Names"].Enabled           = $True
$script:AutoChart13.Series["Share Names"].BorderWidth       = 1
$script:AutoChart13.Series["Share Names"].IsVisibleInLegend = $false
$script:AutoChart13.Series["Share Names"].Chartarea         = 'Chart Area'
$script:AutoChart13.Series["Share Names"].Legend            = 'Legend'
$script:AutoChart13.Series["Share Names"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart13.Series["Share Names"]['PieLineColor']   = 'Black'
$script:AutoChart13.Series["Share Names"]['PieLabelStyle']  = 'Outside'
$script:AutoChart13.Series["Share Names"].ChartType         = 'Column'
$script:AutoChart13.Series["Share Names"].Color             = 'SlateBLue'

        function Generate-AutoChart13 {
            $script:AutoChart13CsvFileHosts      = $script:AutoChartSmbSharesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart13UniqueDataFields  = $script:AutoChartSmbSharesDataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart13UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart13.Series["Share Names"].Points.Clear()

            if ($script:AutoChart13UniqueDataFields.count -gt 0){
                $script:AutoChart13Title.ForeColor = 'Black'
                $script:AutoChart13Title.Text = "Share Names"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart13OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart13UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart13CsvComputers = @()
                    foreach ( $Line in $script:AutoChartSmbSharesDataSource ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart13CsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart13CsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart13UniqueCount = $script:AutoChart13CsvComputers.Count
                    $script:AutoChart13DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart13UniqueCount
                        Computers   = $script:AutoChart13CsvComputers
                    }
                    $script:AutoChart13OverallDataResults += $script:AutoChart13DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart13TrimOffLastTrackBar.SetRange(0, $($script:AutoChart13OverallDataResults.count))
                $script:AutoChart13TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart13OverallDataResults.count))
            }
            else {
                $script:AutoChart13Title.ForeColor = 'Red'
                $script:AutoChart13Title.Text = "Share Names`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart13

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart13OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart13.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart13.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart13OptionsButton
$script:AutoChart13OptionsButton.Add_Click({
    if ($script:AutoChart13OptionsButton.Text -eq 'Options v') {
        $script:AutoChart13OptionsButton.Text = 'Options ^'
        $script:AutoChart13.Controls.Add($script:AutoChart13ManipulationPanel)
    }
    elseif ($script:AutoChart13OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart13OptionsButton.Text = 'Options v'
        $script:AutoChart13.Controls.Remove($script:AutoChart13ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart13OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart13)


$script:AutoChart13ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart13.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart13.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart13TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart13TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart13TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart13OverallDataResults.count))
    $script:AutoChart13TrimOffFirstTrackBarValue   = 0
    $script:AutoChart13TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart13TrimOffFirstTrackBarValue = $script:AutoChart13TrimOffFirstTrackBar.Value
        $script:AutoChart13TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart13TrimOffFirstTrackBar.Value)"
        $script:AutoChart13.Series["Share Names"].Points.Clear()
        $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart13TrimOffFirstGroupBox.Controls.Add($script:AutoChart13TrimOffFirstTrackBar)
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart13TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart13TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart13TrimOffFirstGroupBox.Location.X + $script:AutoChart13TrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart13TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart13TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart13TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart13TrimOffLastTrackBar.SetRange(0, $($script:AutoChart13OverallDataResults.count))
    $script:AutoChart13TrimOffLastTrackBar.Value         = $($script:AutoChart13OverallDataResults.count)
    $script:AutoChart13TrimOffLastTrackBarValue   = 0
    $script:AutoChart13TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart13TrimOffLastTrackBarValue = $($script:AutoChart13OverallDataResults.count) - $script:AutoChart13TrimOffLastTrackBar.Value
        $script:AutoChart13TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart13OverallDataResults.count) - $script:AutoChart13TrimOffLastTrackBar.Value)"
        $script:AutoChart13.Series["Share Names"].Points.Clear()
        $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart13TrimOffLastGroupBox.Controls.Add($script:AutoChart13TrimOffLastTrackBar)
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart13TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart13ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart13TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart13TrimOffFirstGroupBox.Location.Y + $script:AutoChart13TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart13ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart13.Series["Share Names"].ChartType = $script:AutoChart13ChartTypeComboBox.SelectedItem
#    $script:AutoChart13.Series["Share Names"].Points.Clear()
#    $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart13ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart13ChartTypesAvailable) { $script:AutoChart13ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart13ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart133DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart13ChartTypeComboBox.Location.X + $script:AutoChart13ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart13ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart133DToggleButton
$script:AutoChart133DInclination = 0
$script:AutoChart133DToggleButton.Add_Click({

    $script:AutoChart133DInclination += 10
    if ( $script:AutoChart133DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart13Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart13Area.Area3DStyle.Inclination = $script:AutoChart133DInclination
        $script:AutoChart133DToggleButton.Text  = "3D On ($script:AutoChart133DInclination)"
#        $script:AutoChart13.Series["Share Names"].Points.Clear()
#        $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart133DInclination -le 90 ) {
        $script:AutoChart13Area.Area3DStyle.Inclination = $script:AutoChart133DInclination
        $script:AutoChart133DToggleButton.Text  = "3D On ($script:AutoChart133DInclination)"
#        $script:AutoChart13.Series["Share Names"].Points.Clear()
#        $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart133DToggleButton.Text  = "3D Off"
        $script:AutoChart133DInclination = 0
        $script:AutoChart13Area.Area3DStyle.Inclination = $script:AutoChart133DInclination
        $script:AutoChart13Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart13.Series["Share Names"].Points.Clear()
#        $script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart133DToggleButton)

### Change the color of the chart
$script:AutoChart13ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart133DToggleButton.Location.X + $script:AutoChart133DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart133DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart13ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart13ColorsAvailable) { $script:AutoChart13ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart13ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart13.Series["Share Names"].Color = $script:AutoChart13ChangeColorComboBox.SelectedItem
})
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart13ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart13 {
    # List of Positive Endpoints that positively match
    $script:AutoChart13ImportCsvPosResults = $script:AutoChartSmbSharesDataSource | Where-Object 'Name' -eq $($script:AutoChart13InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart13InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart13ImportCsvPosResults) { $script:AutoChart13InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart13ImportCsvAll = $script:AutoChartSmbSharesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart13ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart13ImportCsvAll) { if ($Endpoint -notin $script:AutoChart13ImportCsvPosResults) { $script:AutoChart13ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart13InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart13ImportCsvNegResults) { $script:AutoChart13InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart13InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart13ImportCsvPosResults.count))"
    $script:AutoChart13InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart13ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart13CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart13TrimOffLastGroupBox.Location.X + $script:AutoChart13TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart13TrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart13CheckDiffButton
$script:AutoChart13CheckDiffButton.Add_Click({
    $script:AutoChart13InvestDiffDropDownArraY = $script:AutoChartSmbSharesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart13InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart13InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart13InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart13InvestDiffDropDownLabel.Location.y + $script:AutoChart13InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart13InvestDiffDropDownArray) { $script:AutoChart13InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart13InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart13 }})
    $script:AutoChart13InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart13 })

    ### Investigate Difference Execute Button
    $script:AutoChart13InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart13InvestDiffDropDownComboBox.Location.y + $script:AutoChart13InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart13InvestDiffExecuteButton
    $script:AutoChart13InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart13 }})
    $script:AutoChart13InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart13 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart13InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart13InvestDiffExecuteButton.Location.y + $script:AutoChart13InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart13InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart13InvestDiffPosResultsLabel.Location.y + $script:AutoChart13InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart13InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart13InvestDiffPosResultsLabel.Location.x + $script:AutoChart13InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart13InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart13InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart13InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart13InvestDiffNegResultsLabel.Location.y + $script:AutoChart13InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart13InvestDiffForm.Controls.AddRange(@($script:AutoChart13InvestDiffDropDownLabel,$script:AutoChart13InvestDiffDropDownComboBox,$script:AutoChart13InvestDiffExecuteButton,$script:AutoChart13InvestDiffPosResultsLabel,$script:AutoChart13InvestDiffPosResultsTextBox,$script:AutoChart13InvestDiffNegResultsLabel,$script:AutoChart13InvestDiffNegResultsTextBox))
    $script:AutoChart13InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart13InvestDiffForm.ShowDialog()
})
$script:AutoChart13CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart13ManipulationPanel.controls.Add($script:AutoChart13CheckDiffButton)


$AutoChart13ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart13CheckDiffButton.Location.X + $script:AutoChart13CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart13CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSmbSharesDataSourceFileName -QueryName "SMB Shares" -QueryTabName "Share Names" -PropertyX "Name" -PropertyY "ComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart13ExpandChartButton
$script:AutoChart13ManipulationPanel.Controls.Add($AutoChart13ExpandChartButton)


$script:AutoChart13OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart13CheckDiffButton.Location.X
                   Y = $script:AutoChart13CheckDiffButton.Location.Y + $script:AutoChart13CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart13OpenInShell
$script:AutoChart13OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSmbSharesCSVFileMostRecentCollection })
$script:AutoChart13ManipulationPanel.controls.Add($script:AutoChart13OpenInShell)


$script:AutoChart13ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart13OpenInShell.Location.X + $script:AutoChart13OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart13OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart13ViewResults
$script:AutoChart13ViewResults.Add_Click({ $script:AutoChartSmbSharesDataSource | Out-GridView -Title "$script:AutoChartSmbSharesCSVFileMostRecentCollection" })
$script:AutoChart13ManipulationPanel.controls.Add($script:AutoChart13ViewResults)


### Save the chart to file
$script:AutoChart13SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart13OpenInShell.Location.X
                  Y = $script:AutoChart13OpenInShell.Location.Y + $script:AutoChart13OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart13SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart13SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart13 -Title $script:AutoChart13Title
})
$script:AutoChart13ManipulationPanel.controls.Add($script:AutoChart13SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart13NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart13SaveButton.Location.X
                        Y = $script:AutoChart13SaveButton.Location.Y + $script:AutoChart13SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart13CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart13ManipulationPanel.Controls.Add($script:AutoChart13NoticeTextbox)

$script:AutoChart13.Series["Share Names"].Points.Clear()
$script:AutoChart13OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart13TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart13TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart13.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}














##############################################################################################
# AutoChart14
##############################################################################################

### Auto Create Charts Object
$script:AutoChart14 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart12.Location.X
                  Y = $script:AutoChart12.Location.Y + $script:AutoChart12.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart14.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart14Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart14.Titles.Add($script:AutoChart14Title)

### Create Charts Area
$script:AutoChart14Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart14Area.Name        = 'Chart Area'
$script:AutoChart14Area.AxisX.Title = 'Hosts'
$script:AutoChart14Area.AxisX.Interval          = 1
$script:AutoChart14Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart14Area.Area3DStyle.Enable3D    = $false
$script:AutoChart14Area.Area3DStyle.Inclination = 75
$script:AutoChart14.ChartAreas.Add($script:AutoChart14Area)

### Auto Create Charts Data Series Recent
$script:AutoChart14.Series.Add("Shares Per Host")
$script:AutoChart14.Series["Shares Per Host"].Enabled           = $True
$script:AutoChart14.Series["Shares Per Host"].BorderWidth       = 1
$script:AutoChart14.Series["Shares Per Host"].IsVisibleInLegend = $false
$script:AutoChart14.Series["Shares Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart14.Series["Shares Per Host"].Legend            = 'Legend'
$script:AutoChart14.Series["Shares Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart14.Series["Shares Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart14.Series["Shares Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart14.Series["Shares Per Host"].ChartType         = 'DoughNut'
$script:AutoChart14.Series["Shares Per Host"].Color             = 'SlateBLue'

        function Generate-AutoChart14 {
            $script:AutoChart14CsvFileHosts     = ($script:AutoChartSmbSharesDataSource).ComputerName | Sort-Object -Unique
            $script:AutoChart14UniqueDataFields = ($script:AutoChartSmbSharesDataSource).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart14UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart14UniqueDataFields.count -gt 0){
                $script:AutoChart14Title.ForeColor = 'Black'
                $script:AutoChart14Title.Text = "Shares Per Host"

                $AutoChart14CurrentComputer  = ''
                $AutoChart14CheckIfFirstLine = $false
                $AutoChart14ResultsCount     = 0
                $AutoChart14Computer         = @()
                $AutoChart14YResults         = @()
                $script:AutoChart14OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartSmbSharesDataSource | Sort-Object ComputerName) ) {
                    if ( $AutoChart14CheckIfFirstLine -eq $false ) { $AutoChart14CurrentComputer  = $Line.ComputerName ; $AutoChart14CheckIfFirstLine = $true }
                    if ( $AutoChart14CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart14CurrentComputer ) {
                            if ( $AutoChart14YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart14YResults += $Line.Name ; $AutoChart14ResultsCount += 1 }
                                if ( $AutoChart14Computer -notcontains $Line.ComputerName ) { $AutoChart14Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart14CurrentComputer ) {
                            $AutoChart14CurrentComputer = $Line.ComputerName
                            $AutoChart14YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart14ResultsCount
                                Computer     = $AutoChart14Computer
                            }
                            $script:AutoChart14OverallDataResults += $AutoChart14YDataResults
                            $AutoChart14YResults     = @()
                            $AutoChart14ResultsCount = 0
                            $AutoChart14Computer     = @()
                            if ( $AutoChart14YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart14YResults += $Line.Name ; $AutoChart14ResultsCount += 1 }
                                if ( $AutoChart14Computer -notcontains $Line.ComputerName ) { $AutoChart14Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart14YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart14ResultsCount ; Computer = $AutoChart14Computer }
                $script:AutoChart14OverallDataResults += $AutoChart14YDataResults
                $script:AutoChart14OverallDataResults | ForEach-Object { $script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
                $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart14TrimOffLastTrackBar.SetRange(0, $($script:AutoChart14OverallDataResults.count))
                $script:AutoChart14TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart14OverallDataResults.count))
            }
            else {
                $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
                $script:AutoChart14Title.ForeColor = 'Red'
                $script:AutoChart14Title.Text = "Shares Per Host`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart14

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart14OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart14.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart14.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart14OptionsButton
$script:AutoChart14OptionsButton.Add_Click({
    if ($script:AutoChart14OptionsButton.Text -eq 'Options v') {
        $script:AutoChart14OptionsButton.Text = 'Options ^'
        $script:AutoChart14.Controls.Add($script:AutoChart14ManipulationPanel)
    }
    elseif ($script:AutoChart14OptionsButton.Text -eq 'Options ^') {
        $script:AutoChart14OptionsButton.Text = 'Options v'
        $script:AutoChart14.Controls.Remove($script:AutoChart14ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart14OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart14)

$script:AutoChart14ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart14.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart14.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart14TrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart14TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart14TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart14OverallDataResults.count))
    $script:AutoChart14TrimOffFirstTrackBarValue   = 0
    $script:AutoChart14TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart14TrimOffFirstTrackBarValue = $script:AutoChart14TrimOffFirstTrackBar.Value
        $script:AutoChart14TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart14TrimOffFirstTrackBar.Value)"
        $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
        $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart14TrimOffFirstGroupBox.Controls.Add($script:AutoChart14TrimOffFirstTrackBar)
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart14TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart14TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart14TrimOffFirstGroupBox.Location.X + $script:AutoChart14TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart14TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart14TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart14TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart14TrimOffLastTrackBar.SetRange(0, $($script:AutoChart14OverallDataResults.count))
    $script:AutoChart14TrimOffLastTrackBar.Value         = $($script:AutoChart14OverallDataResults.count)
    $script:AutoChart14TrimOffLastTrackBarValue   = 0
    $script:AutoChart14TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart14TrimOffLastTrackBarValue = $($script:AutoChart14OverallDataResults.count) - $script:AutoChart14TrimOffLastTrackBar.Value
        $script:AutoChart14TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart14OverallDataResults.count) - $script:AutoChart14TrimOffLastTrackBar.Value)"
        $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
        $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart14TrimOffLastGroupBox.Controls.Add($script:AutoChart14TrimOffLastTrackBar)
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart14TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart14ChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart14TrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart14TrimOffFirstGroupBox.Location.Y + $script:AutoChart14TrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart14ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart14.Series["Shares Per Host"].ChartType = $script:AutoChart14ChartTypeComboBox.SelectedItem
#    $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
#    $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart14ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart14ChartTypesAvailable) { $script:AutoChart14ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart14ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart143DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart14ChartTypeComboBox.Location.X + $script:AutoChart14ChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart14ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart143DToggleButton
$script:AutoChart143DInclination = 0
$script:AutoChart143DToggleButton.Add_Click({
    $script:AutoChart143DInclination += 10
    if ( $script:AutoChart143DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart14Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart14Area.Area3DStyle.Inclination = $script:AutoChart143DInclination
        $script:AutoChart143DToggleButton.Text  = "3D On ($script:AutoChart143DInclination)"
#        $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart143DInclination -le 90 ) {
        $script:AutoChart14Area.Area3DStyle.Inclination = $script:AutoChart143DInclination
        $script:AutoChart143DToggleButton.Text  = "3D On ($script:AutoChart143DInclination)"
#        $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart143DToggleButton.Text  = "3D Off"
        $script:AutoChart143DInclination = 0
        $script:AutoChart14Area.Area3DStyle.Inclination = $script:AutoChart143DInclination
        $script:AutoChart14Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart14.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart143DToggleButton)

### Change the color of the chart
$script:AutoChart14ChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart143DToggleButton.Location.X + $script:AutoChart143DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart143DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart14ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart14ColorsAvailable) { $script:AutoChart14ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart14ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart14.Series["Shares Per Host"].Color = $script:AutoChart14ChangeColorComboBox.SelectedItem
})
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart14ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart14 {
    # List of Positive Endpoints that positively match
    $script:AutoChart14ImportCsvPosResults = $script:AutoChartSmbSharesDataSource | Where-Object 'Name' -eq $($script:AutoChart14InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart14InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart14ImportCsvPosResults) { $script:AutoChart14InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart14ImportCsvAll = $script:AutoChartSmbSharesDataSource | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart14ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart14ImportCsvAll) { if ($Endpoint -notin $script:AutoChart14ImportCsvPosResults) { $script:AutoChart14ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart14InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart14ImportCsvNegResults) { $script:AutoChart14InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart14InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart14ImportCsvPosResults.count))"
    $script:AutoChart14InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart14ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart14CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart14TrimOffLastGroupBox.Location.X + $script:AutoChart14TrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart14TrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart14CheckDiffButton
$script:AutoChart14CheckDiffButton.Add_Click({
    $script:AutoChart14InvestDiffDropDownArraY = $script:AutoChartSmbSharesDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart14InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart14InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart14InvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart14InvestDiffDropDownLabel.Location.y + $script:AutoChart14InvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart14InvestDiffDropDownArray) { $script:AutoChart14InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart14InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart14 }})
    $script:AutoChart14InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart14 })

    ### Investigate Difference Execute Button
    $script:AutoChart14InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart14InvestDiffDropDownComboBox.Location.y + $script:AutoChart14InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart14InvestDiffExecuteButton
    $script:AutoChart14InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart14 }})
    $script:AutoChart14InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart14 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart14InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart14InvestDiffExecuteButton.Location.y + $script:AutoChart14InvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart14InvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart14InvestDiffPosResultsLabel.Location.y + $script:AutoChart14InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart14InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart14InvestDiffPosResultsLabel.Location.x + $script:AutoChart14InvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart14InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart14InvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart14InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart14InvestDiffNegResultsLabel.Location.y + $script:AutoChart14InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart14InvestDiffForm.Controls.AddRange(@($script:AutoChart14InvestDiffDropDownLabel,$script:AutoChart14InvestDiffDropDownComboBox,$script:AutoChart14InvestDiffExecuteButton,$script:AutoChart14InvestDiffPosResultsLabel,$script:AutoChart14InvestDiffPosResultsTextBox,$script:AutoChart14InvestDiffNegResultsLabel,$script:AutoChart14InvestDiffNegResultsTextBox))
    $script:AutoChart14InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart14InvestDiffForm.ShowDialog()
})
$script:AutoChart14CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart14ManipulationPanel.controls.Add($script:AutoChart14CheckDiffButton)


$AutoChart14ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart14CheckDiffButton.Location.X + $script:AutoChart14CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart14CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartSmbSharesDataSourceFileName -QueryName "SMB Shares" -QueryTabName "Shares Per Host" -PropertyX "ComputerName" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart14ExpandChartButton
$script:AutoChart14ManipulationPanel.Controls.Add($AutoChart14ExpandChartButton)


$script:AutoChart14OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart14CheckDiffButton.Location.X
                   Y = $script:AutoChart14CheckDiffButton.Location.Y + $script:AutoChart14CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart14OpenInShell
$script:AutoChart14OpenInShell.Add_Click({ AutoChartOpenDataInShell -MostRecentCollection $script:AutoChartSmbSharesCSVFileMostRecentCollection })
$script:AutoChart14ManipulationPanel.controls.Add($script:AutoChart14OpenInShell)


$script:AutoChart14ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart14OpenInShell.Location.X + $script:AutoChart14OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart14OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart14ViewResults
$script:AutoChart14ViewResults.Add_Click({ $script:AutoChartSmbSharesDataSource | Out-GridView -Title "$script:AutoChartSmbSharesCSVFileMostRecentCollection" })
$script:AutoChart14ManipulationPanel.controls.Add($script:AutoChart14ViewResults)


### Save the chart to file
$script:AutoChart14SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart14OpenInShell.Location.X
                  Y = $script:AutoChart14OpenInShell.Location.Y + $script:AutoChart14OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart14SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart14SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart14 -Title $script:AutoChart14Title
})
$script:AutoChart14ManipulationPanel.controls.Add($script:AutoChart14SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart14NoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart14SaveButton.Location.X
                        Y = $script:AutoChart14SaveButton.Location.Y + $script:AutoChart14SaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart14CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart14ManipulationPanel.Controls.Add($script:AutoChart14NoticeTextbox)

$script:AutoChart14.Series["Shares Per Host"].Points.Clear()
$script:AutoChart14OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart14TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart14TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart14.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




























