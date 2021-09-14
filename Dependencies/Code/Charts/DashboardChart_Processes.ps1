$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Process Info'
    Width  = $FormScale * 1700
    Height = $FormScale * 1050
    #Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    AutoScroll    = $True
}
$AutoChartsTabControl.Controls.Add($script:AutoChartsIndividualTab01)

# Searches though the all Collection Data Directories to find files that match
$script:ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName

$script:AutoChartsProgressBar.ForeColor = 'Black'
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = 1
$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Update()

$script:AutoChartCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Processes') { $script:AutoChartCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChartCSVFileMatch | Select-Object -Last 1
$DashboardChartsCsvDataProcesses = $null
$DashboardChartsCsvDataProcesses = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChartOptionsButton.Text = 'Options v'
    $script:AutoChart.Controls.Remove($script:AutoChartManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Process Info'
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 1150
    Height = $FormScale * 25
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter'
}










$script:AutoChartOpenResultsOpenFileDialogfilename = $null

$script:AutoChartDataSourceXmlPath = $null

function AutoChartOpenDataInShell {
    if ($script:AutoChartOpenResultsOpenFileDialogfilename) { $ViewImportResults = $script:AutoChartOpenResultsOpenFileDialogfilename -replace '.csv','.xml' }
    else { $ViewImportResults = $script:AutoChartCSVFileMostRecentCollection -replace '.csv','.xml' }

    if (Test-Path $ViewImportResults) {
        $SavePath = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename
        $FileName = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename -Leaf

        Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}















function Generate-Chart {
    param(
        $SeriesName
    )
    ##############################################################################################
    # AutoChart01
    ##############################################################################################

    ### Auto Create Charts Object
    $script:AutoChart = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{

        Left   = $FormScale * 5
        Top    = $FormScale * 50
        Width  = $FormScale * 560
        Height = $FormScale * 375
        BackColor       = [System.Drawing.Color]::White
        BorderColor     = 'Black'
        Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
        BorderDashStyle = 'Solid'
    }
    $script:AutoChart.Add_MouseHover({ Close-AllOptions })

    ### Auto Create Charts Title
    $script:AutoChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
        Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
        Alignment = "topcenter"
    }
    $script:AutoChart.Titles.Add($script:AutoChartTitle)

    ### Create Charts Area
    $script:AutoChartArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $script:AutoChartArea.Name        = 'Chart Area'
    $script:AutoChartArea.AxisX.Title = 'Hosts'
    $script:AutoChartArea.AxisX.Interval          = 1
    $script:AutoChartArea.AxisY.IntervalAutoMode  = $true
    $script:AutoChartArea.Area3DStyle.Enable3D    = $false
    $script:AutoChartArea.Area3DStyle.Inclination = 75
    $script:AutoChart.ChartAreas.Add($script:AutoChartArea)

    ### Auto Create Charts Data Series Recent
iex @"
    `$script:AutoChart.Series.Add('$SeriesName')
    `$script:AutoChart.Series['$SeriesName'].Enabled           = `$True
    `$script:AutoChart.Series['$SeriesName'].BorderWidth       = 1
    `$script:AutoChart.Series['$SeriesName'].IsVisibleInLegend = `$false
    `$script:AutoChart.Series['$SeriesName'].Chartarea         = 'Chart Area'
    `$script:AutoChart.Series['$SeriesName'].Legend            = 'Legend'
    `$script:AutoChart.Series['$SeriesName'].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    `$script:AutoChart.Series['$SeriesName']['PieLineColor']   = 'Black'
    `$script:AutoChart.Series['$SeriesName']['PieLabelStyle']  = 'Outside'
    `$script:AutoChart.Series['$SeriesName'].ChartType         = 'Column'
    `$script:AutoChart.Series['$SeriesName'].Color             = 'Red'
"@
            function Generate-AutoChart01 {
                $script:AutoChartCsvFileHosts      = $DashboardChartsCsvDataProcesses | Select-Object -ExpandProperty 'PSComputerName' -Unique
                $script:AutoChartUniqueDataFields  = $DashboardChartsCsvDataProcesses | Select-Object -Property 'com' | Sort-Object -Property 'Name' -Unique

                $script:AutoChartsProgressBar.ForeColor = 'Red'
                $script:AutoChartsProgressBar.Minimum = 0
                $script:AutoChartsProgressBar.Maximum = $script:AutoChartUniqueDataFields.count
                $script:AutoChartsProgressBar.Value   = 0
                $script:AutoChartsProgressBar.Update()

                iex "`$script:AutoChart.Series['$SeriesName'].Points.Clear()"

                if ($script:AutoChartUniqueDataFields.count -gt 0){
                    $script:AutoChartTitle.ForeColor = 'Black'
                    iex "`$script:AutoChartTitle.Text = '$SeriesName'"

                    # If the Second field/Y Axis equals PSComputername, it counts it
                    $script:AutoChartOverallDataResults = @()

                    # Generates and Counts the data - Counts the number of times that any given property possess a given value
                    foreach ($DataField in $script:AutoChartUniqueDataFields) {
                        $Count        = 0
                        $script:AutoChartCsvComputers = @()
                        foreach ( $Line in $DashboardChartsCsvDataProcesses ) {
                            if ($($Line.Name) -eq $DataField.Name) {
                                $Count += 1
                                if ( $script:AutoChartCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChartCsvComputers += $($Line.PSComputerName) }
                            }
                        }
                        $script:AutoChartUniqueCount = $script:AutoChartCsvComputers.Count
                        $script:AutoChartDataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:AutoChartUniqueCount
                            Computers   = $script:AutoChartCsvComputers
                        }
                        $script:AutoChartOverallDataResults += $script:AutoChartDataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()
                    }
                    iex "`$script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { `$script:AutoChart.Series['$SeriesName'].Points.AddXY(`$_.DataField.Name,`$_.UniqueCount) }"
                    $script:AutoChartTrimOffLastTrackBar.SetRange(0, $($script:AutoChartOverallDataResults.count))
                    $script:AutoChartTrimOffFirstTrackBar.SetRange(0, $($script:AutoChartOverallDataResults.count))
                }
                else {
                    $script:AutoChartTitle.ForeColor = 'Red'
                    $script:AutoChartTitle.Text = "$SeriesName`n
    [ No Data Available ]`n"
                }
            }
            Generate-AutoChart01

    ### Auto Chart Panel that contains all the options to manage open/close feature
    $script:AutoChartOptionsButton = New-Object Windows.Forms.Button -Property @{
        Text   = "Options v"
        Left   = $script:AutoChart.Left + $($FormScale * 5)
        Top    = $script:AutoChart.Top + $($FormScale * 350)
        Width  = $FormScale * 75
        Height = $FormScale * 20 
    }
    Apply-CommonButtonSettings -Button $script:AutoChartOptionsButton
    $script:AutoChartOptionsButton.Add_Click({
        if ($script:AutoChartOptionsButton.Text -eq 'Options v') {
            $script:AutoChartOptionsButton.Text = 'Options ^'
            $script:AutoChart.Controls.Add($script:AutoChartManipulationPanel)
        }
        elseif ($script:AutoChartOptionsButton.Text -eq 'Options ^') {
            $script:AutoChartOptionsButton.Text = 'Options v'
            $script:AutoChart.Controls.Remove($script:AutoChartManipulationPanel)
        }
    })
    $script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartOptionsButton)
    $script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart)

    $script:AutoChartManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
        Left     = 0
        Top      = $script:AutoChart.Height - $($FormScale * 121)
        Width    = $script:AutoChart.Width
        Height   = $FormScale * 121
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
        BackColor   = 'White'
        BorderStyle = 'FixedSingle'
    }

    ### AutoCharts - Trim Off First GroupBox
    $script:AutoChartTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text   = "Trim Off First: 0"
        Left   = $FormScale * 5
        Top    = $FormScale * 5
        Width  = $FormScale * 165
        Height = $FormScale * 85
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        ### AutoCharts - Trim Off First TrackBar
        $script:AutoChartTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Left   = $FormScale * 1
            Top    = $FormScale * 30
            Width  = $FormScale * 160
            Height = $FormScale * 25
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
            Value         = 0
        }
        $script:AutoChartTrimOffFirstTrackBar.SetRange(0, $($script:AutoChartOverallDataResults.count))
        $script:AutoChartTrimOffFirstTrackBarValue   = 0
        $script:AutoChartTrimOffFirstTrackBar.add_ValueChanged({
            $script:AutoChartTrimOffFirstTrackBarValue = $script:AutoChartTrimOffFirstTrackBar.Value
            $script:AutoChartTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChartTrimOffFirstTrackBar.Value)"
            iex "`$script:AutoChart.Series['$SeriesName'].Points.Clear()"
            iex "`$script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip `$script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast `$script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {`$script:AutoChart.Series['$SeriesName'].Points.AddXY(`$_.DataField.Name,`$_.UniqueCount)}"
        })
        $script:AutoChartTrimOffFirstGroupBox.Controls.Add($script:AutoChartTrimOffFirstTrackBar)
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChartTrimOffFirstGroupBox)

    ### Auto Charts - Trim Off Last GroupBox
    $script:AutoChartTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text   = "Trim Off Last: 0"
        Left   = $script:AutoChartTrimOffFirstGroupBox.Left + $script:AutoChartTrimOffFirstGroupBox.Width + $($FormScale * 8)
        Top    = $script:AutoChartTrimOffFirstGroupBox.Top 
        Width  = $FormScale * 165
        Height = $FormScale * 85
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        ### AutoCharts - Trim Off Last TrackBar
        $script:AutoChartTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Left   = $FormScale * 1
            Top    = $FormScale * 30
            Width  = $FormScale * 160
            Height = $FormScale * 25
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
        }
        $script:AutoChartTrimOffLastTrackBar.RightToLeft   = $true
        $script:AutoChartTrimOffLastTrackBar.SetRange(0, $($script:AutoChartOverallDataResults.count))
        $script:AutoChartTrimOffLastTrackBar.Value         = $($script:AutoChartOverallDataResults.count)
        $script:AutoChartTrimOffLastTrackBarValue   = 0
        $script:AutoChartTrimOffLastTrackBar.add_ValueChanged({
            $script:AutoChartTrimOffLastTrackBarValue = $($script:AutoChartOverallDataResults.count) - $script:AutoChartTrimOffLastTrackBar.Value
            $script:AutoChartTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChartOverallDataResults.count) - $script:AutoChartTrimOffLastTrackBar.Value)"
            iex "`$script:AutoChart.Series['$SeriesName'].Points.Clear()"
            iex "`$script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip `$script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast `$script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {`$script:AutoChart.Series['$SeriesName'].Points.AddXY(`$_.DataField.Name,`$_.UniqueCount)}"
        })
    $script:AutoChartTrimOffLastGroupBox.Controls.Add($script:AutoChartTrimOffLastTrackBar)
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChartTrimOffLastGroupBox)

    #======================================
    # Auto Create Charts Select Chart Type
    #======================================
    $script:AutoChartChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text   = 'Column'
        Left   = $script:AutoChartTrimOffFirstGroupBox.Left + $($FormScale * 80)
        Top    = $script:AutoChartTrimOffFirstGroupBox.Top + $script:AutoChartTrimOffFirstGroupBox.Height + $($FormScale * 5)
        Width  = $FormScale * 85
        Height = $FormScale * 20
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartChartTypeComboBox.add_SelectedIndexChanged({
        iex "`$script:AutoChart.Series['$SeriesName'].ChartType = `$script:AutoChartChartTypeComboBox.SelectedItem"
    #    $script:AutoChart.Series['$SeriesName'].Points.Clear()
    #    $script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series['$SeriesName'].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChartChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
    ForEach ($Item in $script:AutoChartChartTypesAvailable) { $script:AutoChartChartTypeComboBox.Items.Add($Item) }
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChartChartTypeComboBox)


    ### Auto Charts Toggle 3D on/off and inclination angle
    $script:AutoChart3DToggleButton = New-Object Windows.Forms.Button -Property @{
        Text   = "3D Off"
        Left   = $script:AutoChartChartTypeComboBox.Left + $script:AutoChartChartTypeComboBox.Width + $($FormScale * 8)
        Top    = $script:AutoChartChartTypeComboBox.Top
        Width  = $FormScale * 65
        Height = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart3DToggleButton
    $script:AutoChart3DInclination = 0
    $script:AutoChart3DToggleButton.Add_Click({

        $script:AutoChart3DInclination += 10
        if ( $script:AutoChart3DToggleButton.Text -eq "3D Off" ) {
            $script:AutoChartArea.Area3DStyle.Enable3D    = $true
            $script:AutoChartArea.Area3DStyle.Inclination = $script:AutoChart3DInclination
            $script:AutoChart3DToggleButton.Text  = "3D On ($script:AutoChart3DInclination)"
    #        $script:AutoChart.Series['$SeriesName'].Points.Clear()
    #        $script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series['$SeriesName'].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
        }
        elseif ( $script:AutoChart3DInclination -le 90 ) {
            $script:AutoChartArea.Area3DStyle.Inclination = $script:AutoChart3DInclination
            $script:AutoChart3DToggleButton.Text  = "3D On ($script:AutoChart3DInclination)"
    #        $script:AutoChart.Series['$SeriesName'].Points.Clear()
    #        $script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series['$SeriesName'].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
        }
        else {
            $script:AutoChart3DToggleButton.Text  = "3D Off"
            $script:AutoChart3DInclination = 0
            $script:AutoChartArea.Area3DStyle.Inclination = $script:AutoChart3DInclination
            $script:AutoChartArea.Area3DStyle.Enable3D    = $false
    #        $script:AutoChart.Series['$SeriesName'].Points.Clear()
    #        $script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series['$SeriesName'].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
        }
    })
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChart3DToggleButton)

    ### Change the color of the chart
    $script:AutoChartChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Change Color"
        Left = $script:AutoChart3DToggleButton.Left + $script:AutoChart3DToggleButton.Width + $($FormScale * 5)
        Top = $script:AutoChart3DToggleButton.Top
        Width  = $FormScale * 95
        Height = $FormScale * 20
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $script:AutoChartColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach ($Item in $script:AutoChartColorsAvailable) { $script:AutoChartChangeColorComboBox.Items.Add($Item) }
    $script:AutoChartChangeColorComboBox.add_SelectedIndexChanged({
        iex "`$script:AutoChart.Series['$SeriesName'].Color = `$script:AutoChartChangeColorComboBox.SelectedItem"
    })
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChartChangeColorComboBox)


    #=====================================
    # AutoCharts - Investigate Difference
    #=====================================
    function script:InvestigateDifference-AutoChart01 {
        # List of Positive Endpoints that positively match
        $script:AutoChartImportCsvPosResults = $DashboardChartsCsvDataProcesses | Where-Object 'Name' -eq $($script:AutoChartInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
        $script:AutoChartInvestDiffPosResultsTextBox.Text = ''
        ForEach ($Endpoint in $script:AutoChartImportCsvPosResults) { $script:AutoChartInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

        # List of all endpoints within the csv file
        $script:AutoChartImportCsvAll = $DashboardChartsCsvDataProcesses | Select-Object -ExpandProperty 'PSComputerName' -Unique

        $script:AutoChartImportCsvNegResults = @()
        # Creates a list of Endpoints with Negative Results
        foreach ($Endpoint in $script:AutoChartImportCsvAll) { if ($Endpoint -notin $script:AutoChartImportCsvPosResults) { $script:AutoChartImportCsvNegResults += $Endpoint } }

        # Populates the listbox with Negative Endpoint Results
        $script:AutoChartInvestDiffNegResultsTextBox.Text = ''
        ForEach ($Endpoint in $script:AutoChartImportCsvNegResults) { $script:AutoChartInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

        # Updates the label to include the count
        $script:AutoChartInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChartImportCsvPosResults.count))"
        $script:AutoChartInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChartImportCsvNegResults.count))"
    }

    #==============================
    # Auto Chart Buttons
    #==============================
    ### Auto Create Charts Check Diff Button
    $script:AutoChartCheckDiffButton = New-Object Windows.Forms.Button -Property @{
        Text      = 'Investigate'
        Left = $script:AutoChartTrimOffLastGroupBox.Left + $script:AutoChartTrimOffLastGroupBox.Width + $($FormScale * 5)
        Top = $script:AutoChartTrimOffLastGroupBox.Top + $($FormScale * 5)
        Width  = $FormScale * 100
        Height = $FormScale * 23
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    Apply-CommonButtonSettings -Button $script:AutoChartCheckDiffButton
    $script:AutoChartCheckDiffButton.Add_Click({
        $script:AutoChartInvestDiffDropDownArray = $DashboardChartsCsvDataProcesses | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

        ### Investigate Difference Compare Csv Files Form
        $script:AutoChartInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
            Text   = 'Investigate Difference'
            Width  = $FormScale * 330
            Height = $FormScale * 360
            Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
            StartPosition = "CenterScreen"
            ControlBox = $true
            Add_Closing = { $This.dispose() }
        }

        ### Investigate Difference Drop Down Label & ComboBox
        $script:AutoChartInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Investigate the difference between computers."
            Left   = $FormScale * 10
            Top    = $FormScale * 10 
            Width  = $FormScale * 290
            Height = $FormScale * 45
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $script:AutoChartInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Left   = $FormScale * 10
            Top    = $script:AutoChartInvestDiffDropDownLabel.Top + $script:AutoChartInvestDiffDropDownLabel.Height
            Width  = $Formscale * 290
            Height = $Formscale * 30
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        ForEach ($Item in $script:AutoChartInvestDiffDropDownArray) { $script:AutoChartInvestDiffDropDownComboBox.Items.Add($Item) }
        $script:AutoChartInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
        $script:AutoChartInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

        ### Investigate Difference Execute Button
        $script:AutoChartInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Execute"
            Left   = $FormScale * 10
            Top    = $script:AutoChartInvestDiffDropDownComboBox.Top + $script:AutoChartInvestDiffDropDownComboBox.Height + $($FormScale * 5)
            Width  = $Formscale * 100
            Height = $Formscale * 20
        }
        Apply-CommonButtonSettings -Button $script:AutoChartInvestDiffExecuteButton
        $script:AutoChartInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
        $script:AutoChartInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

        ### Investigate Difference Positive Results Label & TextBox
        $script:AutoChartInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Positive Match (+)"
            Left   = $FormScale * 10
            Top    = $script:AutoChartInvestDiffExecuteButton.Top + $script:AutoChartInvestDiffExecuteButton.Height + $($FormScale *  10)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $script:AutoChartInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $FormScale * 10
            Top    = $script:AutoChartInvestDiffPosResultsLabel.Top + $script:AutoChartInvestDiffPosResultsLabel.Height
            Width  = $FormScale * 100
            Height = $FormScale * 178
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ReadOnly   = $true
            BackColor  = 'White'
            WordWrap   = $false
            Multiline  = $true
            ScrollBars = "Vertical"
        }

        ### Investigate Difference Negative Results Label & TextBox
        $script:AutoChartInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Negative Match (-)"
            Left   = $script:AutoChartInvestDiffPosResultsLabel.Left + $script:AutoChartInvestDiffPosResultsLabel.Width + $($FormScale *  10)
            Top    = $script:AutoChartInvestDiffPosResultsLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $script:AutoChartInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $script:AutoChartInvestDiffNegResultsLabel.Left
            Top    = $script:AutoChartInvestDiffNegResultsLabel.Top + $script:AutoChartInvestDiffNegResultsLabel.Height
            Width  = $FormScale * 100
            Height = $FormScale * 178
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ReadOnly   = $true
            BackColor  = 'White'
            WordWrap   = $false
            Multiline  = $true
            ScrollBars = "Vertical"
        }
        $script:AutoChartInvestDiffForm.Controls.AddRange(@($script:AutoChartInvestDiffDropDownLabel,$script:AutoChartInvestDiffDropDownComboBox,$script:AutoChartInvestDiffExecuteButton,$script:AutoChartInvestDiffPosResultsLabel,$script:AutoChartInvestDiffPosResultsTextBox,$script:AutoChartInvestDiffNegResultsLabel,$script:AutoChartInvestDiffNegResultsTextBox))
        $script:AutoChartInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
        $script:AutoChartInvestDiffForm.ShowDialog()
    })
    $script:AutoChartCheckDiffButton.Add_MouseHover({
    Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message "+  Allows you to quickly search for the differences`n`n" })
    $script:AutoChartManipulationPanel.controls.Add($script:AutoChartCheckDiffButton)


    $AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Multi-Series'
        Left   = $script:AutoChartCheckDiffButton.Left + $script:AutoChartCheckDiffButton.Width + $($FormScale * 5)
        Top    = $script:AutoChartCheckDiffButton.Top
        Width  = $FormScale * 100
        Height = $FormScale * 23
        Add_Click  = { 
            iex "Generate-AutoChartsCommand -FilePath `$DashboardChartsCsvDataProcessesFileName -QueryName 'Processes' -QueryTabName '$SeriesName' -PropertyX 'Name' -PropertyY 'PSComputerName'" 
        }
    }
    Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
    $script:AutoChartManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


    $script:AutoChartOpenInShell = New-Object Windows.Forms.Button -Property @{
        Text   = "Open In Shell"
        Left   = $script:AutoChartCheckDiffButton.Left
        Top    = $script:AutoChartCheckDiffButton.Top + $script:AutoChartCheckDiffButton.Height + $($FormScale * 5)
        Width  = $FormScale * 100
        Height = $FormScale * 23
    }
    Apply-CommonButtonSettings -Button $script:AutoChartOpenInShell
    $script:AutoChartOpenInShell.Add_Click({ AutoChartOpenDataInShell })
    $script:AutoChartManipulationPanel.controls.Add($script:AutoChartOpenInShell)


    $script:AutoChartViewResults = New-Object Windows.Forms.Button -Property @{
        Text   = "View Results"
        Left   = $script:AutoChartOpenInShell.Left + $script:AutoChartOpenInShell.Width + $($FormScale * 5)
        Top    = $script:AutoChartOpenInShell.Top
        Width  = $FormScale * 100
        Height = $FormScale * 23
    }
    Apply-CommonButtonSettings -Button $script:AutoChartViewResults
    $script:AutoChartViewResults.Add_Click({ $DashboardChartsCsvDataProcesses | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
    $script:AutoChartManipulationPanel.controls.Add($script:AutoChartViewResults)


    ### Save the chart to file
    $script:AutoChartSaveButton = New-Object Windows.Forms.Button -Property @{
        Text   = "Save Chart"
        Left   = $script:AutoChartOpenInShell.Left
        Top    = $script:AutoChartOpenInShell.Top + $script:AutoChartOpenInShell.Height + $($FormScale * 5)
        Width  = $FormScale * 205
        Height = $FormScale * 23
    }
    Apply-CommonButtonSettings -Button $script:AutoChartSaveButton
    [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $script:AutoChartSaveButton.Add_Click({
        Save-ChartImage -Chart $script:AutoChart -Title $script:AutoChartTitle
    })
    $script:AutoChartManipulationPanel.controls.Add($script:AutoChartSaveButton)

    #==============================
    # Auto Charts - Notice Textbox
    #==============================
    $script:AutoChartNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Left   = $script:AutoChartSaveButton.Left
        Top    = $script:AutoChartSaveButton.Top + $script:AutoChartSaveButton.Height + $($FormScale * 6)
        Width  = $FormScale * 205
        Height = $FormScale * 25
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
        ForeColor   = 'Black'
        Text        = "Endpoints:  $($script:AutoChartCsvFileHosts.Count)"
        Multiline   = $false
        Enabled     = $false
        BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
    }
    $script:AutoChartManipulationPanel.Controls.Add($script:AutoChartNoticeTextbox)

    iex "`$script:AutoChart.Series['$SeriesName'].Points.Clear()"
    $script:AutoChartOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChartTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChartTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart.Series['$SeriesName'].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
}

Generate-Chart -SeriesName 'Unique Processes'
