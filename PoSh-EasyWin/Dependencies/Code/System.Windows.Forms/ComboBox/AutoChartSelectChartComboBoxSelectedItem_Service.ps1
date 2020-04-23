$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:ServiceAutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Service Info'
    Size   = @{ Width  = 1700
                Height = 1050 }
    #Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
    AutoScroll    = $True
}
$AutoChartsTabControl.Controls.Add($script:ServiceAutoChartsIndividualTab01)
 
# Searches though the all Collection Data Directories to find files that match the 'Processes'
$script:ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName

$script:AutoChartsProgressBar.ForeColor = 'Black'
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = 1
$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Update()

$script:ServiceAutoChart01CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Services') { $script:ServiceAutoChart01CSVFileMatch += $CSVFile } }
} 
$script:ServiceAutoChartCSVFileMostRecentCollection = $script:ServiceAutoChart01CSVFileMatch | Select-Object -Last 1
$script:ServiceAutoChartDataSourceServices = $null
$script:ServiceAutoChartDataSourceServices = Import-Csv $script:ServiceAutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()
function Close-AllOptions {
    $script:ServiceAutoChart01OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart01.Controls.Remove($script:ServiceAutoChart01ManipulationPanel)
    $script:ServiceAutoChart02OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart02.Controls.Remove($script:ServiceAutoChart02ManipulationPanel)
    $script:ServiceAutoChart03OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart03.Controls.Remove($script:ServiceAutoChart03ManipulationPanel)
    $script:ServiceAutoChart04OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart04.Controls.Remove($script:ServiceAutoChart04ManipulationPanel)
    $script:ServiceAutoChart05OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart05.Controls.Remove($script:ServiceAutoChart05ManipulationPanel)
    $script:ServiceAutoChart06OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart06.Controls.Remove($script:ServiceAutoChart06ManipulationPanel)
<#
    $script:ServiceAutoChart07OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart07.Controls.Remove($script:ServiceAutoChart07ManipulationPanel)
    $script:ServiceAutoChart08OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart08.Controls.Remove($script:ServiceAutoChart08ManipulationPanel)
    $script:ServiceAutoChart09OptionsButton.Text = 'Options v'
    $script:ServiceAutoChart09.Controls.Remove($script:ServiceAutoChart09ManipulationPanel)
#>
}

### Main Label at the top
$script:ServiceAutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Service Info'
    Location  = @{ X = 5
                   Y = 5 }
    Size      = @{ Width  = 1150
                   Height = 25 }
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter' 
}

### Import select file to view information
$AutoChartSelectFileButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Select File To Analyze'
    Location = @{ X = 5
                  Y = 5 }
    Size     = @{ Width  = 200
                  Height = 25 }
}
CommonButtonSettings -Button $AutoChartSelectFileButton
$script:AutoChartOpenResultsOpenFileDialogfilename = $null
$AutoChartSelectFileButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $AutoChartOpenResultsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $AutoChartOpenResultsOpenFileDialog.Title            = "Open CSV Data"
    $AutoChartOpenResultsOpenFileDialog.InitialDirectory = "$(if (Test-Path $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
    $AutoChartOpenResultsOpenFileDialog.filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
    $AutoChartOpenResultsOpenFileDialog.ShowDialog() | Out-Null
    $AutoChartOpenResultsOpenFileDialog.ShowHelp = $true
    $script:AutoChartOpenResultsOpenFileDialogfilename = $AutoChartOpenResultsOpenFileDialog.filename
    $script:ServiceAutoChartDataSourceServices = Import-Csv $script:AutoChartOpenResultsOpenFileDialogfilename

    Generate-ServicesAutoChart01 -Filter 'Running'
        $script:ServiceAutoChart01FilterComboBox.SelectedIndex = 0

    Generate-ServicesAutoChart02 -Filter 'Running'
        $script:ServiceAutoChart02FilterComboBox.SelectedIndex = 0

    Generate-ServicesAutoChart03 -Filter 'Auto'
        $script:ServiceAutoChart03FilterComboBox.Text = 'Auto'

    Generate-ServicesAutoChart04 -Filter 'LocalSystem'
        $script:ServiceAutoChart04FilterComboBox.Text = 'LocalSystem'
        
    Generate-ServicesAutoChart05

    Generate-ServicesAutoChart06

<#
    Generate-ServicesAutoChart07
    Generate-ServicesAutoChart08
    Generate-ServicesAutoChart09
#>
})
$AutoChartSelectFileButton.Add_MouseHover({
    Show-ToolTip -Title "View Results" -Icon "Info" -Message @"
+  Select a file to view Service Info.
"@ })
$script:ServiceAutoChartsIndividualTab01.Controls.AddRange(@($AutoChartSelectFileButton,$script:ServiceAutoChartsMainLabel01))

function AutoChartOpenDataInShell {
    if ($script:AutoChartOpenResultsOpenFileDialogfilename) { $ViewImportResults = $script:AutoChartOpenResultsOpenFileDialogfilename -replace '.csv','.xml' }
    else { $ViewImportResults = $script:ServiceAutoChartCSVFileMostRecentCollection -replace '.csv','.xml' } 

    if (Test-Path $ViewImportResults) {
        $SavePath = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename
        $FileName = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename -Leaf
    
        Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath    
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}















##############################################################################################
# AutoChart01
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart01 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 5
                  Y = 50 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart01.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart01Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart01.Titles.Add($script:ServiceAutoChart01Title)

### Create Charts Area
$script:ServiceAutoChart01Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart01Area.Name        = 'Chart Area'
$script:ServiceAutoChart01Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart01Area.AxisX.Interval          = 1
$script:ServiceAutoChart01Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart01Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart01Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart01.ChartAreas.Add($script:ServiceAutoChart01Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart01.Series.Add("Running Services")  
$script:ServiceAutoChart01.Series["Running Services"].Enabled           = $True
$script:ServiceAutoChart01.Series["Running Services"].BorderWidth       = 1
$script:ServiceAutoChart01.Series["Running Services"].IsVisibleInLegend = $false
$script:ServiceAutoChart01.Series["Running Services"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart01.Series["Running Services"].Legend            = 'Legend'
$script:ServiceAutoChart01.Series["Running Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart01.Series["Running Services"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart01.Series["Running Services"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart01.Series["Running Services"].ChartType         = 'Column'
$script:ServiceAutoChart01.Series["Running Services"].Color             = 'Red'

        function Generate-ServicesAutoChart01 ($Filter) {
            $script:ServiceAutoChart01CsvFileHosts     = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart01UniqueDataFields = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart01UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()

            if ($script:ServiceAutoChart01UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart01Title.ForeColor = 'Black'
                $script:ServiceAutoChart01Title.Text = "$Filter Services"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart01OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart01UniqueDataFields) {
                    $Count        = 0
                    $script:ServiceAutoChart01CsvComputers = @()
                    foreach ( $Line in $($script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"}) ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:ServiceAutoChart01CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart01CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart01UniqueCount = $script:ServiceAutoChart01CsvComputers.Count
                    $script:ServiceAutoChart01DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart01UniqueCount
                        Computers   = $script:ServiceAutoChart01CsvComputers 
                    }
                    $script:ServiceAutoChart01OverallDataResults += $script:ServiceAutoChart01DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }                
                $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:ServiceAutoChart01TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart01OverallDataResults.count))
                $script:ServiceAutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart01OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart01Title.ForeColor = 'Red'
                $script:ServiceAutoChart01Title.Text = "$Filter Services`n
[ No data not available ]`n
Run a query to collect service data.`n`n"                
            }
            $script:ServiceAutoChart01FilterComboBox.SelectedIndex = 0
        }
        Generate-ServicesAutoChart01 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart01OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart01.Location.X + 5
                   Y = $script:ServiceAutoChart01.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart01OptionsButton
$script:ServiceAutoChart01OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart01OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart01OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart01.Controls.Add($script:ServiceAutoChart01ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart01OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart01OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart01.Controls.Remove($script:ServiceAutoChart01ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart01OptionsButton)

# A filter combobox to modify what is displayed
$script:ServiceAutoChart01FilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running' 
    Location  = @{ X = $script:ServiceAutoChart01OptionsButton.Location.X + 1 
                    Y = $script:ServiceAutoChart01OptionsButton.Location.Y - $script:ServiceAutoChart01OptionsButton.Size.Height - 5 }
    Size      = @{ Width  = 76
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart01FilterComboBox.add_SelectedIndexChanged({
    Generate-ServicesAutoChart01 -Filter $script:ServiceAutoChart01FilterComboBox.SelectedItem
#    $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
#    $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart01FilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:ServiceAutoChart01FilterAvailable) { $script:ServiceAutoChart01FilterComboBox.Items.Add($Item) }
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart01FilterComboBox)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart01)


$script:ServiceAutoChart01ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart01.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart01.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart01TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart01TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart01OverallDataResults.count))                
    $script:ServiceAutoChart01TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart01TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart01TrimOffFirstTrackBarValue = $script:ServiceAutoChart01TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart01TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart01TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
        $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart01TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart01TrimOffFirstTrackBar)
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart01TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart01TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart01TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart01TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart01TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }

    $script:ServiceAutoChart01TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart01TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart01OverallDataResults.count))
    $script:ServiceAutoChart01TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart01OverallDataResults.count)
    $script:ServiceAutoChart01TrimOffLastTrackBarValue          = 0
    $script:ServiceAutoChart01TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart01TrimOffLastTrackBarValue = $($script:ServiceAutoChart01OverallDataResults.count) - $script:ServiceAutoChart01TrimOffLastTrackBar.Value
        $script:ServiceAutoChart01TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart01OverallDataResults.count) - $script:ServiceAutoChart01TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
        $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:ServiceAutoChart01TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart01TrimOffLastTrackBar)
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart01ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart01TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart01TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart01TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart01ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart01.Series["Running Services"].ChartType = $script:ServiceAutoChart01ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
#    $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart01ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart01ChartTypesAvailable) { $script:ServiceAutoChart01ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart013DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart01ChartTypeComboBox.Location.X + $script:ServiceAutoChart01ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart01ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart013DToggleButton
$script:ServiceAutoChart013DInclination = 0
$script:ServiceAutoChart013DToggleButton.Add_Click({
    
    $script:ServiceAutoChart013DInclination += 10
    if ( $script:ServiceAutoChart013DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart01Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart01Area.Area3DStyle.Inclination = $script:ServiceAutoChart013DInclination
        $script:ServiceAutoChart013DToggleButton.Text  = "3D On ($script:ServiceAutoChart013DInclination)"
#        $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
#        $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart013DInclination -le 90 ) {
        $script:ServiceAutoChart01Area.Area3DStyle.Inclination = $script:ServiceAutoChart013DInclination
        $script:ServiceAutoChart013DToggleButton.Text  = "3D On ($script:ServiceAutoChart013DInclination)" 
#        $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
#        $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart013DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart013DInclination = 0
        $script:ServiceAutoChart01Area.Area3DStyle.Inclination = $script:ServiceAutoChart013DInclination
        $script:ServiceAutoChart01Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
#        $script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart013DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart01ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart013DToggleButton.Location.X + $script:ServiceAutoChart013DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart013DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart01ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart01ColorsAvailable) { $script:ServiceAutoChart01ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart01ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart01.Series["Running Services"].Color = $script:ServiceAutoChart01ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 ($Filter) {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart01ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'Name' -eq $($script:ServiceAutoChart01InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart01InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart01ImportCsvPosResults) { $script:ServiceAutoChart01InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart01ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart01ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart01ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart01ImportCsvPosResults) { $script:ServiceAutoChart01ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart01InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart01ImportCsvNegResults) { $script:ServiceAutoChart01InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart01InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart01ImportCsvPosResults.count))"
    $script:ServiceAutoChart01InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart01ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart01CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart01TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart01TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart01TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
CommonButtonSettings -Button $script:ServiceAutoChart01CheckDiffButton
$script:ServiceAutoChart01CheckDiffButton.Add_Click({
    $script:ServiceAutoChart01InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart01InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart01InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart01InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart01InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart01InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart01InvestDiffDropDownArray) { $script:ServiceAutoChart01InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart01InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01  -Filter $script:ServiceAutoChart01FilterComboBox.SelectedItem }})
    $script:ServiceAutoChart01InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 -Filter $script:ServiceAutoChart01FilterComboBox.SelectedItem })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart01InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart01InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart01InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart01InvestDiffExecuteButton
    $script:ServiceAutoChart01InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 -Filter $script:ServiceAutoChart01FilterComboBox.SelectedItem }})
    $script:ServiceAutoChart01InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 -Filter $script:ServiceAutoChart01FilterComboBox.SelectedItem })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart01InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart01InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart01InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart01InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart01InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart01InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart01InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart01InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart01InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart01InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart01InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart01InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart01InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart01InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart01InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart01InvestDiffDropDownLabel,$script:ServiceAutoChart01InvestDiffDropDownComboBox,$script:ServiceAutoChart01InvestDiffExecuteButton,$script:ServiceAutoChart01InvestDiffPosResultsLabel,$script:ServiceAutoChart01InvestDiffPosResultsTextBox,$script:ServiceAutoChart01InvestDiffNegResultsLabel,$script:ServiceAutoChart01InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart01InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart01InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart01CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart01ManipulationPanel.controls.Add($script:ServiceAutoChart01CheckDiffButton)


$script:ServiceAutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart01CheckDiffButton.Location.X + $script:ServiceAutoChart01CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart01CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart01ExpandChartButton
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01ExpandChartButton)


$script:ServiceAutoChart01OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart01CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart01CheckDiffButton.Location.Y + $script:ServiceAutoChart01CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart01OpenInShell
$script:ServiceAutoChart01OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart01ManipulationPanel.controls.Add($script:ServiceAutoChart01OpenInShell)


$script:ServiceAutoChart01Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart01OpenInShell.Location.X + $script:ServiceAutoChart01OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart01OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart01Results
$script:ServiceAutoChart01Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart01ManipulationPanel.controls.Add($script:ServiceAutoChart01Results)

### Save the chart to file
$script:ServiceAutoChart01SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart01OpenInShell.Location.X
                  Y = $script:ServiceAutoChart01OpenInShell.Location.Y + $script:ServiceAutoChart01OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart01SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart01SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01 -Title $script:AutoChart01Title
})
$script:ServiceAutoChart01ManipulationPanel.controls.Add($script:ServiceAutoChart01SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart01NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart01SaveButton.Location.X 
                        Y = $script:ServiceAutoChart01SaveButton.Location.Y + $script:ServiceAutoChart01SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart01CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart01ManipulationPanel.Controls.Add($script:ServiceAutoChart01NoticeTextbox)

$script:ServiceAutoChart01.Series["Running Services"].Points.Clear()
$script:ServiceAutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart01.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart02 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart01.Location.X + $script:ServiceAutoChart01.Size.Width + 20
                  Y = $script:ServiceAutoChart01.Location.Y }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart02.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart02Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:ServiceAutoChart02.Titles.Add($script:ServiceAutoChart02Title)

### Create Charts Area
$script:ServiceAutoChart02Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart02Area.Name        = 'Chart Area'
$script:ServiceAutoChart02Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart02Area.AxisX.Interval          = 1
$script:ServiceAutoChart02Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart02Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart02Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart02.ChartAreas.Add($script:ServiceAutoChart02Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart02.Series.Add("Running Services Per Host")  
$script:ServiceAutoChart02.Series["Running Services Per Host"].Enabled           = $True
$script:ServiceAutoChart02.Series["Running Services Per Host"].BorderWidth       = 1
$script:ServiceAutoChart02.Series["Running Services Per Host"].IsVisibleInLegend = $false
$script:ServiceAutoChart02.Series["Running Services Per Host"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart02.Series["Running Services Per Host"].Legend            = 'Legend'
$script:ServiceAutoChart02.Series["Running Services Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart02.Series["Running Services Per Host"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart02.Series["Running Services Per Host"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart02.Series["Running Services Per Host"].ChartType         = 'DoughNut'
$script:ServiceAutoChart02.Series["Running Services Per Host"].Color             = 'Blue'
        
        function Generate-ServicesAutoChart02 ($Filter) {
            $script:ServiceAutoChart02CsvFileHosts     = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'PSComputerName' -ExpandProperty 'PSComputerName' | Sort-Object -Unique
            $script:ServiceAutoChart02UniqueDataFields = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object  -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:ServiceAutoChart02UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart02Title.ForeColor = 'Black'
                $script:ServiceAutoChart02Title.Text = "$Filter Services Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:ServiceAutoChart02OverallDataResults = @()

                foreach ( $Line in $($script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.PSComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart02YResults += $Line.Name ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart02CurrentComputer ) { 
                            $AutoChart02CurrentComputer = $Line.PSComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer 
                            }
                            $script:ServiceAutoChart02OverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart02YResults += $Line.Name ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }    
                $script:ServiceAutoChart02OverallDataResults += $AutoChart02YDataResults
                $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | ForEach-Object { $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
                $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:ServiceAutoChart02TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart02OverallDataResults.count))
                $script:ServiceAutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart02OverallDataResults.count))            
            }
            else {
                $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
                $script:ServiceAutoChart02Title.ForeColor = 'Red'
                $script:ServiceAutoChart02Title.Text = "$Filter Services Per Host`n
[ No data not available ]`n
Run a query to collect service data.`n`n"                
            }
            $script:ServiceAutoChart02FilterComboBox.SelectedIndex = 0
        }
        Generate-ServicesAutoChart02 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart02OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart02.Location.X + 5
                   Y = $script:ServiceAutoChart02.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart02OptionsButton
$script:ServiceAutoChart02OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart02OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart02OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart02.Controls.Add($script:ServiceAutoChart02ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart02OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart02OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart02.Controls.Remove($script:ServiceAutoChart02ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart02OptionsButton)

# A filter combobox to modify what is displayed
$script:ServiceAutoChart02FilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running' 
    Location  = @{ X = $script:ServiceAutoChart02OptionsButton.Location.X + 1
                    Y = $script:ServiceAutoChart02OptionsButton.Location.Y - $script:ServiceAutoChart02OptionsButton.Size.Height - 5 }
    Size      = @{ Width  = 76
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart02FilterComboBox.add_SelectedIndexChanged({
    Generate-ServicesAutoChart02 -Filter $script:ServiceAutoChart02FilterComboBox.SelectedItem
#    $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
#    $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:ServiceAutoChart02FilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:ServiceAutoChart02FilterAvailable) { $script:ServiceAutoChart02FilterComboBox.Items.Add($Item) }
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart02FilterComboBox)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart02)


$script:ServiceAutoChart02ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart02.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart02.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart02TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart02TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart02OverallDataResults.count))                
    $script:ServiceAutoChart02TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart02TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart02TrimOffFirstTrackBarValue = $script:ServiceAutoChart02TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart02TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart02TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
        $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:ServiceAutoChart02TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart02TrimOffFirstTrackBar)
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart02TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart02TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart02TrimOffFirstGroupBox.Size.Width + 8
                        Y = $script:ServiceAutoChart02TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart02TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart02TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart02TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart02OverallDataResults.count))
    $script:ServiceAutoChart02TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart02OverallDataResults.count)
    $script:ServiceAutoChart02TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart02TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart02TrimOffLastTrackBarValue = $($script:ServiceAutoChart02OverallDataResults.count) - $script:ServiceAutoChart02TrimOffLastTrackBar.Value
        $script:ServiceAutoChart02TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart02OverallDataResults.count) - $script:ServiceAutoChart02TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
        $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:ServiceAutoChart02TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart02TrimOffLastTrackBar)
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart02ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart02TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart02TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart02TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart02ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart02.Series["Running Services Per Host"].ChartType = $script:ServiceAutoChart02ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
#    $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:ServiceAutoChart02ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart02ChartTypesAvailable) { $script:ServiceAutoChart02ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart023DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart02ChartTypeComboBox.Location.X + $script:ServiceAutoChart02ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart02ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart023DToggleButton
$script:ServiceAutoChart023DInclination = 0
$script:ServiceAutoChart023DToggleButton.Add_Click({
    $script:ServiceAutoChart023DInclination += 10
    if ( $script:ServiceAutoChart023DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart02Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart02Area.Area3DStyle.Inclination = $script:ServiceAutoChart023DInclination
        $script:ServiceAutoChart023DToggleButton.Text  = "3D On ($script:ServiceAutoChart023DInclination)"
#        $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
#        $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:ServiceAutoChart023DInclination -le 90 ) {
        $script:ServiceAutoChart02Area.Area3DStyle.Inclination = $script:ServiceAutoChart023DInclination
        $script:ServiceAutoChart023DToggleButton.Text  = "3D On ($script:ServiceAutoChart023DInclination)" 
#        $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
#        $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:ServiceAutoChart023DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart023DInclination = 0
        $script:ServiceAutoChart02Area.Area3DStyle.Inclination = $script:ServiceAutoChart023DInclination
        $script:ServiceAutoChart02Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
#        $script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart023DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart02ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart023DToggleButton.Location.X + $script:ServiceAutoChart023DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart023DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart02ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart02ColorsAvailable) { $script:ServiceAutoChart02ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart02ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart02.Series["Running Services Per Host"].Color = $script:ServiceAutoChart02ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart02ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'Name' -eq $($script:ServiceAutoChart02InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart02InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart02ImportCsvPosResults) { $script:ServiceAutoChart02InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart02ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart02ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart02ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart02ImportCsvPosResults) { $script:ServiceAutoChart02ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart02InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart02ImportCsvNegResults) { $script:ServiceAutoChart02InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart02InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart02ImportCsvPosResults.count))"
    $script:ServiceAutoChart02InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart02ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart02CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart02TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart02TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart02TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart02CheckDiffButton
$script:ServiceAutoChart02CheckDiffButton.Add_Click({
    $script:ServiceAutoChart02InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart02InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart02InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart02InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart02InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart02InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart02InvestDiffDropDownArray) { $script:ServiceAutoChart02InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart02InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:ServiceAutoChart02InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart02InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart02InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart02InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart02InvestDiffExecuteButton
    $script:ServiceAutoChart02InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:ServiceAutoChart02InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart02InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart02InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart02InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart02InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart02InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart02InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart02InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart02InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart02InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart02InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart02InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart02InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart02InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart02InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart02InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart02InvestDiffDropDownLabel,$script:ServiceAutoChart02InvestDiffDropDownComboBox,$script:ServiceAutoChart02InvestDiffExecuteButton,$script:ServiceAutoChart02InvestDiffPosResultsLabel,$script:ServiceAutoChart02InvestDiffPosResultsTextBox,$script:ServiceAutoChart02InvestDiffNegResultsLabel,$script:ServiceAutoChart02InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart02InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart02InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart02CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart02ManipulationPanel.controls.Add($script:ServiceAutoChart02CheckDiffButton)
    

$script:ServiceAutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart02CheckDiffButton.Location.X + $script:ServiceAutoChart02CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart02CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Services per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }
}
CommonButtonSettings -Button $script:ServiceAutoChart02ExpandChartButton
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02ExpandChartButton)


$script:ServiceAutoChart02OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart02CheckDiffButton.Location.X 
                   Y = $script:ServiceAutoChart02CheckDiffButton.Location.Y + $script:ServiceAutoChart02CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart02OpenInShell
$script:ServiceAutoChart02OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart02ManipulationPanel.controls.Add($script:ServiceAutoChart02OpenInShell)


$script:ServiceAutoChart02Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart02OpenInShell.Location.X + $script:ServiceAutoChart02OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart02OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart02Results
$script:ServiceAutoChart02Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart02ManipulationPanel.controls.Add($script:ServiceAutoChart02Results)

### Save the chart to file
$script:ServiceAutoChart02SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart02OpenInShell.Location.X
                  Y = $script:ServiceAutoChart02OpenInShell.Location.Y + $script:ServiceAutoChart02OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart02SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart02SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02 -Title $script:AutoChart02Title
})
$script:ServiceAutoChart02ManipulationPanel.controls.Add($script:ServiceAutoChart02SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart02NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart02SaveButton.Location.X 
                        Y = $script:ServiceAutoChart02SaveButton.Location.Y + $script:ServiceAutoChart02SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart02CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart02ManipulationPanel.Controls.Add($script:ServiceAutoChart02NoticeTextbox)

$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.Clear()
$script:ServiceAutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:ServiceAutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart02.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart03 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart01.Location.X
                  Y = $script:ServiceAutoChart01.Location.Y + $script:ServiceAutoChart01.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart03.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart03Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart03.Titles.Add($script:ServiceAutoChart03Title)

### Create Charts Area
$script:ServiceAutoChart03Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart03Area.Name        = 'Chart Area'
$script:ServiceAutoChart03Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart03Area.AxisX.Interval          = 1
$script:ServiceAutoChart03Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart03Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart03Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart03.ChartAreas.Add($script:ServiceAutoChart03Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart03.Series.Add("Automatic Startup Services")  
$script:ServiceAutoChart03.Series["Automatic Startup Services"].Enabled           = $True
$script:ServiceAutoChart03.Series["Automatic Startup Services"].BorderWidth       = 1
$script:ServiceAutoChart03.Series["Automatic Startup Services"].IsVisibleInLegend = $false
$script:ServiceAutoChart03.Series["Automatic Startup Services"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart03.Series["Automatic Startup Services"].Legend            = 'Legend'
$script:ServiceAutoChart03.Series["Automatic Startup Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart03.Series["Automatic Startup Services"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart03.Series["Automatic Startup Services"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart03.Series["Automatic Startup Services"].ChartType         = 'Column'
$script:ServiceAutoChart03.Series["Automatic Startup Services"].Color             = 'Green'

        function Generate-ServicesAutoChart03 ($Filter) { 
            $script:ServiceAutoChart03CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart03UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.StartType -match $Filter -or $_.StartMode -match $Filter} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()

            if ($script:ServiceAutoChart03UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart03Title.ForeColor = 'Black'
                $script:ServiceAutoChart03Title.Text = "$Filter Startup Services"
                
                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart03OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart03UniqueDataFields) {
                    $Count        = 0
                    $script:ServiceAutoChart03CsvComputers = @()
                    foreach ( $Line in $($script:ServiceAutoChartDataSourceServices | Where-Object {$_.StartType -match $Filter -or $_.StartMode -match $Filter}) ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:ServiceAutoChart03CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart03CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart03UniqueCount = $script:ServiceAutoChart03CsvComputers.Count
                    $script:ServiceAutoChart03DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart03UniqueCount
                        Computers   = $script:ServiceAutoChart03CsvComputers 
                    }
                    $script:ServiceAutoChart03OverallDataResults += $script:ServiceAutoChart03DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:ServiceAutoChart03TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart03OverallDataResults.count))
                $script:ServiceAutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart03OverallDataResults.count))            
            }
            else {
                $script:ServiceAutoChart03Title.ForeColor = 'Red'
                $script:ServiceAutoChart03Title.Text = "$Filter Startup Services`n
[ No data not available ]`n
Run a query to collect service info`n`n"
            }
        }
        Generate-ServicesAutoChart03 -Filter 'Auto'

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart03OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart03.Location.X + 5
                   Y = $script:ServiceAutoChart03.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart03OptionsButton
$script:ServiceAutoChart03OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart03OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart03OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart03.Controls.Add($script:ServiceAutoChart03ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart03OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart03OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart03.Controls.Remove($script:ServiceAutoChart03ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart03OptionsButton)


# A filter combobox to modify what is displayed
$script:ServiceAutoChart03FilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Auto' 
    Location  = @{ X = $script:ServiceAutoChart03OptionsButton.Location.X + 1 
                    Y = $script:ServiceAutoChart03OptionsButton.Location.Y - $script:ServiceAutoChart03OptionsButton.Size.Height - 5 }
    Size      = @{ Width  = 76
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart03FilterComboBox.add_SelectedIndexChanged({
    Generate-ServicesAutoChart03 -Filter $script:ServiceAutoChart03FilterComboBox.SelectedItem
#    $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
#    $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart03FilterAvailable = @()
$script:ServiceAutoChartDataSourceServices | Select-Object StartMode -Unique | ForEach-Object { if ($script:ServiceAutoChart03FilterAvailable -inotcontains $_.StartMode) {$script:ServiceAutoChart03FilterAvailable += $_.StartMode}}
if ($script:ServiceAutoChart03FilterAvailable.Count -eq 0){ $script:ServiceAutoChartDataSourceServices | Select-Object StartType -Unique | ForEach-Object { if ($script:ServiceAutoChart03FilterAvailable -inotcontains $_.StartType) {$script:ServiceAutoChart03FilterAvailable += $_.StartType}} }

ForEach ($Item in $script:ServiceAutoChart03FilterAvailable) { $script:ServiceAutoChart03FilterComboBox.Items.Add($Item) }
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart03FilterComboBox)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart03)


$script:ServiceAutoChart03ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart03.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart03.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart03TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart03TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart03OverallDataResults.count))
    $script:ServiceAutoChart03TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart03TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart03TrimOffFirstTrackBarValue = $script:ServiceAutoChart03TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart03TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart03TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
        $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart03TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart03TrimOffFirstTrackBar)
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart03TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart03TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart03TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart03TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart03TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart03TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart03TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart03OverallDataResults.count))
    $script:ServiceAutoChart03TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart03OverallDataResults.count)
    $script:ServiceAutoChart03TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart03TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart03TrimOffLastTrackBarValue = $($script:ServiceAutoChart03OverallDataResults.count) - $script:ServiceAutoChart03TrimOffLastTrackBar.Value
        $script:ServiceAutoChart03TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart03OverallDataResults.count) - $script:ServiceAutoChart03TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
        $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:ServiceAutoChart03TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart03TrimOffLastTrackBar)
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart03ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart03TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart03TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart03TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart03ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart03.Series["Automatic Startup Services"].ChartType = $script:ServiceAutoChart03ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
#    $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart03ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart03ChartTypesAvailable) { $script:ServiceAutoChart03ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart033DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart03ChartTypeComboBox.Location.X + $script:ServiceAutoChart03ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart03ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart033DToggleButton
$script:ServiceAutoChart033DInclination = 0
$script:ServiceAutoChart033DToggleButton.Add_Click({
    $script:ServiceAutoChart033DInclination += 10
    if ( $script:ServiceAutoChart033DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart03Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart03Area.Area3DStyle.Inclination = $script:ServiceAutoChart033DInclination
        $script:ServiceAutoChart033DToggleButton.Text  = "3D On ($script:ServiceAutoChart033DInclination)"
#        $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
#        $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart033DInclination -le 90 ) {
        $script:ServiceAutoChart03Area.Area3DStyle.Inclination = $script:ServiceAutoChart033DInclination
        $script:ServiceAutoChart033DToggleButton.Text  = "3D On ($script:ServiceAutoChart033DInclination)" 
#        $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
#        $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart033DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart033DInclination = 0
        $script:ServiceAutoChart03Area.Area3DStyle.Inclination = $script:ServiceAutoChart033DInclination
        $script:ServiceAutoChart03Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
#        $script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart033DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart03ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart033DToggleButton.Location.X + $script:ServiceAutoChart033DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart033DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart03ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart03ColorsAvailable) { $script:ServiceAutoChart03ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart03ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart03.Series["Automatic Startup Services"].Color = $script:ServiceAutoChart03ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart03ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'Name' -eq $($script:ServiceAutoChart03InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart03InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart03ImportCsvPosResults) { $script:ServiceAutoChart03InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart03ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart03ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart03ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart03ImportCsvPosResults) { $script:ServiceAutoChart03ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart03InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart03ImportCsvNegResults) { $script:ServiceAutoChart03InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart03InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart03ImportCsvPosResults.count))"
    $script:ServiceAutoChart03InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart03ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart03CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart03TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart03TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart03TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart03CheckDiffButton
$script:ServiceAutoChart03CheckDiffButton.Add_Click({
    $script:ServiceAutoChart03InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart03InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart03InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart03InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart03InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart03InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart03InvestDiffDropDownArray) { $script:ServiceAutoChart03InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart03InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:ServiceAutoChart03InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart03InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart03InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart03InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart03InvestDiffExecuteButton
    $script:ServiceAutoChart03InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:ServiceAutoChart03InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart03InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart03InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart03InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart03InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart03InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart03InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart03InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart03InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart03InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart03InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart03InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart03InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart03InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart03InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart03InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart03InvestDiffDropDownLabel,$script:ServiceAutoChart03InvestDiffDropDownComboBox,$script:ServiceAutoChart03InvestDiffExecuteButton,$script:ServiceAutoChart03InvestDiffPosResultsLabel,$script:ServiceAutoChart03InvestDiffPosResultsTextBox,$script:ServiceAutoChart03InvestDiffNegResultsLabel,$script:ServiceAutoChart03InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart03InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart03InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart03CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart03ManipulationPanel.controls.Add($script:ServiceAutoChart03CheckDiffButton)
    

$script:ServiceAutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart03CheckDiffButton.Location.X + $script:ServiceAutoChart03CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart03CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart03ExpandChartButton
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03ExpandChartButton)


$script:ServiceAutoChart03OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart03CheckDiffButton.Location.X 
                   Y = $script:ServiceAutoChart03CheckDiffButton.Location.Y + $script:ServiceAutoChart03CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart03OpenInShell
$script:ServiceAutoChart03OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart03ManipulationPanel.controls.Add($script:ServiceAutoChart03OpenInShell)


$script:ServiceAutoChart03Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart03OpenInShell.Location.X + $script:ServiceAutoChart03OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart03OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart03Results
$script:ServiceAutoChart03Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart03ManipulationPanel.controls.Add($script:ServiceAutoChart03Results)

### Save the chart to file
$script:ServiceAutoChart03SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart03OpenInShell.Location.X
                  Y = $script:ServiceAutoChart03OpenInShell.Location.Y + $script:ServiceAutoChart03OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart03SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart03SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03 -Title $script:AutoChart03Title
})
$script:ServiceAutoChart03ManipulationPanel.controls.Add($script:ServiceAutoChart03SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart03NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart03SaveButton.Location.X 
                        Y = $script:ServiceAutoChart03SaveButton.Location.Y + $script:ServiceAutoChart03SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart03CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart03ManipulationPanel.Controls.Add($script:ServiceAutoChart03NoticeTextbox)

$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.Clear()
$script:ServiceAutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart03.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart04 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart02.Location.X
                  Y = $script:ServiceAutoChart02.Location.Y + $script:ServiceAutoChart02.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart04.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart04Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart04.Titles.Add($script:ServiceAutoChart04Title)

### Create Charts Area
$script:ServiceAutoChart04Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart04Area.Name        = 'Chart Area'
$script:ServiceAutoChart04Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart04Area.AxisX.Interval          = 1
$script:ServiceAutoChart04Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart04Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart04Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart04.ChartAreas.Add($script:ServiceAutoChart04Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart04.Series.Add("Services Started By LocalSystem")  
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Enabled           = $True
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].BorderWidth       = 1
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].IsVisibleInLegend = $false
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Legend            = 'Legend'
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].ChartType         = 'Column'
$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Color             = 'Orange'

        function Generate-ServicesAutoChart04 ($Filter) {
            $script:ServiceAutoChart04CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart04UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.StartName -eq "$Filter"} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart04UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()

            if ($script:ServiceAutoChart04UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart04Title.ForeColor = 'Black'
                $script:ServiceAutoChart04Title.Text = "Services Started By $Filter"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart04OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart04UniqueDataFields) {
                    $Count        = 0
                    $script:ServiceAutoChart04CsvComputers = @()
                    foreach ( $Line in $($script:ServiceAutoChartDataSourceServices | Where-Object {$_.StartName -eq "$Filter"}) ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:ServiceAutoChart04CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart04CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart04UniqueCount = $script:ServiceAutoChart04CsvComputers.Count
                    $script:ServiceAutoChart04DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart04UniqueCount
                        Computers   = $script:ServiceAutoChart04CsvComputers 
                    }
                    $script:ServiceAutoChart04OverallDataResults += $script:ServiceAutoChart04DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:ServiceAutoChart04TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart04OverallDataResults.count))
                $script:ServiceAutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart04OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart04Title.ForeColor = 'Red'
                $script:ServiceAutoChart04Title.Text = "Services Started By $Filter`n
[ No data not available ]`n
Run Get-WmiObject Win32_Service to view which accounts started services`n`n"
            }

        }
        Generate-ServicesAutoChart04 -Filter 'LocalSystem'

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart04OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart04.Location.X + 5
                   Y = $script:ServiceAutoChart04.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart04OptionsButton
$script:ServiceAutoChart04OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart04OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart04OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart04.Controls.Add($script:ServiceAutoChart04ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart04OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart04OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart04.Controls.Remove($script:ServiceAutoChart04ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart04OptionsButton)


# A filter combobox to modify what is displayed
$script:ServiceAutoChart04FilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text = 'LocalSystem'
    Location  = @{ X = $script:ServiceAutoChart04OptionsButton.Location.X + 1 
                    Y = $script:ServiceAutoChart04OptionsButton.Location.Y - $script:ServiceAutoChart04OptionsButton.Size.Height - 5 }
    Size      = @{ Width  = 76
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart04FilterComboBox.add_SelectedIndexChanged({
    Generate-ServicesAutoChart04 -Filter "$($script:ServiceAutoChart04FilterComboBox.SelectedItem)"
#    $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
#    $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart04FilterAvailable = @()
$script:ServiceAutoChartDataSourceServices | Select-Object StartName -Unique | ForEach-Object { if ($script:ServiceAutoChart04FilterAvailable -inotcontains $_.StartName) {$script:ServiceAutoChart04FilterAvailable += $_.StartName}}
ForEach ($Item in $script:ServiceAutoChart04FilterAvailable) { $script:ServiceAutoChart04FilterComboBox.Items.Add($Item) }
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart04FilterComboBox)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart04)


$script:ServiceAutoChart04ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart04.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart04.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart04TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart04TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart04OverallDataResults.count))                
    $script:ServiceAutoChart04TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart04TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart04TrimOffFirstTrackBarValue = $script:ServiceAutoChart04TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart04TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart04TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
        $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart04TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart04TrimOffFirstTrackBar)
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart04TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart04TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart04TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart04TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart04TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart04TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart04TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart04OverallDataResults.count))
    $script:ServiceAutoChart04TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart04OverallDataResults.count)
    $script:ServiceAutoChart04TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart04TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart04TrimOffLastTrackBarValue = $($script:ServiceAutoChart04OverallDataResults.count) - $script:ServiceAutoChart04TrimOffLastTrackBar.Value
        $script:ServiceAutoChart04TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart04OverallDataResults.count) - $script:ServiceAutoChart04TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
        $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:ServiceAutoChart04TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart04TrimOffLastTrackBar)
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart04ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart04TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart04TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart04TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart04ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].ChartType = $script:ServiceAutoChart04ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
#    $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:ServiceAutoChart04ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart04ChartTypesAvailable) { $script:ServiceAutoChart04ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart043DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart04ChartTypeComboBox.Location.X + $script:ServiceAutoChart04ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart04ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart043DToggleButton
$script:ServiceAutoChart043DInclination = 0
$script:ServiceAutoChart043DToggleButton.Add_Click({
    $script:ServiceAutoChart043DInclination += 10
    if ( $script:ServiceAutoChart043DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart04Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart04Area.Area3DStyle.Inclination = $script:ServiceAutoChart043DInclination
        $script:ServiceAutoChart043DToggleButton.Text  = "3D On ($script:ServiceAutoChart043DInclination)"
#        $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart043DInclination -le 90 ) {
        $script:ServiceAutoChart04Area.Area3DStyle.Inclination = $script:ServiceAutoChart043DInclination
        $script:ServiceAutoChart043DToggleButton.Text  = "3D On ($script:ServiceAutoChart043DInclination)" 
#        $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart043DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart043DInclination = 0
        $script:ServiceAutoChart04Area.Area3DStyle.Inclination = $script:ServiceAutoChart043DInclination
        $script:ServiceAutoChart04Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart043DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart04ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart043DToggleButton.Location.X + $script:ServiceAutoChart043DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart043DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart04ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart04ColorsAvailable) { $script:ServiceAutoChart04ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart04ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Color = $script:ServiceAutoChart04ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart04ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'Name' -eq $($script:ServiceAutoChart04InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart04InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart04ImportCsvPosResults) { $script:ServiceAutoChart04InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart04ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart04ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart04ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart04ImportCsvPosResults) { $script:ServiceAutoChart04ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart04InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart04ImportCsvNegResults) { $script:ServiceAutoChart04InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart04InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart04ImportCsvPosResults.count))"
    $script:ServiceAutoChart04InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart04ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart04CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart04TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart04TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart04TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart04CheckDiffButton
$script:ServiceAutoChart04CheckDiffButton.Add_Click({
    $script:ServiceAutoChart04InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart04InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart04InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart04InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart04InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart04InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart04InvestDiffDropDownArray) { $script:ServiceAutoChart04InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart04InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:ServiceAutoChart04InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart04InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart04InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart04InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart04InvestDiffExecuteButton
    $script:ServiceAutoChart04InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:ServiceAutoChart04InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart04InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart04InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart04InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart04InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart04InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart04InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart04InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart04InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart04InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart04InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart04InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart04InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart04InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart04InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart04InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart04InvestDiffDropDownLabel,$script:ServiceAutoChart04InvestDiffDropDownComboBox,$script:ServiceAutoChart04InvestDiffExecuteButton,$script:ServiceAutoChart04InvestDiffPosResultsLabel,$script:ServiceAutoChart04InvestDiffPosResultsTextBox,$script:ServiceAutoChart04InvestDiffNegResultsLabel,$script:ServiceAutoChart04InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart04InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart04InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart04CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart04ManipulationPanel.controls.Add($script:ServiceAutoChart04CheckDiffButton)
    

$script:ServiceAutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart04CheckDiffButton.Location.X + $script:ServiceAutoChart04CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart04CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart04ExpandChartButton
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04ExpandChartButton)


$script:ServiceAutoChart04OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart04CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart04CheckDiffButton.Location.Y + $script:ServiceAutoChart04CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart04OpenInShell
$script:ServiceAutoChart04OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart04ManipulationPanel.controls.Add($script:ServiceAutoChart04OpenInShell)


$script:ServiceAutoChart04Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart04OpenInShell.Location.X + $script:ServiceAutoChart04OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart04OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart04Results
$script:ServiceAutoChart04Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart04ManipulationPanel.controls.Add($script:ServiceAutoChart04Results)

### Save the chart to file
$script:ServiceAutoChart04SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart04OpenInShell.Location.X
                  Y = $script:ServiceAutoChart04OpenInShell.Location.Y + $script:ServiceAutoChart04OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart04SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart04SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04 -Title $script:AutoChart04Title
})
$script:ServiceAutoChart04ManipulationPanel.controls.Add($script:ServiceAutoChart04SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart04NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart04SaveButton.Location.X 
                        Y = $script:ServiceAutoChart04SaveButton.Location.Y + $script:ServiceAutoChart04SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart04CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart04ManipulationPanel.Controls.Add($script:ServiceAutoChart04NoticeTextbox)

$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.Clear()
$script:ServiceAutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart04.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    






















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart05 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart03.Location.X
                  Y = $script:ServiceAutoChart03.Location.Y + $script:ServiceAutoChart03.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart05.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart05Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart05.Titles.Add($script:ServiceAutoChart05Title)

### Create Charts Area
$script:ServiceAutoChart05Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart05Area.Name        = 'Chart Area'
$script:ServiceAutoChart05Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart05Area.AxisX.Interval          = 1
$script:ServiceAutoChart05Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart05Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart05Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart05.ChartAreas.Add($script:ServiceAutoChart05Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart05.Series.Add("Processes That Started Services ")  
$script:ServiceAutoChart05.Series["Processes That Started Services "].Enabled           = $True
$script:ServiceAutoChart05.Series["Processes That Started Services "].BorderWidth       = 1
$script:ServiceAutoChart05.Series["Processes That Started Services "].IsVisibleInLegend = $false
$script:ServiceAutoChart05.Series["Processes That Started Services "].Chartarea         = 'Chart Area'
$script:ServiceAutoChart05.Series["Processes That Started Services "].Legend            = 'Legend'
$script:ServiceAutoChart05.Series["Processes That Started Services "].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart05.Series["Processes That Started Services "]['PieLineColor']   = 'Black'
$script:ServiceAutoChart05.Series["Processes That Started Services "]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart05.Series["Processes That Started Services "].ChartType         = 'Column'
$script:ServiceAutoChart05.Series["Processes That Started Services "].Color             = 'Brown'

        function Generate-ServicesAutoChart05 {
            $script:ServiceAutoChart05CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart05UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'} | Select-Object -Property 'ProcessName' | Sort-Object -Property 'ProcessName' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart05UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()

            if ($script:ServiceAutoChart05UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart05Title.ForeColor = 'Black'
                $script:ServiceAutoChart05Title.Text = "Processes That Started Services "

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart05OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart05UniqueDataFields) {
                    $Count = 0
                    $script:ServiceAutoChart05CsvComputers = @()
                    foreach ( $Line in $($script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'}) ) {
                        if ($Line.ProcessName -eq $DataField.ProcessName) {
                            $Count += 1
                            if ( $script:ServiceAutoChart05CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart05CsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    if ($Count -gt 0) {
                        $script:ServiceAutoChart05UniqueCount = $script:ServiceAutoChart05CsvComputers.Count
                        $script:ServiceAutoChart05DataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:ServiceAutoChart05UniqueCount
                            Computers   = $script:ServiceAutoChart05CsvComputers 
                        }
                        $script:ServiceAutoChart05OverallDataResults += $script:ServiceAutoChart05DataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()
                    }
                }
                $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
                $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}    

                $script:ServiceAutoChart05TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart05OverallDataResults.count))
                $script:ServiceAutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart05OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart05Title.ForeColor = 'Red'
                $script:ServiceAutoChart05Title.Text = "Processes That Started Services `n
[ No data not available ]`n
Run 'Get-EnrichedServices' to obtain Processes`n
that Started Services.`n`n"
            }
        }
        Generate-ServicesAutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart05OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart05.Location.X + 5
                   Y = $script:ServiceAutoChart05.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart05OptionsButton
$script:ServiceAutoChart05OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart05OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart05OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart05.Controls.Add($script:ServiceAutoChart05ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart05OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart05OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart05.Controls.Remove($script:ServiceAutoChart05ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart05OptionsButton)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart05)

$script:ServiceAutoChart05ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart05.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart05.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart05TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart05TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart05OverallDataResults.count))                
    $script:ServiceAutoChart05TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart05TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart05TrimOffFirstTrackBarValue = $script:ServiceAutoChart05TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart05TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart05TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
        $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart05TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart05TrimOffFirstTrackBar)
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart05TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart05TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart05TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart05TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart05TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart05TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart05TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart05OverallDataResults.count))
    $script:ServiceAutoChart05TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart05OverallDataResults.count)
    $script:ServiceAutoChart05TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart05TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart05TrimOffLastTrackBarValue = $($script:ServiceAutoChart05OverallDataResults.count) - $script:ServiceAutoChart05TrimOffLastTrackBar.Value
        $script:ServiceAutoChart05TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart05OverallDataResults.count) - $script:ServiceAutoChart05TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
        $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    })
$script:ServiceAutoChart05TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart05TrimOffLastTrackBar)
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart05ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart05TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart05TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart05TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart05ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart05.Series["Processes That Started Services "].ChartType = $script:ServiceAutoChart05ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
#    $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
})
$script:ServiceAutoChart05ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart05ChartTypesAvailable) { $script:ServiceAutoChart05ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart053DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart05ChartTypeComboBox.Location.X + $script:ServiceAutoChart05ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart05ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart053DToggleButton
$script:ServiceAutoChart053DInclination = 0
$script:ServiceAutoChart053DToggleButton.Add_Click({
    $script:ServiceAutoChart053DInclination += 10
    if ( $script:ServiceAutoChart053DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart05Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart05Area.Area3DStyle.Inclination = $script:ServiceAutoChart053DInclination
        $script:ServiceAutoChart053DToggleButton.Text  = "3D On ($script:ServiceAutoChart053DInclination)"
#        $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
#        $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart053DInclination -le 90 ) {
        $script:ServiceAutoChart05Area.Area3DStyle.Inclination = $script:ServiceAutoChart053DInclination
        $script:ServiceAutoChart053DToggleButton.Text  = "3D On ($script:ServiceAutoChart053DInclination)" 
#        $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
#        $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart053DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart053DInclination = 0
        $script:ServiceAutoChart05Area.Area3DStyle.Inclination = $script:ServiceAutoChart053DInclination
        $script:ServiceAutoChart05Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
#        $script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart053DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart05ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart053DToggleButton.Location.X + $script:ServiceAutoChart053DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart053DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart05ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart05ColorsAvailable) { $script:ServiceAutoChart05ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart05ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart05.Series["Processes That Started Services "].Color = $script:ServiceAutoChart05ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart05ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'ProcessName' -eq $($script:ServiceAutoChart05InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart05InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart05ImportCsvPosResults) { $script:ServiceAutoChart05InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart05ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart05ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart05ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart05ImportCsvPosResults) { $script:ServiceAutoChart05ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart05InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart05ImportCsvNegResults) { $script:ServiceAutoChart05InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart05InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart05ImportCsvPosResults.count))"
    $script:ServiceAutoChart05InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart05ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart05CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart05TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart05TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart05TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart05CheckDiffButton
$script:ServiceAutoChart05CheckDiffButton.Add_Click({
    $script:ServiceAutoChart05InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'ProcessName' -ExpandProperty 'ProcessName' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart05InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart05InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart05InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart05InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart05InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart05InvestDiffDropDownArray) { $script:ServiceAutoChart05InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart05InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:ServiceAutoChart05InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart05InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart05InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart05InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart05InvestDiffExecuteButton
    $script:ServiceAutoChart05InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:ServiceAutoChart05InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart05InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart05InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart05InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart05InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart05InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart05InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart05InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart05InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart05InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart05InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart05InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart05InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart05InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart05InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart05InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart05InvestDiffDropDownLabel,$script:ServiceAutoChart05InvestDiffDropDownComboBox,$script:ServiceAutoChart05InvestDiffExecuteButton,$script:ServiceAutoChart05InvestDiffPosResultsLabel,$script:ServiceAutoChart05InvestDiffPosResultsTextBox,$script:ServiceAutoChart05InvestDiffNegResultsLabel,$script:ServiceAutoChart05InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart05InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart05InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart05CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart05ManipulationPanel.controls.Add($script:ServiceAutoChart05CheckDiffButton)
    

$script:ServiceAutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart05CheckDiffButton.Location.X + $script:ServiceAutoChart05CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart05CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart05ExpandChartButton
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05ExpandChartButton)


$script:ServiceAutoChart05OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart05CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart05CheckDiffButton.Location.Y + $script:ServiceAutoChart05CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart05OpenInShell
$script:ServiceAutoChart05OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart05ManipulationPanel.controls.Add($script:ServiceAutoChart05OpenInShell)


$script:ServiceAutoChart05Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart05OpenInShell.Location.X + $script:ServiceAutoChart05OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart05OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart05Results
$script:ServiceAutoChart05Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart05ManipulationPanel.controls.Add($script:ServiceAutoChart05Results)

### Save the chart to file
$script:ServiceAutoChart05SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart05OpenInShell.Location.X
                  Y = $script:ServiceAutoChart05OpenInShell.Location.Y + $script:ServiceAutoChart05OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart05SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart05SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05 -Title $script:AutoChart05Title
})
$script:ServiceAutoChart05ManipulationPanel.controls.Add($script:ServiceAutoChart05SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart05NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart05SaveButton.Location.X 
                        Y = $script:ServiceAutoChart05SaveButton.Location.Y + $script:ServiceAutoChart05SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart05CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart05ManipulationPanel.Controls.Add($script:ServiceAutoChart05NoticeTextbox)

$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.Clear()
$script:ServiceAutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart05.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}    






















#
##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart06 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart04.Location.X
                  Y = $script:ServiceAutoChart04.Location.Y + $script:ServiceAutoChart04.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart06.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart06Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart06.Titles.Add($script:ServiceAutoChart06Title)

### Create Charts Area
$script:ServiceAutoChart06Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart06Area.Name        = 'Chart Area'
$script:ServiceAutoChart06Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart06Area.AxisX.Interval          = 1
$script:ServiceAutoChart06Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart06Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart06Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart06.ChartAreas.Add($script:ServiceAutoChart06Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart06.Series.Add("Accounts That Started Services")  
$script:ServiceAutoChart06.Series["Accounts That Started Services"].Enabled           = $True
$script:ServiceAutoChart06.Series["Accounts That Started Services"].BorderWidth       = 1
$script:ServiceAutoChart06.Series["Accounts That Started Services"].IsVisibleInLegend = $false
$script:ServiceAutoChart06.Series["Accounts That Started Services"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart06.Series["Accounts That Started Services"].Legend            = 'Legend'
$script:ServiceAutoChart06.Series["Accounts That Started Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart06.Series["Accounts That Started Services"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart06.Series["Accounts That Started Services"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart06.Series["Accounts That Started Services"].ChartType         = 'Column'
$script:ServiceAutoChart06.Series["Accounts That Started Services"].Color             = 'Gray'

        function Generate-ServicesAutoChart06 {
            $script:ServiceAutoChart06CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart06UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'StartName' | Sort-Object -Property 'StartName' -Unique
#            $script:ServiceAutoChart05UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'} | Select-Object -Property 'ProcessName' | Sort-Object -Property 'ProcessName' -Unique
#batman
            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart06UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()

            if ($script:ServiceAutoChart06UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart06Title.ForeColor = 'Black'
                $script:ServiceAutoChart06Title.Text = "Accounts That Started Services"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart06OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart06UniqueDataFields) {
                    $Count = 0
                    $script:ServiceAutoChart06CsvComputers = @()
                    foreach ( $Line in $script:ServiceAutoChartDataSourceServices ) {
                        if ($($Line.StartName) -eq $DataField.StartName) {
                            $Count += 1
                            if ( $script:ServiceAutoChart06CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart06CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart06UniqueCount = $script:ServiceAutoChart06CsvComputers.Count
                    $script:ServiceAutoChart06DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart06UniqueCount
                        Computers   = $script:ServiceAutoChart06CsvComputers 
                    }
                    $script:ServiceAutoChart06OverallDataResults += $script:ServiceAutoChart06DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount) }

                $script:ServiceAutoChart06TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart06OverallDataResults.count))
                $script:ServiceAutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart06OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart06Title.ForeColor = 'Red'
                $script:ServiceAutoChart06Title.Text = "Accounts That Started Services`n
[ No data not available ]`n
Run 'Get-WmiOBject Win32_Service' or 'Get-EnrichedService'
to obtain Account Start Name data`n`n"                
            }
        }
        Generate-ServicesAutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart06OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart06.Location.X + 5
                   Y = $script:ServiceAutoChart06.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart06OptionsButton
$script:ServiceAutoChart06OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart06OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart06OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart06.Controls.Add($script:ServiceAutoChart06ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart06OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart06OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart06.Controls.Remove($script:ServiceAutoChart06ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart06OptionsButton)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart06)

$script:ServiceAutoChart06ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart06.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart06.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart06TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart06TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart06OverallDataResults.count))                
    $script:ServiceAutoChart06TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart06TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart06TrimOffFirstTrackBarValue = $script:ServiceAutoChart06TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart06TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart06TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
        $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart06TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart06TrimOffFirstTrackBar)
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart06TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart06TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart06TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart06TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart06TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart06TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart06TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart06OverallDataResults.count))
    $script:ServiceAutoChart06TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart06OverallDataResults.count)
    $script:ServiceAutoChart06TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart06TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart06TrimOffLastTrackBarValue = $($script:ServiceAutoChart06OverallDataResults.count) - $script:ServiceAutoChart06TrimOffLastTrackBar.Value
        $script:ServiceAutoChart06TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart06OverallDataResults.count) - $script:ServiceAutoChart06TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
        $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    })
$script:ServiceAutoChart06TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart06TrimOffLastTrackBar)
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart06ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart06TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart06TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart06TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart06ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart06.Series["Accounts That Started Services"].ChartType = $script:ServiceAutoChart06ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
#    $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
})
$script:ServiceAutoChart06ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart06ChartTypesAvailable) { $script:ServiceAutoChart06ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart063DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart06ChartTypeComboBox.Location.X + $script:ServiceAutoChart06ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart06ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart063DToggleButton
$script:ServiceAutoChart063DInclination = 0
$script:ServiceAutoChart063DToggleButton.Add_Click({
    $script:ServiceAutoChart063DInclination += 10
    if ( $script:ServiceAutoChart063DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart06Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart06Area.Area3DStyle.Inclination = $script:ServiceAutoChart063DInclination
        $script:ServiceAutoChart063DToggleButton.Text  = "3D On ($script:ServiceAutoChart063DInclination)"
#        $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
#        $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart063DInclination -le 90 ) {
        $script:ServiceAutoChart06Area.Area3DStyle.Inclination = $script:ServiceAutoChart063DInclination
        $script:ServiceAutoChart063DToggleButton.Text  = "3D On ($script:ServiceAutoChart063DInclination)" 
#        $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
#        $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart063DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart063DInclination = 0
        $script:ServiceAutoChart06Area.Area3DStyle.Inclination = $script:ServiceAutoChart063DInclination
        $script:ServiceAutoChart06Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
#        $script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart063DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart06ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart063DToggleButton.Location.X + $script:ServiceAutoChart063DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart063DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart06ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart06ColorsAvailable) { $script:ServiceAutoChart06ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart06ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart06.Series["Accounts That Started Services"].Color = $script:ServiceAutoChart06ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart06ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'StartName' -eq $($script:ServiceAutoChart06InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart06InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart06ImportCsvPosResults) { $script:ServiceAutoChart06InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart06ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart06ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart06ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart06ImportCsvPosResults) { $script:ServiceAutoChart06ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart06InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart06ImportCsvNegResults) { $script:ServiceAutoChart06InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart06InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart06ImportCsvPosResults.count))"
    $script:ServiceAutoChart06InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart06ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart06CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart06TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart06TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart06TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart06CheckDiffButton
$script:ServiceAutoChart06CheckDiffButton.Add_Click({
    $script:ServiceAutoChart06InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'StartName' -ExpandProperty 'StartName' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart06InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart06InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart06InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart06InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart06InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart06InvestDiffDropDownArray) { $script:ServiceAutoChart06InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart06InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:ServiceAutoChart06InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart06InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart06InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart06InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:ServiceAutoChart06InvestDiffExecuteButton
    $script:ServiceAutoChart06InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:ServiceAutoChart06InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart06InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart06InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart06InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart06InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart06InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart06InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart06InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart06InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart06InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart06InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart06InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart06InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart06InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart06InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart06InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart06InvestDiffDropDownLabel,$script:ServiceAutoChart06InvestDiffDropDownComboBox,$script:ServiceAutoChart06InvestDiffExecuteButton,$script:ServiceAutoChart06InvestDiffPosResultsLabel,$script:ServiceAutoChart06InvestDiffPosResultsTextBox,$script:ServiceAutoChart06InvestDiffNegResultsLabel,$script:ServiceAutoChart06InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart06InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart06InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart06CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart06ManipulationPanel.controls.Add($script:ServiceAutoChart06CheckDiffButton)
    

$script:ServiceAutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart06CheckDiffButton.Location.X + $script:ServiceAutoChart06CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart06CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart06ExpandChartButton
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06ExpandChartButton)


$script:ServiceAutoChart06OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart06CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart06CheckDiffButton.Location.Y + $script:ServiceAutoChart06CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart06OpenInShell
$script:ServiceAutoChart06OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart06ManipulationPanel.controls.Add($script:ServiceAutoChart06OpenInShell)


$script:ServiceAutoChart06Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart06OpenInShell.Location.X + $script:ServiceAutoChart06OpenInShell.Size.Width + 5 
                   Y = $script:ServiceAutoChart06OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart06Results
$script:ServiceAutoChart06Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart06ManipulationPanel.controls.Add($script:ServiceAutoChart06Results)

### Save the chart to file
$script:ServiceAutoChart06SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart06OpenInShell.Location.X
                  Y = $script:ServiceAutoChart06OpenInShell.Location.Y + $script:ServiceAutoChart06OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart06SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart06SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06 -Title $script:AutoChart06Title
})
$script:ServiceAutoChart06ManipulationPanel.controls.Add($script:ServiceAutoChart06SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart06NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart06SaveButton.Location.X 
                        Y = $script:ServiceAutoChart06SaveButton.Location.Y + $script:ServiceAutoChart06SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart06CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart06ManipulationPanel.Controls.Add($script:ServiceAutoChart06NoticeTextbox)

$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.Clear()
$script:ServiceAutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart06.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}    



















<#
The following are commented out and just templates for future charts

##############################################################################################
# AutoChart07
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart07 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart05.Location.X
                  Y = $script:ServiceAutoChart05.Location.Y + $script:ServiceAutoChart05.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart07.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart07Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart07.Titles.Add($script:ServiceAutoChart07Title)

### Create Charts Area
$script:ServiceAutoChart07Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart07Area.Name        = 'Chart Area'
$script:ServiceAutoChart07Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart07Area.AxisX.Interval          = 1
$script:ServiceAutoChart07Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart07Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart07Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart07.ChartAreas.Add($script:ServiceAutoChart07Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart07.Series.Add("Signer Certificate")  
$script:ServiceAutoChart07.Series["Signer Certificate"].Enabled           = $True
$script:ServiceAutoChart07.Series["Signer Certificate"].BorderWidth       = 1
$script:ServiceAutoChart07.Series["Signer Certificate"].IsVisibleInLegend = $false
$script:ServiceAutoChart07.Series["Signer Certificate"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart07.Series["Signer Certificate"].Legend            = 'Legend'
$script:ServiceAutoChart07.Series["Signer Certificate"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart07.Series["Signer Certificate"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart07.Series["Signer Certificate"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart07.Series["Signer Certificate"].ChartType         = 'Column'
$script:ServiceAutoChart07.Series["Signer Certificate"].Color             = 'SlateBLue'

        function Generate-ServicesAutoChart07 {
            $script:ServiceAutoChart07CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart07UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'SignerCertificate' | Sort-Object -Property 'SignerCertificate' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart07UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()

            if ($script:ServiceAutoChart07UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart07Title.ForeColor = 'Black'
                $script:ServiceAutoChart07Title.Text = "Signer Certificate"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart07OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart07UniqueDataFields) {
                    $Count = 0
                    $script:ServiceAutoChart07CsvComputers = @()
                    foreach ( $Line in $script:ServiceAutoChartDataSourceServices ) {
                        if ($($Line.SignerCertificate) -eq $DataField.SignerCertificate) {
                            $Count += 1
                            if ( $script:ServiceAutoChart07CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart07CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart07UniqueCount = $script:ServiceAutoChart07CsvComputers.Count
                    $script:ServiceAutoChart07DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart07UniqueCount
                        Computers   = $script:ServiceAutoChart07CsvComputers 
                    }
                    $script:ServiceAutoChart07OverallDataResults += $script:ServiceAutoChart07DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount) }

                $script:ServiceAutoChart07TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart07OverallDataResults.count))
                $script:ServiceAutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart07OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart07Title.ForeColor = 'Red'
                $script:ServiceAutoChart07Title.Text = "Signer Certificate`n
[ No data not available ]`n
Run 'Get-EnhancedProcesses' to obtain MD5 Hash data`n`n"                
            }
        }
        Generate-ServicesAutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart07OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart07.Location.X + 5
                   Y = $script:ServiceAutoChart07.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $ServiceAutoChart07OptionsButton
$script:ServiceAutoChart07OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart07OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart07OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart07.Controls.Add($script:ServiceAutoChart07ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart07OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart07OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart07.Controls.Remove($script:ServiceAutoChart07ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart07OptionsButton)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart07)

$script:ServiceAutoChart07ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart07.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart07.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart07TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart07TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart07OverallDataResults.count))                
    $script:ServiceAutoChart07TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart07TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart07TrimOffFirstTrackBarValue = $script:ServiceAutoChart07TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart07TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart07TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
        $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart07TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart07TrimOffFirstTrackBar)
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart07TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart07TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart07TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart07TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart07TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart07TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart07TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart07OverallDataResults.count))
    $script:ServiceAutoChart07TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart07OverallDataResults.count)
    $script:ServiceAutoChart07TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart07TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart07TrimOffLastTrackBarValue = $($script:ServiceAutoChart07OverallDataResults.count) - $script:ServiceAutoChart07TrimOffLastTrackBar.Value
        $script:ServiceAutoChart07TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart07OverallDataResults.count) - $script:ServiceAutoChart07TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
        $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    })
$script:ServiceAutoChart07TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart07TrimOffLastTrackBar)
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart07ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart07TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart07TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart07TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart07ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart07.Series["Signer Certificate"].ChartType = $script:ServiceAutoChart07ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
#    $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
})
$script:ServiceAutoChart07ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart07ChartTypesAvailable) { $script:ServiceAutoChart07ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart073DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart07ChartTypeComboBox.Location.X + $script:ServiceAutoChart07ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart07ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart073DToggleButton
$script:ServiceAutoChart073DInclination = 0
$script:ServiceAutoChart073DToggleButton.Add_Click({
    $script:ServiceAutoChart073DInclination += 10
    if ( $script:ServiceAutoChart073DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart07Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart07Area.Area3DStyle.Inclination = $script:ServiceAutoChart073DInclination
        $script:ServiceAutoChart073DToggleButton.Text  = "3D On ($script:ServiceAutoChart073DInclination)"
#        $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
#        $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart073DInclination -le 90 ) {
        $script:ServiceAutoChart07Area.Area3DStyle.Inclination = $script:ServiceAutoChart073DInclination
        $script:ServiceAutoChart073DToggleButton.Text  = "3D On ($script:ServiceAutoChart073DInclination)" 
#        $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
#        $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart073DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart073DInclination = 0
        $script:ServiceAutoChart07Area.Area3DStyle.Inclination = $script:ServiceAutoChart073DInclination
        $script:ServiceAutoChart07Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
#        $script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart073DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart07ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart073DToggleButton.Location.X + $script:ServiceAutoChart073DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart073DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart07ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart07ColorsAvailable) { $script:ServiceAutoChart07ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart07ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart07.Series["Signer Certificate"].Color = $script:ServiceAutoChart07ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart07ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'SignerCertificate' -eq $($script:ServiceAutoChart07InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart07InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart07ImportCsvPosResults) { $script:ServiceAutoChart07InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart07ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart07ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart07ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart07ImportCsvPosResults) { $script:ServiceAutoChart07ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart07InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart07ImportCsvNegResults) { $script:ServiceAutoChart07InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart07InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart07ImportCsvPosResults.count))"
    $script:ServiceAutoChart07InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart07ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart07CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart07TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart07TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart07TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart07CheckDiffButton
$script:ServiceAutoChart07CheckDiffButton.Add_Click({
    $script:ServiceAutoChart07InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'SignerCertificate' -ExpandProperty 'SignerCertificate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart07InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart07InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart07InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart07InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart07InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart07InvestDiffDropDownArray) { $script:ServiceAutoChart07InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart07InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:ServiceAutoChart07InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart07InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart07InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart07InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
CommonButtonSettings -Button $script:ServiceAutoChart07InvestDiffExecuteButton
    $script:ServiceAutoChart07InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:ServiceAutoChart07InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart07InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart07InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart07InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart07InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart07InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart07InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart07InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart07InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart07InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart07InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart07InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart07InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart07InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart07InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart07InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart07InvestDiffDropDownLabel,$script:ServiceAutoChart07InvestDiffDropDownComboBox,$script:ServiceAutoChart07InvestDiffExecuteButton,$script:ServiceAutoChart07InvestDiffPosResultsLabel,$script:ServiceAutoChart07InvestDiffPosResultsTextBox,$script:ServiceAutoChart07InvestDiffNegResultsLabel,$script:ServiceAutoChart07InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart07InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart07InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart07CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart07ManipulationPanel.controls.Add($script:ServiceAutoChart07CheckDiffButton)
    

$script:ServiceAutoChart07ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart07CheckDiffButton.Location.X + $script:ServiceAutoChart07CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart07CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart07ExpandChartButton
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07ExpandChartButton)


$script:ServiceAutoChart07OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart07CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart07CheckDiffButton.Location.Y + $script:ServiceAutoChart07CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart07OpenInShell
$script:ServiceAutoChart07OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart07ManipulationPanel.controls.Add($script:ServiceAutoChart07OpenInShell)


$script:ServiceAutoChart07Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart07OpenInShell.Location.X + $script:ServiceAutoChart07OpenInShell.Size.Width + 5 
                   Y = $script:ServiceAutoChart07OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart07Results
$script:ServiceAutoChart07Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart07ManipulationPanel.controls.Add($script:ServiceAutoChart07Results)

### Save the chart to file
$script:ServiceAutoChart07SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart07OpenInShell.Location.X
                  Y = $script:ServiceAutoChart07OpenInShell.Location.Y + $script:ServiceAutoChart07OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart07SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart07SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07 -Title $script:AutoChart07Title
})
$script:ServiceAutoChart07ManipulationPanel.controls.Add($script:ServiceAutoChart07SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart07NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart07SaveButton.Location.X 
                        Y = $script:ServiceAutoChart07SaveButton.Location.Y + $script:ServiceAutoChart07SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart07CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart07ManipulationPanel.Controls.Add($script:ServiceAutoChart07NoticeTextbox)

$script:ServiceAutoChart07.Series["Signer Certificate"].Points.Clear()
$script:ServiceAutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart07.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}    






















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart08 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart06.Location.X
                  Y = $script:ServiceAutoChart06.Location.Y + $script:ServiceAutoChart06.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart08.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart08Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart08.Titles.Add($script:ServiceAutoChart08Title)

### Create Charts Area
$script:ServiceAutoChart08Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart08Area.Name        = 'Chart Area'
$script:ServiceAutoChart08Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart08Area.AxisX.Interval          = 1
$script:ServiceAutoChart08Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart08Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart08Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart08.ChartAreas.Add($script:ServiceAutoChart08Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart08.Series.Add("Signer Company")  
$script:ServiceAutoChart08.Series["Signer Company"].Enabled           = $True
$script:ServiceAutoChart08.Series["Signer Company"].BorderWidth       = 1
$script:ServiceAutoChart08.Series["Signer Company"].IsVisibleInLegend = $false
$script:ServiceAutoChart08.Series["Signer Company"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart08.Series["Signer Company"].Legend            = 'Legend'
$script:ServiceAutoChart08.Series["Signer Company"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart08.Series["Signer Company"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart08.Series["Signer Company"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart08.Series["Signer Company"].ChartType         = 'Column'
$script:ServiceAutoChart08.Series["Signer Company"].Color             = 'Purple'

        function Generate-ServicesAutoChart08 {
            $script:ServiceAutoChart08CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart08UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'SignerCompany' | Sort-Object -Property 'SignerCompany' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart08UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()

            if ($script:ServiceAutoChart08UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart08Title.ForeColor = 'Black'
                $script:ServiceAutoChart08Title.Text = "Signer Company"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart08OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart08UniqueDataFields) {
                    $Count        = 0
                    $script:ServiceAutoChart08CsvComputers = @()
                    foreach ( $Line in $script:ServiceAutoChartDataSourceServices ) {
                        if ($($Line.SignerCompany) -eq $DataField.SignerCompany) {
                            $Count += 1
                            if ( $script:ServiceAutoChart08CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart08CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart08UniqueCount = $script:ServiceAutoChart08CsvComputers.Count
                    $script:ServiceAutoChart08DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart08UniqueCount
                        Computers   = $script:ServiceAutoChart08CsvComputers 
                    }
                    $script:ServiceAutoChart08OverallDataResults += $script:ServiceAutoChart08DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount) }

                $script:ServiceAutoChart08TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart08OverallDataResults.count))
                $script:ServiceAutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart08OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart08Title.ForeColor = 'Red'
                $script:ServiceAutoChart08Title.Text = "Signer Company`n
[ No data not available ]`n
Run 'Get-EnhancedProcesses' to obtain MD5 Hash data`n`n"                
            }
        }
        Generate-ServicesAutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart08OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart08.Location.X + 5
                   Y = $script:ServiceAutoChart08.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart08OptionsButton
$script:ServiceAutoChart08OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart08OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart08OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart08.Controls.Add($script:ServiceAutoChart08ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart08OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart08OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart08.Controls.Remove($script:ServiceAutoChart08ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart08OptionsButton)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart08)

$script:ServiceAutoChart08ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart08.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart08.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart08TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart08TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart08OverallDataResults.count))                
    $script:ServiceAutoChart08TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart08TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart08TrimOffFirstTrackBarValue = $script:ServiceAutoChart08TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart08TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart08TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
        $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart08TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart08TrimOffFirstTrackBar)
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart08TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart08TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart08TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart08TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart08TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart08TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart08TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart08OverallDataResults.count))
    $script:ServiceAutoChart08TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart08OverallDataResults.count)
    $script:ServiceAutoChart08TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart08TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart08TrimOffLastTrackBarValue = $($script:ServiceAutoChart08OverallDataResults.count) - $script:ServiceAutoChart08TrimOffLastTrackBar.Value
        $script:ServiceAutoChart08TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart08OverallDataResults.count) - $script:ServiceAutoChart08TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
        $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    })
$script:ServiceAutoChart08TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart08TrimOffLastTrackBar)
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart08ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart08TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart08TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart08TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart08ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart08.Series["Signer Company"].ChartType = $script:ServiceAutoChart08ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
#    $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
})
$script:ServiceAutoChart08ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart08ChartTypesAvailable) { $script:ServiceAutoChart08ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart083DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart08ChartTypeComboBox.Location.X + $script:ServiceAutoChart08ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart08ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart083DToggleButton
$script:ServiceAutoChart083DInclination = 0
$script:ServiceAutoChart083DToggleButton.Add_Click({
    $script:ServiceAutoChart083DInclination += 10
    if ( $script:ServiceAutoChart083DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart08Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart08Area.Area3DStyle.Inclination = $script:ServiceAutoChart083DInclination
        $script:ServiceAutoChart083DToggleButton.Text  = "3D On ($script:ServiceAutoChart083DInclination)"
#        $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
#        $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart083DInclination -le 90 ) {
        $script:ServiceAutoChart08Area.Area3DStyle.Inclination = $script:ServiceAutoChart083DInclination
        $script:ServiceAutoChart083DToggleButton.Text  = "3D On ($script:ServiceAutoChart083DInclination)" 
#        $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
#        $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart083DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart083DInclination = 0
        $script:ServiceAutoChart08Area.Area3DStyle.Inclination = $script:ServiceAutoChart083DInclination
        $script:ServiceAutoChart08Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
#        $script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart083DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart08ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart083DToggleButton.Location.X + $script:ServiceAutoChart083DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart083DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart08ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart08ColorsAvailable) { $script:ServiceAutoChart08ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart08ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart08.Series["Signer Company"].Color = $script:ServiceAutoChart08ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart08ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'SignerCompany' -eq $($script:ServiceAutoChart08InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart08InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart08ImportCsvPosResults) { $script:ServiceAutoChart08InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart08ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart08ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart08ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart08ImportCsvPosResults) { $script:ServiceAutoChart08ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart08InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart08ImportCsvNegResults) { $script:ServiceAutoChart08InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart08InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart08ImportCsvPosResults.count))"
    $script:ServiceAutoChart08InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart08ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart08CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart08TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart08TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart08TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart08CheckDiffButton
$script:ServiceAutoChart08CheckDiffButton.Add_Click({
    $script:ServiceAutoChart08InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'SignerCompany' -ExpandProperty 'SignerCompany' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart08InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart08InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart08InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart08InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart08InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart08InvestDiffDropDownArray) { $script:ServiceAutoChart08InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart08InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:ServiceAutoChart08InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart08InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart08InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart08InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
CommonButtonSettings -Button $script:ServiceAutoChart08InvestDiffExecuteButton
    $script:ServiceAutoChart08InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:ServiceAutoChart08InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart08InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart08InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart08InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart08InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart08InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart08InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart08InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart08InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart08InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart08InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart08InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart08InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart08InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart08InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart08InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart08InvestDiffDropDownLabel,$script:ServiceAutoChart08InvestDiffDropDownComboBox,$script:ServiceAutoChart08InvestDiffExecuteButton,$script:ServiceAutoChart08InvestDiffPosResultsLabel,$script:ServiceAutoChart08InvestDiffPosResultsTextBox,$script:ServiceAutoChart08InvestDiffNegResultsLabel,$script:ServiceAutoChart08InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart08InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart08InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart08CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart08ManipulationPanel.controls.Add($script:ServiceAutoChart08CheckDiffButton)
    

$script:ServiceAutoChart08ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart08CheckDiffButton.Location.X + $script:ServiceAutoChart08CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart08CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart08ExpandChartButton
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08ExpandChartButton)


$script:ServiceAutoChart08OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart08CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart08CheckDiffButton.Location.Y + $script:ServiceAutoChart08CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart08OpenInShell
$script:ServiceAutoChart08OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart08ManipulationPanel.controls.Add($script:ServiceAutoChart08OpenInShell)


$script:ServiceAutoChart08Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart08OpenInShell.Location.X + $script:ServiceAutoChart08OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart08OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart08Results
$script:ServiceAutoChart08Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart08ManipulationPanel.controls.Add($script:ServiceAutoChart08Results)

### Save the chart to file
$script:ServiceAutoChart08SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart08OpenInShell.Location.X
                  Y = $script:ServiceAutoChart08OpenInShell.Location.Y + $script:ServiceAutServiceAutoChart08OpenInShelloChart08Results.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart08SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart08SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08 -Title $script:AutoChart08Title
})
$script:ServiceAutoChart08ManipulationPanel.controls.Add($script:ServiceAutoChart08SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart08NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart08SaveButton.Location.X 
                        Y = $script:ServiceAutoChart08SaveButton.Location.Y + $script:ServiceAutoChart08SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart08CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart08ManipulationPanel.Controls.Add($script:ServiceAutoChart08NoticeTextbox)

$script:ServiceAutoChart08.Series["Signer Company"].Points.Clear()
$script:ServiceAutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart08.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}    






















##############################################################################################
# AutoChart09
##############################################################################################

### Auto Create Charts Object
$script:ServiceAutoChart09 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:ServiceAutoChart07.Location.X
                  Y = $script:ServiceAutoChart07.Location.Y + $script:ServiceAutoChart07.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:ServiceAutoChart09.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:ServiceAutoChart09Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:ServiceAutoChart09.Titles.Add($script:ServiceAutoChart09Title)

### Create Charts Area
$script:ServiceAutoChart09Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:ServiceAutoChart09Area.Name        = 'Chart Area'
$script:ServiceAutoChart09Area.AxisX.Title = 'Hosts'
$script:ServiceAutoChart09Area.AxisX.Interval          = 1
$script:ServiceAutoChart09Area.AxisY.IntervalAutoMode  = $true
$script:ServiceAutoChart09Area.Area3DStyle.Enable3D    = $false
$script:ServiceAutoChart09Area.Area3DStyle.Inclination = 75
$script:ServiceAutoChart09.ChartAreas.Add($script:ServiceAutoChart09Area)

### Auto Create Charts Data Series Recent
$script:ServiceAutoChart09.Series.Add("Process Path")  
$script:ServiceAutoChart09.Series["Process Path"].Enabled           = $True
$script:ServiceAutoChart09.Series["Process Path"].BorderWidth       = 1
$script:ServiceAutoChart09.Series["Process Path"].IsVisibleInLegend = $false
$script:ServiceAutoChart09.Series["Process Path"].Chartarea         = 'Chart Area'
$script:ServiceAutoChart09.Series["Process Path"].Legend            = 'Legend'
$script:ServiceAutoChart09.Series["Process Path"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:ServiceAutoChart09.Series["Process Path"]['PieLineColor']   = 'Black'
$script:ServiceAutoChart09.Series["Process Path"]['PieLabelStyle']  = 'Outside'
$script:ServiceAutoChart09.Series["Process Path"].ChartType         = 'Column'
$script:ServiceAutoChart09.Series["Process Path"].Color             = 'Yellow'

        function Generate-ServicesAutoChart09 {
            $script:ServiceAutoChart09CsvFileHosts      = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:ServiceAutoChart09UniqueDataFields  = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Path' | Sort-Object -Property 'Path' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:ServiceAutoChart09UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()

            if ($script:ServiceAutoChart09UniqueDataFields.count -gt 0){
                $script:ServiceAutoChart09Title.ForeColor = 'Black'
                $script:ServiceAutoChart09Title.Text = "Process Path"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:ServiceAutoChart09OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:ServiceAutoChart09UniqueDataFields) {
                    $Count        = 0
                    $script:ServiceAutoChart09CsvComputers = @()
                    foreach ( $Line in $script:ServiceAutoChartDataSourceServices ) {
                        if ($($Line.Path) -eq $DataField.Path) {
                            $Count += 1
                            if ( $script:ServiceAutoChart09CsvComputers -notcontains $($Line.PSComputerName) ) { $script:ServiceAutoChart09CsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:ServiceAutoChart09UniqueCount = $script:ServiceAutoChart09CsvComputers.Count
                    $script:ServiceAutoChart09DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:ServiceAutoChart09UniqueCount
                        Computers   = $script:ServiceAutoChart09CsvComputers 
                    }
                    $script:ServiceAutoChart09OverallDataResults += $script:ServiceAutoChart09DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount) }

                $script:ServiceAutoChart09TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart09OverallDataResults.count))
                $script:ServiceAutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart09OverallDataResults.count))
            }
            else {
                $script:ServiceAutoChart09Title.ForeColor = 'Red'
                $script:ServiceAutoChart09Title.Text = "Process Path`n
[ No data not available ]`n
Run a query to collect service data.`n`n"                
            }
        }
        Generate-ServicesAutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:ServiceAutoChart09OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:ServiceAutoChart09.Location.X + 5
                   Y = $script:ServiceAutoChart09.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $ServiceAutoChart09OptionsButton
$script:ServiceAutoChart09OptionsButton.Add_Click({  
    if ($script:ServiceAutoChart09OptionsButton.Text -eq 'Options v') {
        $script:ServiceAutoChart09OptionsButton.Text = 'Options ^'
        $script:ServiceAutoChart09.Controls.Add($script:ServiceAutoChart09ManipulationPanel)
    }
    elseif ($script:ServiceAutoChart09OptionsButton.Text -eq 'Options ^') {
        $script:ServiceAutoChart09OptionsButton.Text = 'Options v'
        $script:ServiceAutoChart09.Controls.Remove($script:ServiceAutoChart09ManipulationPanel)
    }
})
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart09OptionsButton)
$script:ServiceAutoChartsIndividualTab01.Controls.Add($script:ServiceAutoChart09)

$script:ServiceAutoChart09ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:ServiceAutoChart09.Size.Height - 121 }
    Size        = @{ Width  = $script:ServiceAutoChart09.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:ServiceAutoChart09TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:ServiceAutoChart09TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:ServiceAutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:ServiceAutoChart09OverallDataResults.count))                
    $script:ServiceAutoChart09TrimOffFirstTrackBarValue   = 0
    $script:ServiceAutoChart09TrimOffFirstTrackBar.add_ValueChanged({
        $script:ServiceAutoChart09TrimOffFirstTrackBarValue = $script:ServiceAutoChart09TrimOffFirstTrackBar.Value
        $script:ServiceAutoChart09TrimOffFirstGroupBox.Text = "Trim Off First: $($script:ServiceAutoChart09TrimOffFirstTrackBar.Value)"
        $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
        $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}    
    })
    $script:ServiceAutoChart09TrimOffFirstGroupBox.Controls.Add($script:ServiceAutoChart09TrimOffFirstTrackBar)
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:ServiceAutoChart09TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:ServiceAutoChart09TrimOffFirstGroupBox.Location.X + $script:ServiceAutoChart09TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:ServiceAutoChart09TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:ServiceAutoChart09TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:ServiceAutoChart09TrimOffLastTrackBar.RightToLeft   = $true
    $script:ServiceAutoChart09TrimOffLastTrackBar.SetRange(0, $($script:ServiceAutoChart09OverallDataResults.count))
    $script:ServiceAutoChart09TrimOffLastTrackBar.Value         = $($script:ServiceAutoChart09OverallDataResults.count)
    $script:ServiceAutoChart09TrimOffLastTrackBarValue   = 0
    $script:ServiceAutoChart09TrimOffLastTrackBar.add_ValueChanged({
        $script:ServiceAutoChart09TrimOffLastTrackBarValue = $($script:ServiceAutoChart09OverallDataResults.count) - $script:ServiceAutoChart09TrimOffLastTrackBar.Value
        $script:ServiceAutoChart09TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:ServiceAutoChart09OverallDataResults.count) - $script:ServiceAutoChart09TrimOffLastTrackBar.Value)"
        $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
        $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
$script:ServiceAutoChart09TrimOffLastGroupBox.Controls.Add($script:ServiceAutoChart09TrimOffLastTrackBar)
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:ServiceAutoChart09ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:ServiceAutoChart09TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:ServiceAutoChart09TrimOffFirstGroupBox.Location.Y + $script:ServiceAutoChart09TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart09ChartTypeComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart09.Series["Process Path"].ChartType = $script:ServiceAutoChart09ChartTypeComboBox.SelectedItem
#    $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
#    $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
})
$script:ServiceAutoChart09ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:ServiceAutoChart09ChartTypesAvailable) { $script:ServiceAutoChart09ChartTypeComboBox.Items.Add($Item) }
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:ServiceAutoChart093DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:ServiceAutoChart09ChartTypeComboBox.Location.X + $script:ServiceAutoChart09ChartTypeComboBox.Size.Width + 8
                   Y = $script:ServiceAutoChart09ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:ServiceAutoChart093DToggleButton
$script:ServiceAutoChart093DInclination = 0
$script:ServiceAutoChart093DToggleButton.Add_Click({
    $script:ServiceAutoChart093DInclination += 10
    if ( $script:ServiceAutoChart093DToggleButton.Text -eq "3D Off" ) { 
        $script:ServiceAutoChart09Area.Area3DStyle.Enable3D    = $true
        $script:ServiceAutoChart09Area.Area3DStyle.Inclination = $script:ServiceAutoChart093DInclination
        $script:ServiceAutoChart093DToggleButton.Text  = "3D On ($script:ServiceAutoChart093DInclination)"
#        $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
#        $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    elseif ( $script:ServiceAutoChart093DInclination -le 90 ) {
        $script:ServiceAutoChart09Area.Area3DStyle.Inclination = $script:ServiceAutoChart093DInclination
        $script:ServiceAutoChart093DToggleButton.Text  = "3D On ($script:ServiceAutoChart093DInclination)" 
#        $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
#        $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    else { 
        $script:ServiceAutoChart093DToggleButton.Text  = "3D Off" 
        $script:ServiceAutoChart093DInclination = 0
        $script:ServiceAutoChart09Area.Area3DStyle.Inclination = $script:ServiceAutoChart093DInclination
        $script:ServiceAutoChart09Area.Area3DStyle.Enable3D    = $false
#        $script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
#        $script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
})
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart093DToggleButton)

### Change the color of the chart
$script:ServiceAutoChart09ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:ServiceAutoChart093DToggleButton.Location.X + $script:ServiceAutoChart093DToggleButton.Size.Width + 5
                   Y = $script:ServiceAutoChart093DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:ServiceAutoChart09ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:ServiceAutoChart09ColorsAvailable) { $script:ServiceAutoChart09ChangeColorComboBox.Items.Add($Item) }
$script:ServiceAutoChart09ChangeColorComboBox.add_SelectedIndexChanged({
    $script:ServiceAutoChart09.Series["Process Path"].Color = $script:ServiceAutoChart09ChangeColorComboBox.SelectedItem
})
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {    
    # List of Positive Endpoints that positively match
    $script:ServiceAutoChart09ImportCsvPosResults = $script:ServiceAutoChartDataSourceServices | Where-Object 'Path' -eq $($script:ServiceAutoChart09InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:ServiceAutoChart09InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart09ImportCsvPosResults) { $script:ServiceAutoChart09InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:ServiceAutoChart09ImportCsvAll = $script:ServiceAutoChartDataSourceServices | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:ServiceAutoChart09ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:ServiceAutoChart09ImportCsvAll) { if ($Endpoint -notin $script:ServiceAutoChart09ImportCsvPosResults) { $script:ServiceAutoChart09ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:ServiceAutoChart09InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:ServiceAutoChart09ImportCsvNegResults) { $script:ServiceAutoChart09InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:ServiceAutoChart09InvestDiffPosResultsLabel.Text = "Positive Match ($($script:ServiceAutoChart09ImportCsvPosResults.count))"
    $script:ServiceAutoChart09InvestDiffNegResultsLabel.Text = "Negative Match ($($script:ServiceAutoChart09ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:ServiceAutoChart09CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:ServiceAutoChart09TrimOffLastGroupBox.Location.X + $script:ServiceAutoChart09TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:ServiceAutoChart09TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:ServiceAutoChart09CheckDiffButton
$script:ServiceAutoChart09CheckDiffButton.Add_Click({
    $script:ServiceAutoChart09InvestDiffDropDownArray = $script:ServiceAutoChartDataSourceServices | Select-Object -Property 'Path' -ExpandProperty 'Path' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:ServiceAutoChart09InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:ServiceAutoChart09InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart09InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart09InvestDiffDropDownLabel.Location.y + $script:ServiceAutoChart09InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:ServiceAutoChart09InvestDiffDropDownArray) { $script:ServiceAutoChart09InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:ServiceAutoChart09InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:ServiceAutoChart09InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:ServiceAutoChart09InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:ServiceAutoChart09InvestDiffDropDownComboBox.Location.y + $script:ServiceAutoChart09InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
CommonButtonSettings -Button $script:ServiceAutoChart09InvestDiffExecuteButto
    $script:ServiceAutoChart09InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:ServiceAutoChart09InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:ServiceAutoChart09InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart09InvestDiffExecuteButton.Location.y + $script:ServiceAutoChart09InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:ServiceAutoChart09InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:ServiceAutoChart09InvestDiffPosResultsLabel.Location.y + $script:ServiceAutoChart09InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:ServiceAutoChart09InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:ServiceAutoChart09InvestDiffPosResultsLabel.Location.x + $script:ServiceAutoChart09InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:ServiceAutoChart09InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:ServiceAutoChart09InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:ServiceAutoChart09InvestDiffNegResultsLabel.Location.x
                        Y = $script:ServiceAutoChart09InvestDiffNegResultsLabel.Location.y + $script:ServiceAutoChart09InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:ServiceAutoChart09InvestDiffForm.Controls.AddRange(@($script:ServiceAutoChart09InvestDiffDropDownLabel,$script:ServiceAutoChart09InvestDiffDropDownComboBox,$script:ServiceAutoChart09InvestDiffExecuteButton,$script:ServiceAutoChart09InvestDiffPosResultsLabel,$script:ServiceAutoChart09InvestDiffPosResultsTextBox,$script:ServiceAutoChart09InvestDiffNegResultsLabel,$script:ServiceAutoChart09InvestDiffNegResultsTextBox))
    $script:ServiceAutoChart09InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:ServiceAutoChart09InvestDiffForm.ShowDialog()
})
$script:ServiceAutoChart09CheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:ServiceAutoChart09ManipulationPanel.controls.Add($script:ServiceAutoChart09CheckDiffButton)
    

$script:ServiceAutoChart09ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:ServiceAutoChart09CheckDiffButton.Location.X + $script:ServiceAutoChart09CheckDiffButton.Size.Width + 5
                  Y = $script:ServiceAutoChart09CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceProcessesFileName -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:ServiceAutoChart09ExpandChartButton
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09ExpandChartButton)


$script:ServiceAutoChart09OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:ServiceAutoChart09CheckDiffButton.Location.X
                   Y = $script:ServiceAutoChart09CheckDiffButton.Location.Y + $script:ServiceAutoChart09CheckDiffButton.Size.Height + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:ServiceAutoChart09OpenInShell
$script:ServiceAutoChart09OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:ServiceAutoChart09ManipulationPanel.controls.Add($script:ServiceAutoChart09OpenInShell)


$script:ServiceAutoChart09Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:ServiceAutoChart09OpenInShell.Location.X + $script:ServiceAutoChart09OpenInShell.Size.Width + 5
                   Y = $script:ServiceAutoChart09OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $ServiceAutoChart09Results
$script:ServiceAutoChart09Results.Add_Click({ $script:ServiceAutoChartDataSourceServices | Out-GridView -Title "$script:ServiceAutoChartCSVFileMostRecentCollection" }) 
$script:ServiceAutoChart09ManipulationPanel.controls.Add($script:ServiceAutoChart09Results)

### Save the chart to file
$script:ServiceAutoChart09SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:ServiceAutoChart09OpenInShell.Location.X
                  Y = $script:ServiceAutoChart09OpenInShell.Location.Y + $script:ServiceAutoChart09OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $ServiceAutoChart09SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:ServiceAutoChart09SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09 -Title $script:AutoChart09Title
})
$script:ServiceAutoChart09ManipulationPanel.controls.Add($script:ServiceAutoChart09SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:ServiceAutoChart09NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:ServiceAutoChart09SaveButton.Location.X 
                        Y = $script:ServiceAutoChart09SaveButton.Location.Y + $script:ServiceAutoChart09SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:ServiceAutoChart09CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:ServiceAutoChart09ManipulationPanel.Controls.Add($script:ServiceAutoChart09NoticeTextbox)

$script:ServiceAutoChart09.Series["Process Path"].Points.Clear()
$script:ServiceAutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:ServiceAutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:ServiceAutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:ServiceAutoChart09.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}    

#>
