$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Security Patches'
    Size   = @{ Width  = $FormScale * 1700
                Height = $FormScale * 1050 }
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

$script:AutoChart01CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Security Patches') { $script:AutoChart01CSVFileMatch += $CSVFile } }
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
    Text   = 'Security Patches'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter' 
}

### Import select file to view information
$AutoChartSelectFileButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Select File To Analyze'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 200
                Height = $FormScale * 25 }
}
CommonButtonSettings -Button $AutoChartSelectFileButton
$script:AutoChartOpenResultsOpenFileDialogfilename = $null
$AutoChartSelectFileButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $AutoChartOpenResultsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $AutoChartOpenResultsOpenFileDialog.Title            = "Open XML Data"
    $AutoChartOpenResultsOpenFileDialog.InitialDirectorY = $FormScale * "$(if (Test-Path $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
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
+  Select a file to view Security Patches data.
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
$script:AutoChart01.Series.Add("Security Patches")
$script:AutoChart01.Series["Security Patches"].Enabled           = $True
$script:AutoChart01.Series["Security Patches"].BorderWidth       = 1
$script:AutoChart01.Series["Security Patches"].IsVisibleInLegend = $false
$script:AutoChart01.Series["Security Patches"].Chartarea         = 'Chart Area'
$script:AutoChart01.Series["Security Patches"].Legend            = 'Legend'
$script:AutoChart01.Series["Security Patches"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01.Series["Security Patches"]['PieLineColor']   = 'Black'
$script:AutoChart01.Series["Security Patches"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01.Series["Security Patches"].ChartType         = 'Column'
$script:AutoChart01.Series["Security Patches"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01UniqueDataFields  = $script:AutoChartDataSource | Select-Object -Property 'HotFixID' | Sort-Object -Property 'HotFixID' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01.Series["Security Patches"].Points.Clear()

            if ($script:AutoChart01UniqueDataFields.count -gt 0){
                $script:AutoChart01Title.ForeColor = 'Black'
                $script:AutoChart01Title.Text = "Security Patches"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.HotFixID) -eq $DataField.HotFixID) {
                            $Count += 1
                            if ( $script:AutoChart01CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01CsvComputers += $($Line.PSComputerName) }
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
                $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount) }
                $script:AutoChart01TrimOffLastTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
                $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
            }
            else {
                $script:AutoChart01Title.ForeColor = 'Red'
                $script:AutoChart01Title.Text = "Security Patches`n
[ No Data Available ]`n"                
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
        $script:AutoChart01.Series["Security Patches"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
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
        $script:AutoChart01.Series["Security Patches"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
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
    $script:AutoChart01.Series["Security Patches"].ChartType = $script:AutoChart01ChartTypeComboBox.SelectedItem
#    $script:AutoChart01.Series["Security Patches"].Points.Clear()
#    $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
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
CommonButtonSettings -Button $script:AutoChart013DToggleButton
$script:AutoChart013DInclination = 0
$script:AutoChart013DToggleButton.Add_Click({
    
    $script:AutoChart013DInclination += 10
    if ( $script:AutoChart013DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)"
#        $script:AutoChart01.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart013DInclination -le 90 ) {
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)" 
#        $script:AutoChart01.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart013DToggleButton.Text  = "3D Off" 
        $script:AutoChart013DInclination = 0
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
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
    $script:AutoChart01.Series["Security Patches"].Color = $script:AutoChart01ChangeColorComboBox.SelectedItem
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'HotFixID' -eq $($script:AutoChart01InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
CommonButtonSettings -Button $script:AutoChart01CheckDiffButton
$script:AutoChart01CheckDiffButton.Add_Click({
    $script:AutoChart01InvestDiffDropDownArraY = $script:AutoChartDataSource | Select-Object -Property 'HotFixID' -ExpandProperty 'HotFixID' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    CommonButtonSettings -Button $script:AutoChart01InvestDiffExecuteButton
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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Security Patches" -QueryTabName "Security Patches" -PropertyX "HotFixID" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01ManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01CheckDiffButton.Location.X
                   Y = $script:AutoChart01CheckDiffButton.Location.Y + $script:AutoChart01CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01OpenInShell
$script:AutoChart01OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01OpenInShell)


$script:AutoChart01ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01OpenInShell.Location.X + $script:AutoChart01OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ViewResults
$script:AutoChart01ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01ViewResults)


### Save the chart to file
$script:AutoChart01SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01OpenInShell.Location.X
                  Y = $script:AutoChart01OpenInShell.Location.Y + $script:AutoChart01OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
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

$script:AutoChart01.Series["Security Patches"].Points.Clear()
$script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}























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
$script:AutoChart02.Series.Add("Security Patches Per Host")  
$script:AutoChart02.Series["Security Patches Per Host"].Enabled           = $True
$script:AutoChart02.Series["Security Patches Per Host"].BorderWidth       = 1
$script:AutoChart02.Series["Security Patches Per Host"].IsVisibleInLegend = $false
$script:AutoChart02.Series["Security Patches Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02.Series["Security Patches Per Host"].Legend            = 'Legend'
$script:AutoChart02.Series["Security Patches Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02.Series["Security Patches Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02.Series["Security Patches Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02.Series["Security Patches Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02.Series["Security Patches Per Host"].Color             = 'Blue'
        
        function Generate-AutoChart02 {
            $script:AutoChart02CsvFileHosts     = ($script:AutoChartDataSource).PSComputerName | Sort-Object -Unique
            $script:AutoChart02UniqueDataFields = ($script:AutoChartDataSource).HotFixID | Sort-Object -Property 'HotFixID'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02UniqueDataFields.count -gt 0){
                $script:AutoChart02Title.ForeColor = 'Black'
                $script:AutoChart02Title.Text = "Security Patches Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02OverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSource | Sort-Object PSComputerName) ) {
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.PSComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $Line.HotFixID ) {
                                if ( $Line.HotFixID -ne "" ) { $AutoChart02YResults += $Line.HotFixID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart02CurrentComputer ) { 
                            $AutoChart02CurrentComputer = $Line.PSComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer 
                            }
                            $script:AutoChart02OverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $Line.HotFixID ) {
                                if ( $Line.HotFixID -ne "" ) { $AutoChart02YResults += $Line.HotFixID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }    
                $script:AutoChart02OverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02OverallDataResults | ForEach-Object { $script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02TrimOffLastTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
                $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
            }
            else {
                $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart02Title.ForeColor = 'Red'
                $script:AutoChart02Title.Text = "Security Patches Per Host`n
[ No Data Available ]`n"                
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
        $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
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
        $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
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
    $script:AutoChart02.Series["Security Patches Per Host"].ChartType = $script:AutoChart02ChartTypeComboBox.SelectedItem
#    $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
#    $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
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
CommonButtonSettings -Button $script:AutoChart023DToggleButton
$script:AutoChart023DInclination = 0
$script:AutoChart023DToggleButton.Add_Click({
    $script:AutoChart023DInclination += 10
    if ( $script:AutoChart023DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)"
#        $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart023DInclination -le 90 ) {
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)" 
#        $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart023DToggleButton.Text  = "3D Off" 
        $script:AutoChart023DInclination = 0
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
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
    $script:AutoChart02.Series["Security Patches Per Host"].Color = $script:AutoChart02ChangeColorComboBox.SelectedItem
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'Name' -eq $($script:AutoChart02InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
CommonButtonSettings -Button $script:AutoChart02CheckDiffButton
$script:AutoChart02CheckDiffButton.Add_Click({
    $script:AutoChart02InvestDiffDropDownArraY = $script:AutoChartDataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    CommonButtonSettings -Button $script:AutoChart02InvestDiffExecuteButton
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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Security Patches" -QueryTabName "Security Patches Per Host" -PropertyX "PSComputerName" -PropertyY "HotFixID" }
}
CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02ManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02CheckDiffButton.Location.X
                   Y = $script:AutoChart02CheckDiffButton.Location.Y + $script:AutoChart02CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02OpenInShell
$script:AutoChart02OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02OpenInShell)


$script:AutoChart02ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02OpenInShell.Location.X + $script:AutoChart02OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ViewResults
$script:AutoChart02ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02ViewResults)


### Save the chart to file
$script:AutoChart02SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02OpenInShell.Location.X
                  Y = $script:AutoChart02OpenInShell.Location.Y + $script:AutoChart02OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
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

$script:AutoChart02.Series["Security Patches Per Host"].Points.Clear()
$script:AutoChart02OverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

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
$script:AutoChart03.Series.Add("Service Pack In Effect")  
$script:AutoChart03.Series["Service Pack In Effect"].Enabled           = $True
$script:AutoChart03.Series["Service Pack In Effect"].BorderWidth       = 1
$script:AutoChart03.Series["Service Pack In Effect"].IsVisibleInLegend = $false
$script:AutoChart03.Series["Service Pack In Effect"].Chartarea         = 'Chart Area'
$script:AutoChart03.Series["Service Pack In Effect"].Legend            = 'Legend'
$script:AutoChart03.Series["Service Pack In Effect"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03.Series["Service Pack In Effect"]['PieLineColor']   = 'Black'
$script:AutoChart03.Series["Service Pack In Effect"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03.Series["Service Pack In Effect"].ChartType         = 'Column'
$script:AutoChart03.Series["Service Pack In Effect"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03UniqueDataFields  = $script:AutoChartDataSource | Select-Object -Property 'ServicePackInEffect' | Sort-Object -Property 'ServicePackInEffect' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()

            if ($script:AutoChart03UniqueDataFields.count -gt 0){
                $script:AutoChart03Title.ForeColor = 'Black'
                $script:AutoChart03Title.Text = "Service Pack In Effect"
                
                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($Line.ServicePackInEffect -eq $DataField.ServicePackInEffect) {
                            $Count += 1
                            if ( $script:AutoChart03CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03CsvComputers += $($Line.PSComputerName) }                        
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
                $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount) }

                $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
                $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
            }
            else {
                $script:AutoChart03Title.ForeColor = 'Red'
                $script:AutoChart03Title.Text = "Service Pack In Effect`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
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
        $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}    
    })
    $script:AutoChart03TrimOffFirstGroupBox.Controls.Add($script:AutoChart03TrimOffFirstTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + $script:AutoChart03TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
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
    $script:AutoChart03TrimOffLastTrackBarValue   = 0
    $script:AutoChart03TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffLastTrackBarValue = $($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value
        $script:AutoChart03TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value)"
        $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
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
    $script:AutoChart03.Series["Service Pack In Effect"].ChartType = $script:AutoChart03ChartTypeComboBox.SelectedItem
#    $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
#    $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
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
CommonButtonSettings -Button $script:AutoChart033DToggleButton
$script:AutoChart033DInclination = 0
$script:AutoChart033DToggleButton.Add_Click({
    $script:AutoChart033DInclination += 10
    if ( $script:AutoChart033DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)"
#        $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart033DInclination -le 90 ) {
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)" 
#        $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart033DToggleButton.Text  = "3D Off" 
        $script:AutoChart033DInclination = 0
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
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
    $script:AutoChart03.Series["Service Pack In Effect"].Color = $script:AutoChart03ChangeColorComboBox.SelectedItem
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'ServicePackInEffect' -eq $($script:AutoChart03InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
}
CommonButtonSettings -Button $script:AutoChart03CheckDiffButton
$script:AutoChart03CheckDiffButton.Add_Click({
    $script:AutoChart03InvestDiffDropDownArraY = $script:AutoChartDataSource | Select-Object -Property 'ServicePackInEffect' -ExpandProperty 'ServicePackInEffect' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    $script:AutoChart03InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03InvestDiffDropDownComboBox.Location.y + $script:AutoChart03InvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03InvestDiffExecuteButton
    $script:AutoChart03InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

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
    

$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03CheckDiffButton.Location.X + $script:AutoChart03CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Security Patches" -QueryTabName "Service Pack In Effect" -PropertyX "ServicePackInEffect" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03ManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03CheckDiffButton.Location.X
                   Y = $script:AutoChart03CheckDiffButton.Location.Y + $script:AutoChart03CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03OpenInShell
$script:AutoChart03OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03OpenInShell)


$script:AutoChart03ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03OpenInShell.Location.X + $script:AutoChart03OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ViewResults
$script:AutoChart03ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03ViewResults)


### Save the chart to file
$script:AutoChart03SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03OpenInShell.Location.X
                  Y = $script:AutoChart03OpenInShell.Location.Y + $script:AutoChart03OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
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

$script:AutoChart03.Series["Service Pack In Effect"].Points.Clear()
$script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}    





















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
$script:AutoChart04.Series.Add("Install Date")  
$script:AutoChart04.Series["Install Date"].Enabled           = $True
$script:AutoChart04.Series["Install Date"].BorderWidth       = 1
$script:AutoChart04.Series["Install Date"].IsVisibleInLegend = $false
$script:AutoChart04.Series["Install Date"].Chartarea         = 'Chart Area'
$script:AutoChart04.Series["Install Date"].Legend            = 'Legend'
$script:AutoChart04.Series["Install Date"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04.Series["Install Date"]['PieLineColor']   = 'Black'
$script:AutoChart04.Series["Install Date"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04.Series["Install Date"].ChartType         = 'Column'
$script:AutoChart04.Series["Install Date"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04CsvFileHosts      = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04UniqueDataFields  = $script:AutoChartDataSource | Select-Object -Property 'InstalledOn' | Sort-Object -Property 'InstalledOn' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04UniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04.Series["Install Date"].Points.Clear()

            if ($script:AutoChart04UniqueDataFields.count -gt 0){
                $script:AutoChart04Title.ForeColor = 'Black'
                $script:AutoChart04Title.Text = "Install Date"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04OverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04UniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04CsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSource ) {
                        if ($($Line.InstalledOn) -eq $DataField.InstalledOn) {
                            $Count += 1
                            if ( $script:AutoChart04CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04CsvComputers += $($Line.PSComputerName) }                        
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
                $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount) }

                $script:AutoChart04TrimOffLastTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
                $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
            }
            else {
                $script:AutoChart04Title.ForeColor = 'Red'
                $script:AutoChart04Title.Text = "Install Date`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
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
        $script:AutoChart04.Series["Install Date"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}    
    })
    $script:AutoChart04TrimOffFirstGroupBox.Controls.Add($script:AutoChart04TrimOffFirstTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04TrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + $script:AutoChart04TrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
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
        $script:AutoChart04.Series["Install Date"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
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
    $script:AutoChart04.Series["Install Date"].ChartType = $script:AutoChart04ChartTypeComboBox.SelectedItem
#    $script:AutoChart04.Series["Install Date"].Points.Clear()
#    $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
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
CommonButtonSettings -Button $script:AutoChart043DToggleButton
$script:AutoChart043DInclination = 0
$script:AutoChart043DToggleButton.Add_Click({
    $script:AutoChart043DInclination += 10
    if ( $script:AutoChart043DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)"
#        $script:AutoChart04.Series["Install Date"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart043DInclination -le 90 ) {
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)" 
#        $script:AutoChart04.Series["Install Date"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart043DToggleButton.Text  = "3D Off" 
        $script:AutoChart043DInclination = 0
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04.Series["Install Date"].Points.Clear()
#        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
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
    $script:AutoChart04.Series["Install Date"].Color = $script:AutoChart04ChangeColorComboBox.SelectedItem
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04ImportCsvPosResults = $script:AutoChartDataSource | Where-Object 'InstalledOn' -eq $($script:AutoChart04InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ImportCsvAll = $script:AutoChartDataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
CommonButtonSettings -Button $script:AutoChart04CheckDiffButton
$script:AutoChart04CheckDiffButton.Add_Click({
    $script:AutoChart04InvestDiffDropDownArraY = $script:AutoChartDataSource | Select-Object -Property 'InstalledOn' -ExpandProperty 'InstalledOn' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    CommonButtonSettings -Button $script:AutoChart04InvestDiffExecuteButton 
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
    

$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04CheckDiffButton.Location.X + $script:AutoChart04CheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04CheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceFileName -QueryName "Security Patches" -QueryTabName "Install Date" -PropertyX "InstalledOn" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04ManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04OpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04CheckDiffButton.Location.X
                   Y = $script:AutoChart04CheckDiffButton.Location.Y + $script:AutoChart04CheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04OpenInShell
$script:AutoChart04OpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04OpenInShell)


$script:AutoChart04ViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04OpenInShell.Location.X + $script:AutoChart04OpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04OpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ViewResults
$script:AutoChart04ViewResults.Add_Click({ $script:AutoChartDataSource | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04ViewResults)


### Save the chart to file
$script:AutoChart04SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04OpenInShell.Location.X
                  Y = $script:AutoChart04OpenInShell.Location.Y + $script:AutoChart04OpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
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

$script:AutoChart04.Series["Install Date"].Points.Clear()
$script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}    





