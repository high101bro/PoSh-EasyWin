#batman

$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:DashboardChartTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Process Info  '
    Width  = $FormScale * 1400
    Height = $FormScale * 1050
    #Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    AutoScroll    = $True
}
$AutoChartsTabControl.Controls.Add($script:DashboardChartTab)

# Searches though the all Collection Data Directories to find files that match
$script:ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName

$script:DashboardChartsProgressBar.ForeColor = 'Black'
$script:DashboardChartsProgressBar.Minimum = 0
$script:DashboardChartsProgressBar.Maximum = 1
$script:DashboardChartsProgressBar.Value   = 0
$script:DashboardChartsProgressBar.Update()

$script:DashboardChartCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Processes') { $script:DashboardChartCSVFileMatch += $CSVFile } }
}
$script:DashboardChartCSVFileMostRecentCollection = $script:DashboardChartCSVFileMatch | Select-Object -Last 1
$DashboardChartCsvData = $null
$DashboardChartCsvData = Import-Csv $script:DashboardChartCSVFileMostRecentCollection

$script:DashboardChartsProgressBar.Value = 1
$script:DashboardChartsProgressBar.Update()


function Close-AllOptions {
    $script:DashboardChartOptionsButton.Text = 'Options v'
    $script:DashboardChart.Controls.Remove($script:DashboardChartManipulationPanel)
}

### Main Label at the top
$script:DashboardChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Process Info'
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 1150
    Height = $FormScale * 25
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter'
}










$script:DashboardChartOpenResultsOpenFileDialogfilename = $null

$script:DashboardChartDataSourceXmlPath = $null

function AutoChartOpenDataInShell {
    if ($script:DashboardChartOpenResultsOpenFileDialogfilename) { $ViewImportResults = $script:DashboardChartOpenResultsOpenFileDialogfilename -replace '.csv','.xml' }
    else { $ViewImportResults = $script:DashboardChartCSVFileMostRecentCollection -replace '.csv','.xml' }

    if (Test-Path $ViewImportResults) {
        $SavePath = Split-Path -Path $script:DashboardChartOpenResultsOpenFileDialogfilename
        $FileName = Split-Path -Path $script:DashboardChartOpenResultsOpenFileDialogfilename -Leaf

        Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}














function Generate-Chart {
    param(
        $ChartNumber = $(Get-Random),
        $Title,
        [switch]$ByEndpoint,
        [switch]$PerEndpoint,
        $ChartLeft = 5,
        $ChartTop = 50,
        $ChartWidth = 560,
        $ChartHeight = 375,
        $ChartType,
        $ChartColor,
        $Property,
        $SeriesName
     )
     Invoke-Expression @"

    ### Auto Create Charts Object
    `$script:DashboardChart$($ChartNumber) = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{

        Left   = `$FormScale * $ChartLeft
        Top    = `$FormScale * $ChartTop
        Width  = `$FormScale * $ChartWidth
        Height = `$FormScale * $ChartHeight
        BackColor       = [System.Drawing.Color]::White
        BorderColor     = 'Black'
        Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
        BorderDashStyle = 'Solid'
        Add_MouseHover  = { Close-AllOptions }
    }

    ### Auto Create Charts Title
    `$script:DashboardChart$($ChartNumber)Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
        Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
        Alignment = "topcenter"
    }
    `$script:DashboardChart$($ChartNumber).Titles.Add(`$script:DashboardChart$($ChartNumber)Title)

    ### Create Charts Area
    `$script:DashboardChart$($ChartNumber)Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    `$script:DashboardChart$($ChartNumber)Area.Name        = 'Chart Area'
    `$script:DashboardChart$($ChartNumber)Area.AxisX.Title = 'Hosts'
    `$script:DashboardChart$($ChartNumber)Area.AxisX.Interval          = 1
    `$script:DashboardChart$($ChartNumber)Area.AxisY.IntervalAutoMode  = `$true
    `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Enable3D    = `$false
    `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Inclination = 75
    `$script:DashboardChart$($ChartNumber).ChartAreas.Add(`$script:DashboardChart$($ChartNumber)Area)

    ### Auto Create Charts Data Series Recent
    `$script:DashboardChart$($ChartNumber).Series.Add('$SeriesName')
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Enabled           = `$True
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].BorderWidth       = 1
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].IsVisibleInLegend = `$false
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Chartarea         = 'Chart Area'
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Legend            = 'Legend'
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName']['PieLineColor']   = 'Black'
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName']['PieLabelStyle']  = 'Outside'
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].ChartType         = 'Column'
    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Color             = '$ChartColor'

            if (`$ByEndpoint) {
                `$script:DashboardChart$($ChartNumber)CsvFileHosts      = `$DashboardChartCsvData | Select-Object -ExpandProperty 'ComputerName' -Unique
                `$script:DashboardChart$($ChartNumber)UniqueDataFields  = `$DashboardChartCsvData | Select-Object -Property '$Property' | Sort-Object -Property '$Property' -Unique

                `$script:DashboardChart$($ChartNumber)ProgressBar.ForeColor = '$ChartColor'
                `$script:DashboardChart$($ChartNumber)ProgressBar.Minimum = 0
                `$script:DashboardChart$($ChartNumber)ProgressBar.Maximum = `$script:DashboardChart$($ChartNumber)UniqueDataFields.count
                `$script:DashboardChart$($ChartNumber)ProgressBar.Value   = 0
                `$script:DashboardChart$($ChartNumber)ProgressBar.Update()

                `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.Clear()

                if (`$script:DashboardChart$($ChartNumber)UniqueDataFields.count -gt 0){
                    `$script:DashboardChart$($ChartNumber)Title.ForeColor = 'Black'
                    `$script:DashboardChart$($ChartNumber)Title.Text = '$SeriesName'

                    # If the Second field/Y Axis equals ComputerName, it counts it
                    `$script:DashboardChart$($ChartNumber)OverallDataResults = @()

                    # Generates and Counts the data - Counts the number of times that any given property possess a given value
                    foreach (`$DataField in `$script:DashboardChart$($ChartNumber)UniqueDataFields) {
                        `$Count        = 0
                        `$script:DashboardChart$($ChartNumber)CsvComputers = @()
                        foreach ( `$Line in `$DashboardChartCsvData ) {
                            if (`$(`$Line.$Property) -eq `$DataField.$Property) {
                                `$Count += 1
                                if ( `$script:DashboardChart$($ChartNumber)CsvComputers -notcontains `$(`$Line.ComputerName) ) { 
                                    `$script:DashboardChart$($ChartNumber)CsvComputers += `$(`$Line.ComputerName) 
                                }
                            }
                        }
                        `$script:DashboardChart$($ChartNumber)UniqueCount = `$script:DashboardChart$($ChartNumber)CsvComputers.Count
                        `$script:DashboardChart$($ChartNumber)DataResults = New-Object PSObject -Property @{
                            DataField   = `$DataField
                            TotalCount  = `$Count
                            UniqueCount = `$script:DashboardChart$($ChartNumber)UniqueCount
                            Computers   = `$script:DashboardChart$($ChartNumber)CsvComputers
                        }
                        `$script:DashboardChart$($ChartNumber)OverallDataResults += `$script:DashboardChart$($ChartNumber)DataResults
                        `$script:DashboardChart$($ChartNumber)ProgressBar.Value += 1
                        `$script:DashboardChart$($ChartNumber)ProgressBar.Update()
                    }
                    `$script:DashboardChart$($ChartNumber)OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.AddXY(`$_.DataField.$Property,`$_.UniqueCount) }
                    `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.SetRange(0, `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))
                    `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.SetRange(0, `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))
                }
                else {
                    `$script:DashboardChart$($ChartNumber)Title.ForeColor = 'Red'
                    `$script:DashboardChart$($ChartNumber)Title.Text = "$SeriesName`n
[ No Data Available ]`n"
                }
            }
            elseif (`$PerEndpoint) {
                `$script:DashboardChart$($ChartNumber)CsvFileHosts     = (`$DashboardChartCsvData).ComputerName | Sort-Object -Unique
                `$script:DashboardChart$($ChartNumber)UniqueDataFields = (`$DashboardChartCsvData).ProcessID | Sort-Object
                
                `$script:DashboardChart$($ChartNumber)ProgressBar.ForeColor = '$ChartColor'
                `$script:DashboardChart$($ChartNumber)ProgressBar.Minimum = 0
                `$script:DashboardChart$($ChartNumber)ProgressBar.Maximum = `$script:DashboardChart$($ChartNumber)UniqueDataFields.count
                `$script:DashboardChart$($ChartNumber)ProgressBar.Value   = 0
                `$script:DashboardChart$($ChartNumber)ProgressBar.Update()

                if (`$script:DashboardChart$($ChartNumber)UniqueDataFields.count -gt 0){
                    `$script:DashboardChart$($ChartNumber)Title.ForeColor = 'Black'
                    `$script:DashboardChart$($ChartNumber)Title.Text = '$SeriesName'
                
                    `$DashboardChartCurrentComputer  = ''
                    `$DashboardChartCheckIfFirstLine = `$false
                    `$DashboardChartResultsCount     = 0
                    `$DashboardChartComputer         = @()
                    `$DashboardChartYResults         = @()
                    `$script:DashboardChart$($ChartNumber)OverallDataResults = @()
                
                    foreach ( `$Line in `$(`$DashboardChartCsvData | Sort-Object ComputerName) ) {
                        if ( `$DashboardChartCheckIfFirstLine -eq `$false ) { 
                            `$DashboardChartCurrentComputer  = `$Line.ComputerName
                            `$DashboardChartCheckIfFirstLine = `$true 
                        }
                        if ( `$DashboardChartCheckIfFirstLine -eq `$true ) {
                            if ( `$Line.ComputerName -eq `$DashboardChartCurrentComputer ) {
                                if ( `$DashboardChartYResults -notcontains `$Line.ProcessID ) {
                                    if ( `$Line.ProcessID -ne "" ) { 
                                        `$DashboardChartYResults += `$Line.ProcessID
                                        `$DashboardChartResultsCount += 1 
                                    }
                                    if ( `$DashboardChartComputer -notcontains `$Line.ComputerName ) { 
                                        `$DashboardChartComputer = `$Line.ComputerName 
                                    }
                                }
                            }
                            elseif ( `$Line.ComputerName -ne `$DashboardChartCurrentComputer ) {
                                `$DashboardChartCurrentComputer = `$Line.ComputerName
                                `$DashboardChartYDataResults    = New-Object PSObject -Property @{
                                    ResultsCount = `$DashboardChartResultsCount
                                    Computer     = `$DashboardChartComputer
                                }
                                `$script:DashboardChart$($ChartNumber)OverallDataResults += `$DashboardChartYDataResults
                                `$DashboardChartYResults     = @()
                                `$DashboardChartResultsCount = 0
                                `$DashboardChartComputer     = @()
                                if ( `$DashboardChartYResults -notcontains `$Line.ProcessID ) {
                                    if ( `$Line.ProcessID -ne "" ) { 
                                        `$DashboardChartYResults += `$Line.ProcessID
                                        `$DashboardChartResultsCount += 1 
                                    }
                                    if ( `$DashboardChartComputer -notcontains `$Line.ComputerName ) { 
                                        `$DashboardChartComputer = `$Line.ComputerName 
                                    }
                                }
                            }
                        }
                        `$script:DashboardChart$($ChartNumber)ProgressBar.Value += 1
                        `$script:DashboardChart$($ChartNumber)ProgressBar.Update()
                    }
                    `$DashboardChartYDataResults = New-Object PSObject -Property @{ 
                        ResultsCount = `$DashboardChartResultsCount
                        Computer = `$DashboardChartComputer 
                    }

                    `$script:DashboardChart$($ChartNumber)OverallDataResults | Sort-Object -Property ResultsCount | ForEach-Object { `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.AddXY(`$_.Computer,`$_.ResultsCount) }
                    `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.SetRange(0,`$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))
                    `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.SetRange(0,`$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))

                }
                else {
                    `$script:DashboardChart$($ChartNumber)Title.ForeColor = 'Red'
                    `$script:DashboardChart$($ChartNumber)Title.Text = '$SeriesName`n
[ No Unique Data Available ]'
                }
            }

            
    ### Auto Chart Panel that contains all the options to manage open/close feature
    `$script:DashboardChart$($ChartNumber)OptionsButton = New-Object Windows.Forms.Button -Property @{
        Text   = "Options v"
        Left   = `$script:DashboardChart$($ChartNumber).Left + `$(`$FormScale * 5)
        Top    = `$script:DashboardChart$($ChartNumber).Top + `$(`$FormScale * 350)
        Width  = `$FormScale * 75
        Height = `$FormScale * 20 
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)OptionsButton

    `$script:DashboardChart$($ChartNumber)OptionsButton.Add_Click({
        if (`$script:DashboardChart$($ChartNumber)OptionsButton.Text -eq 'Options v') {
            `$script:DashboardChart$($ChartNumber)OptionsButton.Text = 'Options ^'
            `$script:DashboardChart$($ChartNumber).Controls.Add(`$script:DashboardChart$($ChartNumber)ManipulationPanel)
        }
        elseif (`$script:DashboardChart$($ChartNumber)OptionsButton.Text -eq 'Options ^') {
            `$script:DashboardChart$($ChartNumber)OptionsButton.Text = 'Options v'
            `$script:DashboardChart$($ChartNumber).Controls.Remove(`$script:DashboardChart$($ChartNumber)ManipulationPanel)
        }
    })
    `$script:DashboardChartTab.Controls.Add(`$script:DashboardChart$($ChartNumber)OptionsButton)
    `$script:DashboardChartTab.Controls.Add(`$script:DashboardChart$($ChartNumber))

    `$script:DashboardChart$($ChartNumber)ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
        Left     = 0
        Top      = `$script:DashboardChart$($ChartNumber).Height - `$(`$FormScale * 121)
        Width    = `$script:DashboardChart$($ChartNumber).Width
        Height   = `$FormScale * 121
        Font        = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        ForeColor   = 'Black'
        BackColor   = 'White'
        BorderStyle = 'FixedSingle'
    }

    ### AutoCharts - Trim Off First GroupBox
    `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text   = "Trim Off First: 0"
        Left   = `$FormScale * 5
        Top    = `$FormScale * 5
        Width  = `$FormScale * 165
        Height = `$FormScale * 85
        Font        = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        ### AutoCharts - Trim Off First TrackBar
        `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Left   = `$FormScale * 1
            Top    = `$FormScale * 30
            Width  = `$FormScale * 160
            Height = `$FormScale * 25
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
            Value         = 0
        }
        `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.SetRange(0, `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))
        `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBarValue   = 0
        `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.add_ValueChanged({
            `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBarValue = `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.Value
            `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Text = "Trim Off First: `$(`$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar.Value)"
            `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.Clear()
            `$script:DashboardChart$($ChartNumber)OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBarValue | Select-Object -SkipLast `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBarValue | ForEach-Object {`$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.AddXY(`$_.DataField.$Property,`$_.UniqueCount)}
        })
        `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Controls.Add(`$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBar)
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox)

    ### Auto Charts - Trim Off Last GroupBox
    `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text   = "Trim Off Last: 0"
        Left   = `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Left + `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Width + `$(`$FormScale * 8)
        Top    = `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Top 
        Width  = `$FormScale * 165
        Height = `$FormScale * 85
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        ForeColor   = 'Black'
    }
        ### AutoCharts - Trim Off Last TrackBar
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
            Left   = `$FormScale * 1
            Top    = `$FormScale * 30
            Width  = `$FormScale * 160
            Height = `$FormScale * 25
            Orientation   = "Horizontal"
            TickFrequency = 1
            TickStyle     = "TopLeft"
            Minimum       = 0
        }
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.RightToLeft   = `$true
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.SetRange(0, `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count))
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.Value         = `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count)
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBarValue   = 0
        `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.add_ValueChanged({
            `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBarValue = `$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count) - `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.Value
            `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox.Text = "Trim Off Last: `$(`$(`$script:DashboardChart$($ChartNumber)OverallDataResults.count) - `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar.Value)"
            `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.Clear()
            `$script:DashboardChart$($ChartNumber)OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBarValue | Select-Object -SkipLast `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBarValue | ForEach-Object {`$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.AddXY(`$_.DataField.$Property,`$_.UniqueCount)}
        })
    `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox.Controls.Add(`$script:DashboardChart$($ChartNumber)TrimOffLastTrackBar)
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox)


    `$script:DashboardChart$($ChartNumber)ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text   = 'Column'
        Left   = `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Left + `$(`$FormScale * 80)
        Top    = `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Top + `$script:DashboardChart$($ChartNumber)TrimOffFirstGroupBox.Height + `$(`$FormScale * 5)
        Width  = `$FormScale * 85
        Height = `$FormScale * 20
        Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.add_SelectedIndexChanged({
        `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].ChartType = `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.SelectedItem
    })
    `$script:DashboardChart$($ChartNumber)ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
    ForEach (`$Item in `$script:DashboardChart$($ChartNumber)ChartTypesAvailable) { `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.Items.Add(`$Item) }
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)ChartTypeComboBox)


    ### Auto Charts Toggle 3D on/off and inclination angle
    `$script:DashboardChart$($ChartNumber)3DToggleButton = New-Object Windows.Forms.Button -Property @{
        Text   = "3D Off"
        Left   = `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.Left + `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.Width + `$(`$FormScale * 8)
        Top    = `$script:DashboardChart$($ChartNumber)ChartTypeComboBox.Top
        Width  = `$FormScale * 65
        Height = `$FormScale * 20
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)3DToggleButton
    `$script:DashboardChart$($ChartNumber)3DInclination = 0
    `$script:DashboardChart$($ChartNumber)3DToggleButton.Add_Click({

        `$script:DashboardChart$($ChartNumber)3DInclination += 10
        if ( `$script:DashboardChart$($ChartNumber)3DToggleButton.Text -eq "3D Off" ) {
            `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Enable3D    = `$true
            `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Inclination = `$script:DashboardChart$($ChartNumber)3DInclination
            `$script:DashboardChart$($ChartNumber)3DToggleButton.Text  = "3D On (`$script:DashboardChart$($ChartNumber)3DInclination)"
        }
        elseif ( `$script:DashboardChart$($ChartNumber)3DInclination -le 90 ) {
            `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Inclination = `$script:DashboardChart$($ChartNumber)3DInclination
            `$script:DashboardChart$($ChartNumber)3DToggleButton.Text  = "3D On (`$script:DashboardChart$($ChartNumber)3DInclination)"
        }
        else {
            `$script:DashboardChart$($ChartNumber)3DToggleButton.Text  = "3D Off"
            `$script:DashboardChart$($ChartNumber)3DInclination = 0
            `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Inclination = `$script:DashboardChart$($ChartNumber)3DInclination
            `$script:DashboardChart$($ChartNumber)Area.Area3DStyle.Enable3D    = `$false
        }
    })
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)3DToggleButton)

    ### Change the color of the chart
    `$script:DashboardChart$($ChartNumber)ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Change Color"
        Left = `$script:DashboardChart$($ChartNumber)3DToggleButton.Left + `$script:DashboardChart$($ChartNumber)3DToggleButton.Width + `$(`$FormScale * 5)
        Top = `$script:DashboardChart$($ChartNumber)3DToggleButton.Top
        Width  = `$FormScale * 95
        Height = `$FormScale * 20
        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    `$script:DashboardChart$($ChartNumber)ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
    ForEach (`$Item in `$script:DashboardChart$($ChartNumber)ColorsAvailable) { `$script:DashboardChart$($ChartNumber)ChangeColorComboBox.Items.Add(`$Item) }
    `$script:DashboardChart$($ChartNumber)ChangeColorComboBox.add_SelectedIndexChanged({
        `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Color = `$script:DashboardChart$($ChartNumber)ChangeColorComboBox.SelectedItem
    })
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)ChangeColorComboBox)


    function script:InvestigateDifference-AutoChart01 {
        # List of Positive Endpoints that positively match
        `$script:DashboardChart$($ChartNumber)ImportCsvPosResults = `$DashboardChartCsvData | Where-Object '$Property' -eq `$(`$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
        `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsTextBox.Text = ''
        ForEach (`$Endpoint in `$script:DashboardChart$($ChartNumber)ImportCsvPosResults) { `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsTextBox.Text += "`$Endpoint`r`n" }

        # List of all endpoints within the csv file
        `$script:DashboardChart$($ChartNumber)ImportCsvAll = `$DashboardChartCsvData | Select-Object -ExpandProperty 'ComputerName' -Unique

        `$script:DashboardChart$($ChartNumber)ImportCsvNegResults = @()
        # Creates a list of Endpoints with Negative Results
        foreach (`$Endpoint in `$script:DashboardChart$($ChartNumber)ImportCsvAll) { if (`$Endpoint -notin `$script:DashboardChart$($ChartNumber)ImportCsvPosResults) { `$script:DashboardChart$($ChartNumber)ImportCsvNegResults += `$Endpoint } }

        # Populates the listbox with Negative Endpoint Results
        `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsTextBox.Text = ''
        ForEach (`$Endpoint in `$script:DashboardChart$($ChartNumber)ImportCsvNegResults) { `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsTextBox.Text += "`$Endpoint`r`n" }

        # Updates the label to include the count
        `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Text = "Positive Match (`$(`$script:DashboardChart$($ChartNumber)ImportCsvPosResults.count))"
        `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel.Text = "Negative Match (`$(`$script:DashboardChart$($ChartNumber)ImportCsvNegResults.count))"
    }


    ### Auto Create Charts Check Diff Button
    `$script:DashboardChart$($ChartNumber)CheckDiffButton = New-Object Windows.Forms.Button -Property @{
        Text      = 'Investigate'
        Left = `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox.Left + `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox.Width + `$(`$FormScale * 5)
        Top = `$script:DashboardChart$($ChartNumber)TrimOffLastGroupBox.Top + `$(`$FormScale * 5)
        Width  = `$FormScale * 100
        Height = `$FormScale * 23
        Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)CheckDiffButton
    `$script:DashboardChart$($ChartNumber)CheckDiffButton.Add_Click({
        `$script:DashboardChart$($ChartNumber)InvestDiffDropDownArray = `$DashboardChartCsvData | Select-Object -Property '$Property' -ExpandProperty '$Property' | Sort-Object -Unique

        ### Investigate Difference Compare Csv Files Form
        `$script:DashboardChart$($ChartNumber)InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
            Text   = 'Investigate Difference'
            Width  = `$FormScale * 330
            Height = `$FormScale * 360
            Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("`$Dependencies\Images\favicon.ico")
            StartPosition = "CenterScreen"
            ControlBox = `$true
            Add_Closing = { `$This.dispose() }
        }

        ### Investigate Difference Drop Down Label & ComboBox
        `$script:DashboardChart$($ChartNumber)InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Investigate the difference between computers."
            Left   = `$FormScale * 10
            Top    = `$FormScale * 10 
            Width  = `$FormScale * 290
            Height = `$FormScale * 45
            Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        }
        `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Left   = `$FormScale * 10
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffDropDownLabel.Top + `$script:DashboardChart$($ChartNumber)InvestDiffDropDownLabel.Height
            Width  = `$Formscale * 290
            Height = `$Formscale * 30
            Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        ForEach (`$Item in `$script:DashboardChart$($ChartNumber)InvestDiffDropDownArray) { `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Items.Add(`$Item) }
        `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Add_KeyDown({ if (`$_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
        `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

        ### Investigate Difference Execute Button
        `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Execute"
            Left   = `$FormScale * 10
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Top + `$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox.Height + `$(`$FormScale * 5)
            Width  = `$Formscale * 100
            Height = `$Formscale * 20
        }
        Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton
        `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton.Add_KeyDown({ if (`$_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
        `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

        ### Investigate Difference Positive Results Label & TextBox
        `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Positive Match (+)"
            Left   = `$FormScale * 10
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton.Top + `$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton.Height + `$(`$FormScale *  10)
            Width  = `$FormScale * 100
            Height = `$FormScale * 22
            Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        }
        `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = `$FormScale * 10
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Top + `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Height
            Width  = `$FormScale * 100
            Height = `$FormScale * 178
            Font       = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ReadOnly   = `$true
            BackColor  = 'White'
            WordWrap   = `$false
            Multiline  = `$true
            ScrollBars = "Vertical"
        }

        ### Investigate Difference Negative Results Label & TextBox
        `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Negative Match (-)"
            Left   = `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Left + `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Width + `$(`$FormScale *  10)
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel.Top
            Width  = `$FormScale * 100
            Height = `$FormScale * 22
            Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
        }
        `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel.Left
            Top    = `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel.Top + `$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel.Height
            Width  = `$FormScale * 100
            Height = `$FormScale * 178
            Font       = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ReadOnly   = `$true
            BackColor  = 'White'
            WordWrap   = `$false
            Multiline  = `$true
            ScrollBars = "Vertical"
        }
        `$script:DashboardChart$($ChartNumber)InvestDiffForm.Controls.AddRange(@(`$script:DashboardChart$($ChartNumber)InvestDiffDropDownLabel,`$script:DashboardChart$($ChartNumber)InvestDiffDropDownComboBox,`$script:DashboardChart$($ChartNumber)InvestDiffExecuteButton,`$script:DashboardChart$($ChartNumber)InvestDiffPosResultsLabel,`$script:DashboardChart$($ChartNumber)InvestDiffPosResultsTextBox,`$script:DashboardChart$($ChartNumber)InvestDiffNegResultsLabel,`$script:DashboardChart$($ChartNumber)InvestDiffNegResultsTextBox))
        `$script:DashboardChart$($ChartNumber)InvestDiffForm.add_Load(`$OnLoadForm_StateCorrection)
        `$script:DashboardChart$($ChartNumber)InvestDiffForm.ShowDialog()
    })
    `$script:DashboardChart$($ChartNumber)CheckDiffButton.Add_MouseHover({
    Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message "+  Allows you to quickly search for the differences`n`n" })
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.controls.Add(`$script:DashboardChart$($ChartNumber)CheckDiffButton)


    `$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Multi-Series'
        Left   = `$script:DashboardChart$($ChartNumber)CheckDiffButton.Left + `$script:DashboardChart$($ChartNumber)CheckDiffButton.Width + `$(`$FormScale * 5)
        Top    = `$script:DashboardChart$($ChartNumber)CheckDiffButton.Top
        Width  = `$FormScale * 100
        Height = `$FormScale * 23
        Add_Click  = { 
            Generate-AutoChartsCommand -FilePath `$DashboardChartCsvDataFileName -QueryName 'Processes' -QueryTabName '$SeriesName' -PropertyX '$Property' -PropertyY 'ComputerName'
        }
    }
    Apply-CommonButtonSettings -Button `$AutoChart01ExpandChartButton
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$AutoChart01ExpandChartButton)


    `$script:DashboardChart$($ChartNumber)OpenInShell = New-Object Windows.Forms.Button -Property @{
        Text   = "Open In Shell"
        Left   = `$script:DashboardChart$($ChartNumber)CheckDiffButton.Left
        Top    = `$script:DashboardChart$($ChartNumber)CheckDiffButton.Top + `$script:DashboardChart$($ChartNumber)CheckDiffButton.Height + `$(`$FormScale * 5)
        Width  = `$FormScale * 100
        Height = `$FormScale * 23
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)OpenInShell
    `$script:DashboardChart$($ChartNumber)OpenInShell.Add_Click({ AutoChartOpenDataInShell })
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.controls.Add(`$script:DashboardChart$($ChartNumber)OpenInShell)


    `$script:DashboardChart$($ChartNumber)ViewResults = New-Object Windows.Forms.Button -Property @{
        Text   = "View Results"
        Left   = `$script:DashboardChart$($ChartNumber)OpenInShell.Left + `$script:DashboardChart$($ChartNumber)OpenInShell.Width + `$(`$FormScale * 5)
        Top    = `$script:DashboardChart$($ChartNumber)OpenInShell.Top
        Width  = `$FormScale * 100
        Height = `$FormScale * 23
        Add_Click = {
            `$DashboardChartCsvData | Out-GridView -Title "$Title" 
        }    
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)ViewResults
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.controls.Add(`$script:DashboardChart$($ChartNumber)ViewResults)


    ### Save the chart to file
    `$script:DashboardChart$($ChartNumber)SaveButton = New-Object Windows.Forms.Button -Property @{
        Text   = "Save Chart"
        Left   = `$script:DashboardChart$($ChartNumber)OpenInShell.Left
        Top    = `$script:DashboardChart$($ChartNumber)OpenInShell.Top + `$script:DashboardChart$($ChartNumber)OpenInShell.Height + `$(`$FormScale * 5)
        Width  = `$FormScale * 205
        Height = `$FormScale * 23
    }
    Apply-CommonButtonSettings -Button `$script:DashboardChart$($ChartNumber)SaveButton
    [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    `$script:DashboardChart$($ChartNumber)SaveButton.Add_Click({
        Save-ChartImage -Chart `$script:DashboardChart$($ChartNumber) -Title `$script:DashboardChart$($ChartNumber)Title
    })
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.controls.Add(`$script:DashboardChart$($ChartNumber)SaveButton)


    `$script:DashboardChart$($ChartNumber)NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Left   = `$script:DashboardChart$($ChartNumber)SaveButton.Left
        Top    = `$script:DashboardChart$($ChartNumber)SaveButton.Top + `$script:DashboardChart$($ChartNumber)SaveButton.Height + `$(`$FormScale * 6)
        Width  = `$FormScale * 205
        Height = `$FormScale * 25
        Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        Font        = New-Object System.Drawing.Font("Courier New",`$(`$FormScale * 11),0,0,0)
        ForeColor   = 'Black'
        Text        = "Endpoints:  `$(`$script:DashboardChart$($ChartNumber)CsvFileHosts.Count)"
        Multiline   = `$false
        Enabled     = `$false
        BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
    }
    `$script:DashboardChart$($ChartNumber)ManipulationPanel.Controls.Add(`$script:DashboardChart$($ChartNumber)NoticeTextbox)

    `$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.Clear()
    `$script:DashboardChart$($ChartNumber)OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip `$script:DashboardChart$($ChartNumber)TrimOffFirstTrackBarValue | Select-Object -SkipLast `$script:DashboardChart$($ChartNumber)TrimOffLastTrackBarValue | ForEach-Object {`$script:DashboardChart$($ChartNumber).Series['$SeriesName'].Points.AddXY(`$_.DataField.$Property,`$_.UniqueCount)}
"@
}

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (5) -ChartTop (50) -ChartType 'Column' -SeriesName 'Unique Processes' -Property 'Name' -ChartColor 'Red'

Generate-Chart -PerEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (560+25) -ChartTop (50) -ChartType 'Pie' -SeriesName 'Processes Per Host' -Property 'ProcessID' -ChartColor 'Blue'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (5) -ChartTop (50+(375+20)) -ChartType 'Column' -SeriesName 'Process Company' -Property 'Company' -ChartColor 'Green'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (560+25) -ChartTop (50+(375+20)) -ChartType 'Column' -SeriesName 'Process Product' -Property 'Product' -ChartColor 'Orange'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (5) -ChartTop (50+((375+20)*2)) -ChartType 'Column' -SeriesName 'Processes with Network Activity' -Property 'NetworkConnections' -ChartColor 'DarkRed'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (560+25) -ChartTop (50+((375+20)*2)) -ChartType 'Column' -SeriesName 'Process MD5 Hash' -Property 'MD5Hash' -ChartColor 'Gray'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (5) -ChartTop (50+((375+20)*3)) -ChartType 'Column' -SeriesName 'Signer Certificate' -Property 'SignerCertificate' -ChartColor 'SlateBlue'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (560+25) -ChartTop (50+((375+20)*3)) -ChartType 'Column' -SeriesName 'Signer Company' -Property 'SignerCompany' -ChartColor 'Purple'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (5) -ChartTop (50+((375+20)*4)) -ChartType 'Column' -SeriesName 'Process Path' -Property 'Path' -ChartColor 'Yellow'

Generate-Chart -ByEndpoint -Title 'Process Data' -ChartWidth 560 -ChartHeight 375 -ChartLeft (560+25) -ChartTop (50+((375+20)*4)) -ChartType 'Column' -SeriesName 'Services Started by Processes' -Property 'ServiceInfo' -ChartColor 'Red'






# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUas7k5svZlfx82C2Ixbwec5q4
# ZEOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU66e7dFg9yWdW5YShQKzPnmyJXXMwDQYJKoZI
# hvcNAQEBBQAEggEAMDGSHCRew5Xfe2TOeQLWlvuzt02WPYWB7PEFmmGN3olv4T+M
# nWrT5Tk+rWknL8qN5tNUuQo5zUO20Zl0TWraGQ5XD+t1nCmYRhcYqTpLLcy9FjCK
# axY3LFWLqRS8YqHFI2euZbkSspWmkxVNahlbfY1TKlrOyRjRNZ/Jf9rLAQPdFWGC
# W8Jxo1vLwzmpefSLO5OJifWHbKrtzqHlmAS59t3brtYpHUD4bAhqyRUuwg7f56Ru
# bmCbKJSdQAhj7pVteCHuRfuGqey9UekT7CQ76Q4kpvQYudtvtHOPBBeuHmb8WW/a
# sZa63BkNP9CxSTqaXrdLBfwGD5JMLI3UUjdNWw==
# SIG # End signature block
