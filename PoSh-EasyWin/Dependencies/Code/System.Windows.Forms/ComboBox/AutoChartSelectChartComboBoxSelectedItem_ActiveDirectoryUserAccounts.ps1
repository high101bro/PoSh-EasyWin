$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Active Directory User Account Info'
    Size   = @{ Width  = 1700
                Height = 1050 }
    #Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",11,0,0,0)
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

$script:AutoChart01CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'AD Accounts') { $script:AutoChart01CSVFileMatch += $CSVFile } }
} 
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01CSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSource = $null
$script:AutoChartDataSource = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


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
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'AD User Accounts'
    Location = @{ X = 5
                  Y = 5 }
    Size   = @{ Width  = 1150
                Height = 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter' 
}

### Import select file to view information
$AutoChartSelectFileButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Select File To Analyze'
    Location = @{ X = 5
                  Y = 5 }
    Size   = @{ Width  = 200
                Height = 25 }
}
CommonButtonSettings -Button $AutoChartSelectFileButton
$script:AutoChartOpenResultsOpenFileDialogfilename = $null
$AutoChartSelectFileButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $AutoChartOpenResultsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $AutoChartOpenResultsOpenFileDialog.Title            = "Open XML Data"
    $AutoChartOpenResultsOpenFileDialog.InitialDirectory = "$(if (Test-Path $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
    $AutoChartOpenResultsOpenFileDialog.filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
    $AutoChartOpenResultsOpenFileDialog.ShowDialog() | Out-Null
    $AutoChartOpenResultsOpenFileDialog.ShowHelp = $true
    $script:AutoChartOpenResultsOpenFileDialogfilename = $AutoChartOpenResultsOpenFileDialog.filename
    $script:AutoChartDataSource = Import-Csv $script:AutoChartOpenResultsOpenFileDialogfilename

    # This variable is used elsewhere
    $script:AutoChartDataSourceFileName = $AutoChartOpenResultsOpenFileDialog.filename

    Generate-AutoChart01
    Generate-AutoChart02
    Generate-AutoChart03
    Generate-AutoChart04
    Generate-AutoChart05
    Generate-AutoChart06
    Generate-AutoChart07
    Generate-AutoChart08
    Generate-AutoChart09
    Generate-AutoChart10
})
$AutoChartSelectFileButton.Add_MouseHover = {
    Show-ToolTip -Title "View Results" -Icon "Info" -Message @"
+  Select a file to view Process Info.
"@ 
}

$script:AutoChartsIndividualTab01.Controls.AddRange(@($AutoChartSelectFileButton,$script:AutoChartsMainLabel01))

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


















##############################################################################################
# AutoChart01
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 5
                  Y = 50 }
    Size     = @{ Width  = 560
                  Height = 375 }
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
$script:AutoChart01.Series.Add("When Created")
$script:AutoChart01.Series["When Created"].Enabled           = $True
$script:AutoChart01.Series["When Created"].BorderWidth       = 1
$script:AutoChart01.Series["When Created"].IsVisibleInLegend = $false
$script:AutoChart01.Series["When Created"].Chartarea         = 'Chart Area'
$script:AutoChart01.Series["When Created"].Legend            = 'Legend'
$script:AutoChart01.Series["When Created"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01.Series["When Created"]['PieLineColor']   = 'Black'
$script:AutoChart01.Series["When Created"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01.Series["When Created"].ChartType         = 'Column'
$script:AutoChart01.Series["When Created"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name
            $script:AutoChart01UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenCreated | Sort-Object WhenCreated -unique
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01.Series["When Created"].Points.Clear()

            if ($script:AutoChart01UniqueDataFields.count -gt 0){
                $script:AutoChart01Title.ForeColor = 'Black'
                $script:AutoChart01Title.Text = "When Created"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart01OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.WhenCreated) -eq $DataField.WhenCreated) {
                            $Count += 1
                            if ( $script:AutoChart01CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart01CsvComputers += $($Line.Name) }
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
                $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount) }
                $script:AutoChart01TrimOffLastTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
                $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
            }
            else {
                $script:AutoChart01Title.ForeColor = 'Red'
                $script:AutoChart01Title.Text = "When Created`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart01OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01.Location.X + 5
                   Y = $script:AutoChart01.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart01OptionsButton
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
                     Y = $script:AutoChart01.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart01.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))                
    $script:AutoChart01TrimOffFirstTrackBarValue   = 0
    $script:AutoChart01TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01TrimOffFirstTrackBarValue = $script:AutoChart01TrimOffFirstTrackBar.Value
        $script:AutoChart01TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01TrimOffFirstTrackBar.Value)"
        $script:AutoChart01.Series["When Created"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
    })
    $script:AutoChart01TrimOffFirstGroupBox.Controls.Add($script:AutoChart01TrimOffFirstTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X + $script:AutoChart01TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart01.Series["When Created"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
    })
$script:AutoChart01TrimOffLastGroupBox.Controls.Add($script:AutoChart01TrimOffLastTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y + $script:AutoChart01TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01.Series["When Created"].ChartType = $script:AutoChart01ChartTypeComboBox.SelectedItem
#    $script:AutoChart01.Series["When Created"].Points.Clear()
#    $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
})
$script:AutoChart01ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ChartTypesAvailable) { $script:AutoChart01ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart013DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ChartTypeComboBox.Location.X + $script:AutoChart01ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart01ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart013DToggleButton
$script:AutoChart013DInclination = 0
$script:AutoChart013DToggleButton.Add_Click({
    
    $script:AutoChart013DInclination += 10
    if ( $script:AutoChart013DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)"
#        $script:AutoChart01.Series["When Created"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart013DInclination -le 90 ) {
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)" 
#        $script:AutoChart01.Series["When Created"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart013DToggleButton.Text  = "3D Off" 
        $script:AutoChart013DInclination = 0
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01.Series["When Created"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}
    }
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart013DToggleButton)

### Change the color of the chart
$script:AutoChart01ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart013DToggleButton.Location.X + $script:AutoChart013DToggleButton.Size.Width + 5
                   Y = $script:AutoChart013DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ColorsAvailable) { $script:AutoChart01ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01.Series["When Created"].Color = $script:AutoChart01ChangeColorComboBox.SelectedItem
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenCreated' -eq $($script:AutoChart01InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart01InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart01TrimOffLastGroupBox.Location.X + $script:AutoChart01TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart01TrimOffLastGroupBox.Location.Y + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01CheckDiffButton
$script:AutoChart01CheckDiffButton.Add_Click({
    $script:AutoChart01InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenCreated' -ExpandProperty 'WhenCreated' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart01InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart01InvestDiffDropDownLabel.Location.y + $script:AutoChart01InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01InvestDiffDropDownArray) { $script:AutoChart01InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart01InvestDiffDropDownComboBox.Location.y + $script:AutoChart01InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart01InvestDiffExecuteButton
    $script:AutoChart01InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart01InvestDiffExecuteButton.Location.y + $script:AutoChart01InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart01InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y + $script:AutoChart01InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01InvestDiffPosResultsLabel.Location.x + $script:AutoChart01InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart01InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01InvestDiffNegResultsLabel.Location.y + $script:AutoChart01InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart01CheckDiffButton.Location.X + $script:AutoChart01CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart01CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "When Created" -PropertyX "WhenCreated" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01ManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01CheckDiffButton.Location.X
                   Y = $script:AutoChart01CheckDiffButton.Location.Y + $script:AutoChart01CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart01OpenInShell
$script:AutoChart01OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01OpenInShell)


$script:AutoChart01ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01OpenInShell.Location.X + $script:AutoChart01OpenInShell.Size.Width + 5
                   Y = $script:AutoChart01OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart01ViewResults
$script:AutoChart01ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01ViewResults)


### Save the chart to file
$script:AutoChart01SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01OpenInShell.Location.X
                  Y = $script:AutoChart01OpenInShell.Location.Y + $script:AutoChart01OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart01SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01 -Title $script:AutoChart01Title
})
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SaveButton.Location.X 
                        Y = $script:AutoChart01SaveButton.Location.Y + $script:AutoChart01SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01NoticeTextbox)

$script:AutoChart01.Series["When Created"].Points.Clear()
$script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["When Created"].Points.AddXY($_.DataField.WhenCreated,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01.Location.X + $script:AutoChart01.Size.Width + 20
                  Y = $script:AutoChart01.Location.Y }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart02Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
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
$script:AutoChart02.Series.Add("When Modified")
$script:AutoChart02.Series["When Modified"].Enabled           = $True
$script:AutoChart02.Series["When Modified"].BorderWidth       = 1
$script:AutoChart02.Series["When Modified"].IsVisibleInLegend = $false
$script:AutoChart02.Series["When Modified"].Chartarea         = 'Chart Area'
$script:AutoChart02.Series["When Modified"].Legend            = 'Legend'
$script:AutoChart02.Series["When Modified"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02.Series["When Modified"]['PieLineColor']   = 'Black'
$script:AutoChart02.Series["When Modified"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02.Series["When Modified"].ChartType         = 'Column'
$script:AutoChart02.Series["When Modified"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart02UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenModified | Sort-Object WhenModified -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02.Series["When Modified"].Points.Clear()

            if ($script:AutoChart02UniqueDataFields.count -gt 0){
                $script:AutoChart02Title.ForeColor = 'Black'
                $script:AutoChart02Title.Text = "When Modified"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart02OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart02CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.WhenModified) -eq $DataField.WhenModified) {
                            $Count += 1
                            if ( $script:AutoChart02CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart02CsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart02UniqueCount = $script:AutoChart02CsvComputers.Count
                    $script:AutoChart02DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02UniqueCount
                        Computers   = $script:AutoChart02CsvComputers 
                    }
                    $script:AutoChart02OverallDataResults += $script:AutoChart02DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount) }
                $script:AutoChart02TrimOffLastTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
                $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
            }
            else {
                $script:AutoChart02Title.ForeColor = 'Red'
                $script:AutoChart02Title.Text = "When Modified`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart02OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02.Location.X + 5
                   Y = $script:AutoChart02.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart02OptionsButton
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
                     Y = $script:AutoChart02.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart02.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))                
    $script:AutoChart02TrimOffFirstTrackBarValue   = 0
    $script:AutoChart02TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02TrimOffFirstTrackBarValue = $script:AutoChart02TrimOffFirstTrackBar.Value
        $script:AutoChart02TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02TrimOffFirstTrackBar.Value)"
        $script:AutoChart02.Series["When Modified"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
    })
    $script:AutoChart02TrimOffFirstGroupBox.Controls.Add($script:AutoChart02TrimOffFirstTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X + $script:AutoChart02TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart02.Series["When Modified"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
    })
$script:AutoChart02TrimOffLastGroupBox.Controls.Add($script:AutoChart02TrimOffLastTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y + $script:AutoChart02TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02.Series["When Modified"].ChartType = $script:AutoChart02ChartTypeComboBox.SelectedItem
#    $script:AutoChart02.Series["When Modified"].Points.Clear()
#    $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
})
$script:AutoChart02ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ChartTypesAvailable) { $script:AutoChart02ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart023DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ChartTypeComboBox.Location.X + $script:AutoChart02ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart02ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart023DToggleButton
$script:AutoChart023DInclination = 0
$script:AutoChart023DToggleButton.Add_Click({
    
    $script:AutoChart023DInclination += 10
    if ( $script:AutoChart023DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)"
#        $script:AutoChart02.Series["When Modified"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart023DInclination -le 90 ) {
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)" 
#        $script:AutoChart02.Series["When Modified"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart023DToggleButton.Text  = "3D Off" 
        $script:AutoChart023DInclination = 0
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02.Series["When Modified"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}
    }
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart023DToggleButton)

### Change the color of the chart
$script:AutoChart02ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart023DToggleButton.Location.X + $script:AutoChart023DToggleButton.Size.Width + 5
                   Y = $script:AutoChart023DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ColorsAvailable) { $script:AutoChart02ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02.Series["When Modified"].Color = $script:AutoChart02ChangeColorComboBox.SelectedItem
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenModified' -eq $($script:AutoChart02InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart02InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart02TrimOffLastGroupBox.Location.X + $script:AutoChart02TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart02TrimOffLastGroupBox.Location.Y + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02CheckDiffButton
$script:AutoChart02CheckDiffButton.Add_Click({
    $script:AutoChart02InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenModified' -ExpandProperty 'WhenModified' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart02InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart02InvestDiffDropDownLabel.Location.y + $script:AutoChart02InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02InvestDiffDropDownArray) { $script:AutoChart02InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart02InvestDiffDropDownComboBox.Location.y + $script:AutoChart02InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart02InvestDiffExecuteButton
    $script:AutoChart02InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart02InvestDiffExecuteButton.Location.y + $script:AutoChart02InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart02InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y + $script:AutoChart02InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02InvestDiffPosResultsLabel.Location.x + $script:AutoChart02InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart02InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02InvestDiffNegResultsLabel.Location.y + $script:AutoChart02InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart02CheckDiffButton.Location.X + $script:AutoChart02CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart02CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "When Modified" -PropertyX "WhenModified" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02ManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02CheckDiffButton.Location.X
                   Y = $script:AutoChart02CheckDiffButton.Location.Y + $script:AutoChart02CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart02OpenInShell
$script:AutoChart02OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02OpenInShell)


$script:AutoChart02ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02OpenInShell.Location.X + $script:AutoChart02OpenInShell.Size.Width + 5
                   Y = $script:AutoChart02OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart02ViewResults
$script:AutoChart02ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02ViewResults)


### Save the chart to file
$script:AutoChart02SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02OpenInShell.Location.X
                  Y = $script:AutoChart02OpenInShell.Location.Y + $script:AutoChart02OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart02SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02 -Title $script:AutoChart02Title
})
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SaveButton.Location.X 
                        Y = $script:AutoChart02SaveButton.Location.Y + $script:AutoChart02SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02NoticeTextbox)

$script:AutoChart02.Series["When Modified"].Points.Clear()
$script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["When Modified"].Points.AddXY($_.DataField.WhenModified,$_.UniqueCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01.Location.X
                  Y = $script:AutoChart01.Location.Y + $script:AutoChart01.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
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
$script:AutoChart03.Series.Add("When Last Logon Date")  
$script:AutoChart03.Series["When Last Logon Date"].Enabled           = $True
$script:AutoChart03.Series["When Last Logon Date"].BorderWidth       = 1
$script:AutoChart03.Series["When Last Logon Date"].IsVisibleInLegend = $false
$script:AutoChart03.Series["When Last Logon Date"].Chartarea         = 'Chart Area'
$script:AutoChart03.Series["When Last Logon Date"].Legend            = 'Legend'
$script:AutoChart03.Series["When Last Logon Date"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03.Series["When Last Logon Date"]['PieLineColor']   = 'Black'
$script:AutoChart03.Series["When Last Logon Date"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03.Series["When Last Logon Date"].ChartType         = 'Column'
$script:AutoChart03.Series["When Last Logon Date"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart03UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenLastLogonDate | Sort-Object WhenLastLogonDate -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()

            if ($script:AutoChart03UniqueDataFields.count -gt 0){
                $script:AutoChart03Title.ForeColor = 'Black'
                $script:AutoChart03Title.Text = "When Last Logon Date"
                
                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart03OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($Line.WhenLastLogonDate -eq $DataField.WhenLastLogonDate) {
                            $Count += 1
                            if ( $script:AutoChart03CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart03CsvComputers += $($Line.Name) }                        
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
                $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount) }

                $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
                $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
            }
            else {
                $script:AutoChart03Title.ForeColor = 'Red'
                $script:AutoChart03Title.Text = "When Last Logon Date`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03.Location.X + 5
                   Y = $script:AutoChart03.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart03OptionsButton
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
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03)

$script:AutoChart03ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart03.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))                
    $script:AutoChart03TrimOffFirstTrackBarValue   = 0
    $script:AutoChart03TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffFirstTrackBarValue = $script:AutoChart03TrimOffFirstTrackBar.Value
        $script:AutoChart03TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03TrimOffFirstTrackBar.Value)"
        $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}    
    })
    $script:AutoChart03TrimOffFirstGroupBox.Controls.Add($script:AutoChart03TrimOffFirstTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + $script:AutoChart03TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
    $script:AutoChart03TrimOffLastTrackBar.Value         = $($script:AutoChart03OverallDataResults.count)
    $script:AutoChart03TrimOffLastTrackBarValue   = 0
    $script:AutoChart03TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffLastTrackBarValue = $($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value
        $script:AutoChart03TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value)"
        $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}
    })
$script:AutoChart03TrimOffLastGroupBox.Controls.Add($script:AutoChart03TrimOffLastTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y + $script:AutoChart03TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03.Series["When Last Logon Date"].ChartType = $script:AutoChart03ChartTypeComboBox.SelectedItem
#    $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
#    $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}
})
$script:AutoChart03ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ChartTypesAvailable) { $script:AutoChart03ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart033DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ChartTypeComboBox.Location.X + $script:AutoChart03ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart03ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart033DToggleButton
$script:AutoChart033DInclination = 0
$script:AutoChart033DToggleButton.Add_Click({
    $script:AutoChart033DInclination += 10
    if ( $script:AutoChart033DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)"
#        $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart033DInclination -le 90 ) {
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)" 
#        $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart033DToggleButton.Text  = "3D Off" 
        $script:AutoChart033DInclination = 0
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}
    }
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart033DToggleButton)

### Change the color of the chart
$script:AutoChart03ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart033DToggleButton.Location.X + $script:AutoChart033DToggleButton.Size.Width + 5
                   Y = $script:AutoChart033DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ColorsAvailable) { $script:AutoChart03ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03.Series["When Last Logon Date"].Color = $script:AutoChart03ChangeColorComboBox.SelectedItem
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenLastLogonDate' -eq $($script:AutoChart03InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart03InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart03TrimOffLastGroupBox.Location.X + $script:AutoChart03TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart03TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03CheckDiffButton
$script:AutoChart03CheckDiffButton.Add_Click({
    $script:AutoChart03InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenLastLogonDate' -ExpandProperty 'WhenLastLogonDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart03InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart03InvestDiffDropDownLabel.Location.y + $script:AutoChart03InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03InvestDiffDropDownArray) { $script:AutoChart03InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart03InvestDiffDropDownComboBox.Location.y + $script:AutoChart03InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart03InvestDiffExecuteButton
    $script:AutoChart03InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart03InvestDiffExecuteButton.Location.y + $script:AutoChart03InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart03InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y + $script:AutoChart03InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03InvestDiffPosResultsLabel.Location.x + $script:AutoChart03InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart03InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03InvestDiffNegResultsLabel.Location.y + $script:AutoChart03InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    

$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03CheckDiffButton.Location.X + $script:AutoChart03CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart03CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "When Last Logon Date" -PropertyX "WhenLastLogonDate" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03ManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03CheckDiffButton.Location.X
                   Y = $script:AutoChart03CheckDiffButton.Location.Y + $script:AutoChart03CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart03OpenInShell
$script:AutoChart03OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03OpenInShell)


$script:AutoChart03ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03OpenInShell.Location.X + $script:AutoChart03OpenInShell.Size.Width + 5
                   Y = $script:AutoChart03OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart03ViewResults
$script:AutoChart03ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03ViewResults)


### Save the chart to file
$script:AutoChart03SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03OpenInShell.Location.X
                  Y = $script:AutoChart03OpenInShell.Location.Y + $script:AutoChart03OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart03SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03 -Title $script:AutoChart03Title
})
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SaveButton.Location.X 
                        Y = $script:AutoChart03SaveButton.Location.Y + $script:AutoChart03SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03NoticeTextbox)

$script:AutoChart03.Series["When Last Logon Date"].Points.Clear()
$script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["When Last Logon Date"].Points.AddXY($_.DataField.WhenLastLogonDate,$_.UniqueCount)}    





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02.Location.X
                  Y = $script:AutoChart02.Location.Y + $script:AutoChart02.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart04Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
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
$script:AutoChart04.Series.Add("When Last Bad Password Attempt")  
$script:AutoChart04.Series["When Last Bad Password Attempt"].Enabled           = $True
$script:AutoChart04.Series["When Last Bad Password Attempt"].BorderWidth       = 1
$script:AutoChart04.Series["When Last Bad Password Attempt"].IsVisibleInLegend = $false
$script:AutoChart04.Series["When Last Bad Password Attempt"].Chartarea         = 'Chart Area'
$script:AutoChart04.Series["When Last Bad Password Attempt"].Legend            = 'Legend'
$script:AutoChart04.Series["When Last Bad Password Attempt"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04.Series["When Last Bad Password Attempt"]['PieLineColor']   = 'Black'
$script:AutoChart04.Series["When Last Bad Password Attempt"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04.Series["When Last Bad Password Attempt"].ChartType         = 'Column'
$script:AutoChart04.Series["When Last Bad Password Attempt"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart04UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenLastBadPasswordAttempt | Sort-Object WhenLastBadPasswordAttempt -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()

            if ($script:AutoChart04UniqueDataFields.count -gt 0){
                $script:AutoChart04Title.ForeColor = 'Black'
                $script:AutoChart04Title.Text = "When Last Bad Password Attempt"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart04OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.WhenLastBadPasswordAttempt) -eq $DataField.WhenLastBadPasswordAttempt) {
                            $Count += 1
                            if ( $script:AutoChart04CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart04CsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart04UniqueCount = $script:AutoChart04CsvComputers.Count
                    $script:AutoChart04DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04UniqueCount
                        Computers   = $script:AutoChart04CsvComputers 
                    }
                    $script:AutoChart04OverallDataResults += $script:AutoChart04DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount) }

                $script:AutoChart04TrimOffLastTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
                $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
            }
            else {
                $script:AutoChart04Title.ForeColor = 'Red'
                $script:AutoChart04Title.Text = "When Last Bad Password Attempt`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04.Location.X + 5
                   Y = $script:AutoChart04.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart04OptionsButton
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
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04)

$script:AutoChart04ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart04.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))                
    $script:AutoChart04TrimOffFirstTrackBarValue   = 0
    $script:AutoChart04TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04TrimOffFirstTrackBarValue = $script:AutoChart04TrimOffFirstTrackBar.Value
        $script:AutoChart04TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04TrimOffFirstTrackBar.Value)"
        $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}    
    })
    $script:AutoChart04TrimOffFirstGroupBox.Controls.Add($script:AutoChart04TrimOffFirstTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + $script:AutoChart04TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}
    })
$script:AutoChart04TrimOffLastGroupBox.Controls.Add($script:AutoChart04TrimOffLastTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y + $script:AutoChart04TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04.Series["When Last Bad Password Attempt"].ChartType = $script:AutoChart04ChartTypeComboBox.SelectedItem
#    $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
#    $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}
})
$script:AutoChart04ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ChartTypesAvailable) { $script:AutoChart04ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart043DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ChartTypeComboBox.Location.X + $script:AutoChart04ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart04ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart043DToggleButton
$script:AutoChart043DInclination = 0
$script:AutoChart043DToggleButton.Add_Click({
    $script:AutoChart043DInclination += 10
    if ( $script:AutoChart043DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)"
#        $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart043DInclination -le 90 ) {
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)" 
#        $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart043DToggleButton.Text  = "3D Off" 
        $script:AutoChart043DInclination = 0
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}
    }
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart043DToggleButton)

### Change the color of the chart
$script:AutoChart04ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart043DToggleButton.Location.X + $script:AutoChart043DToggleButton.Size.Width + 5
                   Y = $script:AutoChart043DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ColorsAvailable) { $script:AutoChart04ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04.Series["When Last Bad Password Attempt"].Color = $script:AutoChart04ChangeColorComboBox.SelectedItem
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenLastBadPasswordAttempt' -eq $($script:AutoChart04InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart04InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart04TrimOffLastGroupBox.Location.X + $script:AutoChart04TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart04TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04CheckDiffButton
$script:AutoChart04CheckDiffButton.Add_Click({
    $script:AutoChart04InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenLastBadPasswordAttempt' -ExpandProperty 'WhenLastBadPasswordAttempt' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart04InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart04InvestDiffDropDownLabel.Location.y + $script:AutoChart04InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04InvestDiffDropDownArray) { $script:AutoChart04InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart04InvestDiffDropDownComboBox.Location.y + $script:AutoChart04InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart04InvestDiffExecuteButton 
    $script:AutoChart04InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart04InvestDiffExecuteButton.Location.y + $script:AutoChart04InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart04InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y + $script:AutoChart04InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04InvestDiffPosResultsLabel.Location.x + $script:AutoChart04InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart04InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04InvestDiffNegResultsLabel.Location.y + $script:AutoChart04InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    

$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04CheckDiffButton.Location.X + $script:AutoChart04CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart04CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "When Last Bad Password Attempt" -PropertyX "WhenLastBadPasswordAttempt" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04ManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04CheckDiffButton.Location.X
                   Y = $script:AutoChart04CheckDiffButton.Location.Y + $script:AutoChart04CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart04OpenInShell
$script:AutoChart04OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04OpenInShell)


$script:AutoChart04ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04OpenInShell.Location.X + $script:AutoChart04OpenInShell.Size.Width + 5
                   Y = $script:AutoChart04OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart04ViewResults
$script:AutoChart04ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04ViewResults)


### Save the chart to file
$script:AutoChart04SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04OpenInShell.Location.X
                  Y = $script:AutoChart04OpenInShell.Location.Y + $script:AutoChart04OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart04SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04 -Title $script:AutoChart04Title
})
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SaveButton.Location.X 
                        Y = $script:AutoChart04SaveButton.Location.Y + $script:AutoChart04SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04NoticeTextbox)

$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.Clear()
$script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["When Last Bad Password Attempt"].Points.AddXY($_.DataField.WhenLastBadPasswordAttempt,$_.UniqueCount)}    



















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03.Location.X
                  Y = $script:AutoChart03.Location.Y + $script:AutoChart03.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
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
$script:AutoChart05.Series.Add("When Password Last Set")
$script:AutoChart05.Series["When Password Last Set"].Enabled           = $True
$script:AutoChart05.Series["When Password Last Set"].BorderWidth       = 1
$script:AutoChart05.Series["When Password Last Set"].IsVisibleInLegend = $false
$script:AutoChart05.Series["When Password Last Set"].Chartarea         = 'Chart Area'
$script:AutoChart05.Series["When Password Last Set"].Legend            = 'Legend'
$script:AutoChart05.Series["When Password Last Set"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05.Series["When Password Last Set"]['PieLineColor']   = 'Black'
$script:AutoChart05.Series["When Password Last Set"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05.Series["When Password Last Set"].ChartType         = 'Column'
$script:AutoChart05.Series["When Password Last Set"].Color             = 'Brown'

        function Generate-AutoChart05 {
            $script:AutoChart05CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart05UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenPasswordLastSet | Sort-Object WhenPasswordLastSet -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05.Series["When Password Last Set"].Points.Clear()

            if ($script:AutoChart05UniqueDataFields.count -gt 0){
                $script:AutoChart05Title.ForeColor = 'Black'
                $script:AutoChart05Title.Text = "When Password Last Set"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart05OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.WhenPasswordLastSet) -eq $DataField.WhenPasswordLastSet) {
                            $Count += 1
                            if ( $script:AutoChart05CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart05CsvComputers += $($Line.Name) }
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
                $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount) }
                $script:AutoChart05TrimOffLastTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
                $script:AutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
            }
            else {
                $script:AutoChart05Title.ForeColor = 'Red'
                $script:AutoChart05Title.Text = "When Password Last Set`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05.Location.X + 5
                   Y = $script:AutoChart05.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart05OptionsButton
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
                     Y = $script:AutoChart05.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart05.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))                
    $script:AutoChart05TrimOffFirstTrackBarValue   = 0
    $script:AutoChart05TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05TrimOffFirstTrackBarValue = $script:AutoChart05TrimOffFirstTrackBar.Value
        $script:AutoChart05TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05TrimOffFirstTrackBar.Value)"
        $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
    })
    $script:AutoChart05TrimOffFirstGroupBox.Controls.Add($script:AutoChart05TrimOffFirstTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X + $script:AutoChart05TrimOffFirstGroupBox.Size.Width + 8
                     Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
    })
$script:AutoChart05TrimOffLastGroupBox.Controls.Add($script:AutoChart05TrimOffLastTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y + $script:AutoChart05TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05.Series["When Password Last Set"].ChartType = $script:AutoChart05ChartTypeComboBox.SelectedItem
#    $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
#    $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
})
$script:AutoChart05ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ChartTypesAvailable) { $script:AutoChart05ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05ChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart053DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ChartTypeComboBox.Location.X + $script:AutoChart05ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart05ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart053DToggleButton
$script:AutoChart053DInclination = 0
$script:AutoChart053DToggleButton.Add_Click({
    
    $script:AutoChart053DInclination += 10
    if ( $script:AutoChart053DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)"
#        $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart053DInclination -le 90 ) {
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)" 
#        $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart053DToggleButton.Text  = "3D Off" 
        $script:AutoChart053DInclination = 0
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05.Series["When Password Last Set"].Points.Clear()
#        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}
    }
})
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart053DToggleButton)

### Change the color of the chart
$script:AutoChart05ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart053DToggleButton.Location.X + $script:AutoChart053DToggleButton.Size.Width + 5
                   Y = $script:AutoChart053DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ColorsAvailable) { $script:AutoChart05ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05.Series["When Password Last Set"].Color = $script:AutoChart05ChangeColorComboBox.SelectedItem
})
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenPasswordLastSet' -eq $($script:AutoChart05InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart05InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ImportCsvPosResults) { $script:AutoChart05InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart05TrimOffLastGroupBox.Location.X + $script:AutoChart05TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart05TrimOffLastGroupBox.Location.Y + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05CheckDiffButton
$script:AutoChart05CheckDiffButton.Add_Click({
    $script:AutoChart05InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenPasswordLastSet' -ExpandProperty 'WhenPasswordLastSet' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart05InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart05InvestDiffDropDownLabel.Location.y + $script:AutoChart05InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05InvestDiffDropDownArray) { $script:AutoChart05InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart05InvestDiffDropDownComboBox.Location.y + $script:AutoChart05InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart05InvestDiffExecuteButton
    $script:AutoChart05InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart05InvestDiffExecuteButton.Location.y + $script:AutoChart05InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart05InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y + $script:AutoChart05InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05InvestDiffPosResultsLabel.Location.x + $script:AutoChart05InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart05InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05InvestDiffNegResultsLabel.Location.y + $script:AutoChart05InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart05CheckDiffButton.Location.X + $script:AutoChart05CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart05CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "When Password Last Set" -PropertyX "WhenPasswordLastSet" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05ManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05CheckDiffButton.Location.X
                   Y = $script:AutoChart05CheckDiffButton.Location.Y + $script:AutoChart05CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart05OpenInShell
$script:AutoChart05OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05OpenInShell)


$script:AutoChart05ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05OpenInShell.Location.X + $script:AutoChart05OpenInShell.Size.Width + 5
                   Y = $script:AutoChart05OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart05ViewResults
$script:AutoChart05ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05ViewResults)


### Save the chart to file
$script:AutoChart05SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05OpenInShell.Location.X
                  Y = $script:AutoChart05OpenInShell.Location.Y + $script:AutoChart05OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart05SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05 -Title $script:AutoChart05Title
})
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05SaveButton.Location.X 
                        Y = $script:AutoChart05SaveButton.Location.Y + $script:AutoChart05SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05NoticeTextbox)

$script:AutoChart05.Series["When Password Last Set"].Points.Clear()
$script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["When Password Last Set"].Points.AddXY($_.DataField.WhenPasswordLastSet,$_.UniqueCount)}






















##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04.Location.X
                  Y = $script:AutoChart04.Location.Y + $script:AutoChart04.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart06Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
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
$script:AutoChart06.Series.Add("Last Security Descriptor Core Propagation Data")  
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Enabled           = $True
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].BorderWidth       = 1
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].IsVisibleInLegend = $false
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Chartarea         = 'Chart Area'
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Legend            = 'Legend'
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"]['PieLineColor']   = 'Black'
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].ChartType         = 'Column'
$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Color             = 'Gray'

        function Generate-AutoChart06 {
            $script:AutoChart06CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart06UniqueDataFields  = $script:AutoChartDataSource | Select-Object LastdSCorePropagationData | Sort-Object LastdSCorePropagationData -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()

            if ($script:AutoChart06UniqueDataFields.count -gt 0){
                $script:AutoChart06Title.ForeColor = 'Black'
                $script:AutoChart06Title.Text = "Last Security Descriptor Core Propagation Data"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart06OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06UniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.LastdSCorePropagationData) -eq $DataField.LastdSCorePropagationData) {
                            $Count += 1
                            if ( $script:AutoChart06CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart06CsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart06UniqueCount = $script:AutoChart06CsvComputers.Count
                    $script:AutoChart06DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06UniqueCount
                        Computers   = $script:AutoChart06CsvComputers 
                    }
                    $script:AutoChart06OverallDataResults += $script:AutoChart06DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount) }

                $script:AutoChart06TrimOffLastTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
                $script:AutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
            }
            else {
                $script:AutoChart06Title.ForeColor = 'Red'
                $script:AutoChart06Title.Text = "Last Security Descriptor Core Propagation Data`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06.Location.X + 5
                   Y = $script:AutoChart06.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart06OptionsButton
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
                     Y = $script:AutoChart06.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart06.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))                
    $script:AutoChart06TrimOffFirstTrackBarValue   = 0
    $script:AutoChart06TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06TrimOffFirstTrackBarValue = $script:AutoChart06TrimOffFirstTrackBar.Value
        $script:AutoChart06TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06TrimOffFirstTrackBar.Value)"
        $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}    
    })
    $script:AutoChart06TrimOffFirstGroupBox.Controls.Add($script:AutoChart06TrimOffFirstTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X + $script:AutoChart06TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}
    })
$script:AutoChart06TrimOffLastGroupBox.Controls.Add($script:AutoChart06TrimOffLastTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y + $script:AutoChart06TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].ChartType = $script:AutoChart06ChartTypeComboBox.SelectedItem
#    $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
#    $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}
})
$script:AutoChart06ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ChartTypesAvailable) { $script:AutoChart06ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart063DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ChartTypeComboBox.Location.X + $script:AutoChart06ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart06ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart063DToggleButton
$script:AutoChart063DInclination = 0
$script:AutoChart063DToggleButton.Add_Click({
    $script:AutoChart063DInclination += 10
    if ( $script:AutoChart063DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)"
#        $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart063DInclination -le 90 ) {
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)" 
#        $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart063DToggleButton.Text  = "3D Off" 
        $script:AutoChart063DInclination = 0
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
#        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}
    }
})
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart063DToggleButton)

### Change the color of the chart
$script:AutoChart06ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart063DToggleButton.Location.X + $script:AutoChart063DToggleButton.Size.Width + 5
                   Y = $script:AutoChart063DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ColorsAvailable) { $script:AutoChart06ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Color = $script:AutoChart06ChangeColorComboBox.SelectedItem
})
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'LastdSCorePropagationData' -eq $($script:AutoChart06InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart06InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ImportCsvPosResults) { $script:AutoChart06InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart06TrimOffLastGroupBox.Location.X + $script:AutoChart06TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart06TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06CheckDiffButton
$script:AutoChart06CheckDiffButton.Add_Click({
    $script:AutoChart06InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'LastdSCorePropagationData' -ExpandProperty 'LastdSCorePropagationData' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart06InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart06InvestDiffDropDownLabel.Location.y + $script:AutoChart06InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06InvestDiffDropDownArray) { $script:AutoChart06InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart06InvestDiffDropDownComboBox.Location.y + $script:AutoChart06InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart06InvestDiffExecuteButton
    $script:AutoChart06InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart06InvestDiffExecuteButton.Location.y + $script:AutoChart06InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart06InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y + $script:AutoChart06InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06InvestDiffPosResultsLabel.Location.x + $script:AutoChart06InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart06InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06InvestDiffNegResultsLabel.Location.y + $script:AutoChart06InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart06CheckDiffButton.Location.X + $script:AutoChart06CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart06CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "Last Security Descriptor Core Propagation Dataes" -PropertyX "LastdSCorePropagationData" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06ManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06CheckDiffButton.Location.X
                   Y = $script:AutoChart06CheckDiffButton.Location.Y + $script:AutoChart06CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart06OpenInShell
$script:AutoChart06OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06OpenInShell)


$script:AutoChart06ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06OpenInShell.Location.X + $script:AutoChart06OpenInShell.Size.Width + 5
                   Y = $script:AutoChart06OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart06ViewResults
$script:AutoChart06ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06ViewResults)


### Save the chart to file
$script:AutoChart06SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06OpenInShell.Location.X
                  Y = $script:AutoChart06OpenInShell.Location.Y + $script:AutoChart06OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart06SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06 -Title $script:AutoChart06Title
})
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06SaveButton.Location.X 
                        Y = $script:AutoChart06SaveButton.Location.Y + $script:AutoChart06SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06NoticeTextbox)

$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.Clear()
$script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Last Security Descriptor Core Propagation Data"].Points.AddXY($_.DataField.LastdSCorePropagationData,$_.UniqueCount)}    





















##############################################################################################
# AutoChart07
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05.Location.X
                  Y = $script:AutoChart05.Location.Y + $script:AutoChart05.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
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
$script:AutoChart07.Series.Add("WhenAccountExpirationDate")  
$script:AutoChart07.Series["WhenAccountExpirationDate"].Enabled           = $True
$script:AutoChart07.Series["WhenAccountExpirationDate"].BorderWidth       = 1
$script:AutoChart07.Series["WhenAccountExpirationDate"].IsVisibleInLegend = $false
$script:AutoChart07.Series["WhenAccountExpirationDate"].Chartarea         = 'Chart Area'
$script:AutoChart07.Series["WhenAccountExpirationDate"].Legend            = 'Legend'
$script:AutoChart07.Series["WhenAccountExpirationDate"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07.Series["WhenAccountExpirationDate"]['PieLineColor']   = 'Black'
$script:AutoChart07.Series["WhenAccountExpirationDate"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07.Series["WhenAccountExpirationDate"].ChartType         = 'Column'
$script:AutoChart07.Series["WhenAccountExpirationDate"].Color             = 'SlateBLue'

        function Generate-AutoChart07 {
            $script:AutoChart07CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart07UniqueDataFields  = $script:AutoChartDataSource | Select-Object WhenAccountExpirationDate | Sort-Object WhenAccountExpirationDate -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()

            if ($script:AutoChart07UniqueDataFields.count -gt 0){
                $script:AutoChart07Title.ForeColor = 'Black'
                $script:AutoChart07Title.Text = "When Account Expiration Date"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart07OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07UniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.WhenAccountExpirationDate) -eq $DataField.WhenAccountExpirationDate) {
                            $Count += 1
                            if ( $script:AutoChart07CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart07CsvComputers += $($Line.Name) }                        
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
                $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount) }

                $script:AutoChart07TrimOffLastTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
                $script:AutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))
            }
            else {
                $script:AutoChart07Title.ForeColor = 'Red'
                $script:AutoChart07Title.Text = "WhenAccountExpirationDate`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart07OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07.Location.X + 5
                   Y = $script:AutoChart07.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart07OptionsButton
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
                     Y = $script:AutoChart07.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart07.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07OverallDataResults.count))                
    $script:AutoChart07TrimOffFirstTrackBarValue   = 0
    $script:AutoChart07TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07TrimOffFirstTrackBarValue = $script:AutoChart07TrimOffFirstTrackBar.Value
        $script:AutoChart07TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07TrimOffFirstTrackBar.Value)"
        $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}    
    })
    $script:AutoChart07TrimOffFirstGroupBox.Controls.Add($script:AutoChart07TrimOffFirstTrackBar)
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07TrimOffFirstGroupBox.Location.X + $script:AutoChart07TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart07TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}
    })
$script:AutoChart07TrimOffLastGroupBox.Controls.Add($script:AutoChart07TrimOffLastTrackBar)
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart07TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart07TrimOffFirstGroupBox.Location.Y + $script:AutoChart07TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07.Series["WhenAccountExpirationDate"].ChartType = $script:AutoChart07ChartTypeComboBox.SelectedItem
#    $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
#    $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}
})
$script:AutoChart07ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ChartTypesAvailable) { $script:AutoChart07ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart073DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ChartTypeComboBox.Location.X + $script:AutoChart07ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart07ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart073DToggleButton
$script:AutoChart073DInclination = 0
$script:AutoChart073DToggleButton.Add_Click({
    $script:AutoChart073DInclination += 10
    if ( $script:AutoChart073DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart07Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart073DToggleButton.Text  = "3D On ($script:AutoChart073DInclination)"
#        $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart073DInclination -le 90 ) {
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart073DToggleButton.Text  = "3D On ($script:AutoChart073DInclination)" 
#        $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart073DToggleButton.Text  = "3D Off" 
        $script:AutoChart073DInclination = 0
        $script:AutoChart07Area.Area3DStyle.Inclination = $script:AutoChart073DInclination
        $script:AutoChart07Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
#        $script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}
    }
})
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart073DToggleButton)

### Change the color of the chart
$script:AutoChart07ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart073DToggleButton.Location.X + $script:AutoChart073DToggleButton.Size.Width + 5
                   Y = $script:AutoChart073DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ColorsAvailable) { $script:AutoChart07ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07.Series["WhenAccountExpirationDate"].Color = $script:AutoChart07ChangeColorComboBox.SelectedItem
})
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart07ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'WhenAccountExpirationDate' -eq $($script:AutoChart07InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart07InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ImportCsvPosResults) { $script:AutoChart07InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart07TrimOffLastGroupBox.Location.X + $script:AutoChart07TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart07TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07CheckDiffButton
$script:AutoChart07CheckDiffButton.Add_Click({
    $script:AutoChart07InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'WhenAccountExpirationDate' -ExpandProperty 'WhenAccountExpirationDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart07InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart07InvestDiffDropDownLabel.Location.y + $script:AutoChart07InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07InvestDiffDropDownArray) { $script:AutoChart07InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:AutoChart07InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart07InvestDiffDropDownComboBox.Location.y + $script:AutoChart07InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart07InvestDiffExecuteButton
    $script:AutoChart07InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart07InvestDiffExecuteButton.Location.y + $script:AutoChart07InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart07InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart07InvestDiffPosResultsLabel.Location.y + $script:AutoChart07InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07InvestDiffPosResultsLabel.Location.x + $script:AutoChart07InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart07InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart07InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07InvestDiffNegResultsLabel.Location.y + $script:AutoChart07InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart07CheckDiffButton.Location.X + $script:AutoChart07CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart07CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "Process WhenAccountExpirationDate" -PropertyX "WhenAccountExpirationDate" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart07ExpandChartButton
$script:AutoChart07ManipulationPanel.Controls.Add($AutoChart07ExpandChartButton)


$script:AutoChart07OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07CheckDiffButton.Location.X
                   Y = $script:AutoChart07CheckDiffButton.Location.Y + $script:AutoChart07CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart07OpenInShell
$script:AutoChart07OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07OpenInShell)


$script:AutoChart07ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07OpenInShell.Location.X + $script:AutoChart07OpenInShell.Size.Width + 5
                   Y = $script:AutoChart07OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart07ViewResults
$script:AutoChart07ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07ViewResults)


### Save the chart to file
$script:AutoChart07SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07OpenInShell.Location.X
                  Y = $script:AutoChart07OpenInShell.Location.Y + $script:AutoChart07OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart07SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07 -Title $script:AutoChart07Title
})
$script:AutoChart07ManipulationPanel.controls.Add($script:AutoChart07SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07SaveButton.Location.X 
                        Y = $script:AutoChart07SaveButton.Location.Y + $script:AutoChart07SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ManipulationPanel.Controls.Add($script:AutoChart07NoticeTextbox)

$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.Clear()
$script:AutoChart07OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07.Series["WhenAccountExpirationDate"].Points.AddXY($_.DataField.WhenAccountExpirationDate,$_.UniqueCount)}    


















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06.Location.X
                  Y = $script:AutoChart06.Location.Y + $script:AutoChart06.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart08Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
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
$script:AutoChart08.Series.Add("Enabled Accounts")  
$script:AutoChart08.Series["Enabled Accounts"].Enabled           = $True
$script:AutoChart08.Series["Enabled Accounts"].BorderWidth       = 1
$script:AutoChart08.Series["Enabled Accounts"].IsVisibleInLegend = $false
$script:AutoChart08.Series["Enabled Accounts"].Chartarea         = 'Chart Area'
$script:AutoChart08.Series["Enabled Accounts"].Legend            = 'Legend'
$script:AutoChart08.Series["Enabled Accounts"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08.Series["Enabled Accounts"]['PieLineColor']   = 'Black'
$script:AutoChart08.Series["Enabled Accounts"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08.Series["Enabled Accounts"].ChartType         = 'Column'
$script:AutoChart08.Series["Enabled Accounts"].Color             = 'Gray'

        function Generate-AutoChart08 {
            $script:AutoChart08CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart08UniqueDataFields  = $script:AutoChartDataSource | Select-Object Enabled | Sort-Object Enabled -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()

            if ($script:AutoChart08UniqueDataFields.count -gt 0){
                $script:AutoChart08Title.ForeColor = 'Black'
                $script:AutoChart08Title.Text = "Enabled Accounts"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart08OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08UniqueDataFields) {
                    $Count = 0
                    $script:AutoChart08CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.Enabled) -eq $DataField.Enabled) {
                            $Count += 1
                            if ( $script:AutoChart08CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart08CsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart08UniqueCount = $script:AutoChart08CsvComputers.Count
                    $script:AutoChart08DataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08UniqueCount
                        Computers   = $script:AutoChart08CsvComputers 
                    }
                    $script:AutoChart08OverallDataResults += $script:AutoChart08DataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount) }

                $script:AutoChart08TrimOffLastTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
                $script:AutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))
            }
            else {
                $script:AutoChart08Title.ForeColor = 'Red'
                $script:AutoChart08Title.Text = "Enabled Accounts`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart08OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08.Location.X + 5
                   Y = $script:AutoChart08.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart08OptionsButton
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
                     Y = $script:AutoChart08.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart08.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08OverallDataResults.count))                
    $script:AutoChart08TrimOffFirstTrackBarValue   = 0
    $script:AutoChart08TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08TrimOffFirstTrackBarValue = $script:AutoChart08TrimOffFirstTrackBar.Value
        $script:AutoChart08TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08TrimOffFirstTrackBar.Value)"
        $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
        $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}    
    })
    $script:AutoChart08TrimOffFirstGroupBox.Controls.Add($script:AutoChart08TrimOffFirstTrackBar)
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08TrimOffFirstGroupBox.Location.X + $script:AutoChart08TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart08TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
        $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    })
$script:AutoChart08TrimOffLastGroupBox.Controls.Add($script:AutoChart08TrimOffLastTrackBar)
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart08TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart08TrimOffFirstGroupBox.Location.Y + $script:AutoChart08TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08.Series["Enabled Accounts"].ChartType = $script:AutoChart08ChartTypeComboBox.SelectedItem
#    $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
#    $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
})
$script:AutoChart08ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ChartTypesAvailable) { $script:AutoChart08ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart083DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ChartTypeComboBox.Location.X + $script:AutoChart08ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart08ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart083DToggleButton
$script:AutoChart083DInclination = 0
$script:AutoChart083DToggleButton.Add_Click({
    $script:AutoChart083DInclination += 10
    if ( $script:AutoChart083DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart08Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart083DToggleButton.Text  = "3D On ($script:AutoChart083DInclination)"
#        $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart083DInclination -le 90 ) {
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart083DToggleButton.Text  = "3D On ($script:AutoChart083DInclination)" 
#        $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart083DToggleButton.Text  = "3D Off" 
        $script:AutoChart083DInclination = 0
        $script:AutoChart08Area.Area3DStyle.Inclination = $script:AutoChart083DInclination
        $script:AutoChart08Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
})
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart083DToggleButton)

### Change the color of the chart
$script:AutoChart08ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart083DToggleButton.Location.X + $script:AutoChart083DToggleButton.Size.Width + 5
                   Y = $script:AutoChart083DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ColorsAvailable) { $script:AutoChart08ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08.Series["Enabled Accounts"].Color = $script:AutoChart08ChangeColorComboBox.SelectedItem
})
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart08ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'Enabled' -eq $($script:AutoChart08InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart08InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ImportCsvPosResults) { $script:AutoChart08InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart08TrimOffLastGroupBox.Location.X + $script:AutoChart08TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart08TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08CheckDiffButton
$script:AutoChart08CheckDiffButton.Add_Click({
    $script:AutoChart08InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'Enabled' -ExpandProperty 'Enabled' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart08InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart08InvestDiffDropDownLabel.Location.y + $script:AutoChart08InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08InvestDiffDropDownArray) { $script:AutoChart08InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:AutoChart08InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart08InvestDiffDropDownComboBox.Location.y + $script:AutoChart08InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart08InvestDiffExecuteButton
    $script:AutoChart08InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart08InvestDiffExecuteButton.Location.y + $script:AutoChart08InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart08InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart08InvestDiffPosResultsLabel.Location.y + $script:AutoChart08InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08InvestDiffPosResultsLabel.Location.x + $script:AutoChart08InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart08InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart08InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08InvestDiffNegResultsLabel.Location.y + $script:AutoChart08InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart08CheckDiffButton.Location.X + $script:AutoChart08CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart08CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "Enabled Accountses" -PropertyX "Enabled" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart08ExpandChartButton
$script:AutoChart08ManipulationPanel.Controls.Add($AutoChart08ExpandChartButton)


$script:AutoChart08OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08CheckDiffButton.Location.X
                   Y = $script:AutoChart08CheckDiffButton.Location.Y + $script:AutoChart08CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart08OpenInShell
$script:AutoChart08OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08OpenInShell)


$script:AutoChart08ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08OpenInShell.Location.X + $script:AutoChart08OpenInShell.Size.Width + 5
                   Y = $script:AutoChart08OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart08ViewResults
$script:AutoChart08ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08ViewResults)


### Save the chart to file
$script:AutoChart08SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08OpenInShell.Location.X
                  Y = $script:AutoChart08OpenInShell.Location.Y + $script:AutoChart08OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart08SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08 -Title $script:AutoChart08Title
})
$script:AutoChart08ManipulationPanel.controls.Add($script:AutoChart08SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08SaveButton.Location.X 
                        Y = $script:AutoChart08SaveButton.Location.Y + $script:AutoChart08SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ManipulationPanel.Controls.Add($script:AutoChart08NoticeTextbox)

$script:AutoChart08.Series["Enabled Accounts"].Points.Clear()
$script:AutoChart08OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}    


















##############################################################################################
# AutoChart09
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07.Location.X
                  Y = $script:AutoChart07.Location.Y + $script:AutoChart07.Size.Height + 20 }
    Size     = @{ Width  = 560
                  Height = 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
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
$script:AutoChart09.Series.Add("Locked Accounts")  
$script:AutoChart09.Series["Locked Accounts"].LockedOut           = $True
$script:AutoChart09.Series["Locked Accounts"].BorderWidth       = 1
$script:AutoChart09.Series["Locked Accounts"].IsVisibleInLegend = $false
$script:AutoChart09.Series["Locked Accounts"].Chartarea         = 'Chart Area'
$script:AutoChart09.Series["Locked Accounts"].Legend            = 'Legend'
$script:AutoChart09.Series["Locked Accounts"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09.Series["Locked Accounts"]['PieLineColor']   = 'Black'
$script:AutoChart09.Series["Locked Accounts"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09.Series["Locked Accounts"].ChartType         = 'Column'
$script:AutoChart09.Series["Locked Accounts"].Color             = 'Gray'

        function Generate-AutoChart09 {
            $script:AutoChart09CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart09UniqueDataFields  = $script:AutoChartDataSource | Select-Object LockedOut | Sort-Object LockedOut -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09.Series["Locked Accounts"].Points.Clear()

            if ($script:AutoChart09UniqueDataFields.count -gt 0){
                $script:AutoChart09Title.ForeColor = 'Black'
                $script:AutoChart09Title.Text = "Locked Accounts"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart09OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09UniqueDataFields) {
                    $Count = 0
                    $script:AutoChart09CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.LockedOut) -eq $DataField.LockedOut) {
                            $Count += 1
                            if ( $script:AutoChart09CsvComputers -notcontains $($Line.Name) ) { $script:AutoChart09CsvComputers += $($Line.Name) }                        
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
                $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount) }

                $script:AutoChart09TrimOffLastTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
                $script:AutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))
            }
            else {
                $script:AutoChart09Title.ForeColor = 'Red'
                $script:AutoChart09Title.Text = "Locked Accounts`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart09OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09.Location.X + 5
                   Y = $script:AutoChart09.Location.Y + 350 }
    Size      = @{ Width  = 75
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart09OptionsButton
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
                     Y = $script:AutoChart09.Size.Height - 121 }
    Size        = @{ Width  = $script:AutoChart09.Size.Width
                     Height = 121 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09OverallDataResults.count))                
    $script:AutoChart09TrimOffFirstTrackBarValue   = 0
    $script:AutoChart09TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09TrimOffFirstTrackBarValue = $script:AutoChart09TrimOffFirstTrackBar.Value
        $script:AutoChart09TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09TrimOffFirstTrackBar.Value)"
        $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}    
    })
    $script:AutoChart09TrimOffFirstGroupBox.Controls.Add($script:AutoChart09TrimOffFirstTrackBar)
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09TrimOffFirstGroupBox.Location.X + $script:AutoChart09TrimOffFirstGroupBox.Size.Width + 5
                     Y = $script:AutoChart09TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
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
        $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    })
$script:AutoChart09TrimOffLastGroupBox.Controls.Add($script:AutoChart09TrimOffLastTrackBar)
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart09TrimOffFirstGroupBox.Location.X + 80
                    Y = $script:AutoChart09TrimOffFirstGroupBox.Location.Y + $script:AutoChart09TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 85
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09.Series["Locked Accounts"].ChartType = $script:AutoChart09ChartTypeComboBox.SelectedItem
#    $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
#    $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
})
$script:AutoChart09ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ChartTypesAvailable) { $script:AutoChart09ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart093DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ChartTypeComboBox.Location.X + $script:AutoChart09ChartTypeComboBox.Size.Width + 8
                   Y = $script:AutoChart09ChartTypeComboBox.Location.Y }
    Size      = @{ Width  = 65
                   Height = 20 }
}
CommonButtonSettings -Button $script:AutoChart093DToggleButton
$script:AutoChart093DInclination = 0
$script:AutoChart093DToggleButton.Add_Click({
    $script:AutoChart093DInclination += 10
    if ( $script:AutoChart093DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart09Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart093DToggleButton.Text  = "3D On ($script:AutoChart093DInclination)"
#        $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart093DInclination -le 90 ) {
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart093DToggleButton.Text  = "3D On ($script:AutoChart093DInclination)" 
#        $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart093DToggleButton.Text  = "3D Off" 
        $script:AutoChart093DInclination = 0
        $script:AutoChart09Area.Area3DStyle.Inclination = $script:AutoChart093DInclination
        $script:AutoChart09Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
})
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart093DToggleButton)

### Change the color of the chart
$script:AutoChart09ChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart093DToggleButton.Location.X + $script:AutoChart093DToggleButton.Size.Width + 5
                   Y = $script:AutoChart093DToggleButton.Location.Y }
    Size      = @{ Width  = 95
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ColorsAvailable) { $script:AutoChart09ChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09.Series["Locked Accounts"].Color = $script:AutoChart09ChangeColorComboBox.SelectedItem
})
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart09ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'LockedOut' -eq $($script:AutoChart09InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart09InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ImportCsvPosResults) { $script:AutoChart09InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty Name -Unique
    
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
    Location  = @{ X = $script:AutoChart09TrimOffLastGroupBox.Location.X + $script:AutoChart09TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart09TrimOffLastGroupBox.Location.Y + 5  }
    Size      = @{ Width  = 100
                   Height = 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09CheckDiffButton
$script:AutoChart09CheckDiffButton.Add_Click({
    $script:AutoChart09InvestDiffDropDownArray = $script:AutoChartDataSource | Select-Object -Property 'LockedOut' -ExpandProperty 'LockedOut' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart09InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart09InvestDiffDropDownLabel.Location.y + $script:AutoChart09InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09InvestDiffDropDownArray) { $script:AutoChart09InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:AutoChart09InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart09InvestDiffDropDownComboBox.Location.y + $script:AutoChart09InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
    }
    CommonButtonSettings -Button $script:AutoChart09InvestDiffExecuteButton
    $script:AutoChart09InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart09InvestDiffExecuteButton.Location.y + $script:AutoChart09InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart09InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart09InvestDiffPosResultsLabel.Location.y + $script:AutoChart09InvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09InvestDiffPosResultsLabel.Location.x + $script:AutoChart09InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart09InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 100
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart09InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09InvestDiffNegResultsLabel.Location.y + $script:AutoChart09InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 100
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Location = @{ X = $script:AutoChart09CheckDiffButton.Location.X + $script:AutoChart09CheckDiffButton.Size.Width + 5
                  Y = $script:AutoChart09CheckDiffButton.Location.Y }
    Size   = @{ Width  = 100
                Height = 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Processes" -QueryTabName "Locked Accountses" -PropertyX "LockedOut" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart09ExpandChartButton
$script:AutoChart09ManipulationPanel.Controls.Add($AutoChart09ExpandChartButton)


$script:AutoChart09OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09CheckDiffButton.Location.X
                   Y = $script:AutoChart09CheckDiffButton.Location.Y + $script:AutoChart09CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart09OpenInShell
$script:AutoChart09OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09OpenInShell)


$script:AutoChart09ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09OpenInShell.Location.X + $script:AutoChart09OpenInShell.Size.Width + 5
                   Y = $script:AutoChart09OpenInShell.Location.Y }
    Size      = @{ Width  = 100
                   Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart09ViewResults
$script:AutoChart09ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09ViewResults)


### Save the chart to file
$script:AutoChart09SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09OpenInShell.Location.X
                  Y = $script:AutoChart09OpenInShell.Location.Y + $script:AutoChart09OpenInShell.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 23 }
}
CommonButtonSettings -Button $script:AutoChart09SaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09SaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09 -Title $script:AutoChart09Title
})
$script:AutoChart09ManipulationPanel.controls.Add($script:AutoChart09SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09SaveButton.Location.X 
                        Y = $script:AutoChart09SaveButton.Location.Y + $script:AutoChart09SaveButton.Size.Height + 6 }
    Size        = @{ Width  = 205
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09CsvFileHosts.Count)"
    Multiline   = $false
    LockedOut     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ManipulationPanel.Controls.Add($script:AutoChart09NoticeTextbox)

$script:AutoChart09.Series["Locked Accounts"].Points.Clear()
$script:AutoChart09OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}    
















