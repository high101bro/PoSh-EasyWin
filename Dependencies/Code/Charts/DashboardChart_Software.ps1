$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Software Info  '
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

$script:AutoChart01SoftwareCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Software') { $script:AutoChart01SoftwareCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01SoftwareCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsvSoftware = $null
$script:AutoChartDataSourceCsvSoftware = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01SoftwareOptionsButton.Text = 'Options v'
    $script:AutoChart01Software.Controls.Remove($script:AutoChart01SoftwareManipulationPanel)
    $script:AutoChart02SoftwareOptionsButton.Text = 'Options v'
    $script:AutoChart02Software.Controls.Remove($script:AutoChart02SoftwareManipulationPanel)
    $script:AutoChart03SoftwareOptionsButton.Text = 'Options v'
    $script:AutoChart03Software.Controls.Remove($script:AutoChart03SoftwareManipulationPanel)
    $script:AutoChart04SoftwareOptionsButton.Text = 'Options v'
    $script:AutoChart04Software.Controls.Remove($script:AutoChart04SoftwareManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Installed Software Info'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
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


















##############################################################################################
# AutoChart01
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01Software = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01Software.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01SoftwareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01Software.Titles.Add($script:AutoChart01SoftwareTitle)

### Create Charts Area
$script:AutoChart01SoftwareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01SoftwareArea.Name        = 'Chart Area'
$script:AutoChart01SoftwareArea.AxisX.Title = 'Hosts'
$script:AutoChart01SoftwareArea.AxisX.Interval          = 1
$script:AutoChart01SoftwareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01SoftwareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01SoftwareArea.Area3DStyle.Inclination = 75
$script:AutoChart01Software.ChartAreas.Add($script:AutoChart01SoftwareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01Software.Series.Add("Software Names")
$script:AutoChart01Software.Series["Software Names"].Enabled           = $True
$script:AutoChart01Software.Series["Software Names"].BorderWidth       = 1
$script:AutoChart01Software.Series["Software Names"].IsVisibleInLegend = $false
$script:AutoChart01Software.Series["Software Names"].Chartarea         = 'Chart Area'
$script:AutoChart01Software.Series["Software Names"].Legend            = 'Legend'
$script:AutoChart01Software.Series["Software Names"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01Software.Series["Software Names"]['PieLineColor']   = 'Black'
$script:AutoChart01Software.Series["Software Names"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01Software.Series["Software Names"].ChartType         = 'Column'
$script:AutoChart01Software.Series["Software Names"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01SoftwareCsvFileHosts      = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01SoftwareUniqueDataFields  = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01SoftwareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01Software.Series["Software Names"].Points.Clear()

            if ($script:AutoChart01SoftwareUniqueDataFields.count -gt 0){
                $script:AutoChart01SoftwareTitle.ForeColor = 'Black'
                $script:AutoChart01SoftwareTitle.Text = "Software Names"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01SoftwareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01SoftwareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01SoftwareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSoftware ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01SoftwareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01SoftwareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01SoftwareUniqueCount = $script:AutoChart01SoftwareCsvComputers.Count
                    $script:AutoChart01SoftwareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01SoftwareUniqueCount
                        Computers   = $script:AutoChart01SoftwareCsvComputers
                    }
                    $script:AutoChart01SoftwareOverallDataResults += $script:AutoChart01SoftwareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SoftwareOverallDataResults.count))
                $script:AutoChart01SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SoftwareOverallDataResults.count))
            }
            else {
                $script:AutoChart01SoftwareTitle.ForeColor = 'Red'
                $script:AutoChart01SoftwareTitle.Text = "Software Names`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01SoftwareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01Software.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01Software.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareOptionsButton
$script:AutoChart01SoftwareOptionsButton.Add_Click({
    if ($script:AutoChart01SoftwareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01SoftwareOptionsButton.Text = 'Options ^'
        $script:AutoChart01Software.Controls.Add($script:AutoChart01SoftwareManipulationPanel)
    }
    elseif ($script:AutoChart01SoftwareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01SoftwareOptionsButton.Text = 'Options v'
        $script:AutoChart01Software.Controls.Remove($script:AutoChart01SoftwareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01SoftwareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01Software)


$script:AutoChart01SoftwareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01Software.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01Software.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01SoftwareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01SoftwareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SoftwareOverallDataResults.count))
    $script:AutoChart01SoftwareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01SoftwareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01SoftwareTrimOffFirstTrackBarValue = $script:AutoChart01SoftwareTrimOffFirstTrackBar.Value
        $script:AutoChart01SoftwareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01SoftwareTrimOffFirstTrackBar.Value)"
        $script:AutoChart01Software.Series["Software Names"].Points.Clear()
        $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01SoftwareTrimOffFirstGroupBox.Controls.Add($script:AutoChart01SoftwareTrimOffFirstTrackBar)
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01SoftwareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01SoftwareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01SoftwareTrimOffFirstGroupBox.Location.X + $script:AutoChart01SoftwareTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01SoftwareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01SoftwareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01SoftwareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SoftwareOverallDataResults.count))
    $script:AutoChart01SoftwareTrimOffLastTrackBar.Value         = $($script:AutoChart01SoftwareOverallDataResults.count)
    $script:AutoChart01SoftwareTrimOffLastTrackBarValue   = 0
    $script:AutoChart01SoftwareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01SoftwareTrimOffLastTrackBarValue = $($script:AutoChart01SoftwareOverallDataResults.count) - $script:AutoChart01SoftwareTrimOffLastTrackBar.Value
        $script:AutoChart01SoftwareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01SoftwareOverallDataResults.count) - $script:AutoChart01SoftwareTrimOffLastTrackBar.Value)"
        $script:AutoChart01Software.Series["Software Names"].Points.Clear()
        $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01SoftwareTrimOffLastGroupBox.Controls.Add($script:AutoChart01SoftwareTrimOffLastTrackBar)
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01SoftwareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01SoftwareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01SoftwareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01SoftwareTrimOffFirstGroupBox.Location.Y + $script:AutoChart01SoftwareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SoftwareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Software.Series["Software Names"].ChartType = $script:AutoChart01SoftwareChartTypeComboBox.SelectedItem
#    $script:AutoChart01Software.Series["Software Names"].Points.Clear()
#    $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01SoftwareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01SoftwareChartTypesAvailable) { $script:AutoChart01SoftwareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01SoftwareChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01Software3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01SoftwareChartTypeComboBox.Location.X + $script:AutoChart01SoftwareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01SoftwareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01Software3DToggleButton
$script:AutoChart01Software3DInclination = 0
$script:AutoChart01Software3DToggleButton.Add_Click({

    $script:AutoChart01Software3DInclination += 10
    if ( $script:AutoChart01Software3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01SoftwareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01SoftwareArea.Area3DStyle.Inclination = $script:AutoChart01Software3DInclination
        $script:AutoChart01Software3DToggleButton.Text  = "3D On ($script:AutoChart01Software3DInclination)"
#        $script:AutoChart01Software.Series["Software Names"].Points.Clear()
#        $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01Software3DInclination -le 90 ) {
        $script:AutoChart01SoftwareArea.Area3DStyle.Inclination = $script:AutoChart01Software3DInclination
        $script:AutoChart01Software3DToggleButton.Text  = "3D On ($script:AutoChart01Software3DInclination)"
#        $script:AutoChart01Software.Series["Software Names"].Points.Clear()
#        $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01Software3DToggleButton.Text  = "3D Off"
        $script:AutoChart01Software3DInclination = 0
        $script:AutoChart01SoftwareArea.Area3DStyle.Inclination = $script:AutoChart01Software3DInclination
        $script:AutoChart01SoftwareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01Software.Series["Software Names"].Points.Clear()
#        $script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01Software3DToggleButton)

### Change the color of the chart
$script:AutoChart01SoftwareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01Software3DToggleButton.Location.X + $script:AutoChart01Software3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01Software3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SoftwareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01SoftwareColorsAvailable) { $script:AutoChart01SoftwareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01SoftwareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Software.Series["Software Names"].Color = $script:AutoChart01SoftwareChangeColorComboBox.SelectedItem
})
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01SoftwareChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01SoftwareImportCsvPosResults = $script:AutoChartDataSourceCsvSoftware | Where-Object 'Name' -eq $($script:AutoChart01SoftwareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01SoftwareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SoftwareImportCsvPosResults) { $script:AutoChart01SoftwareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01SoftwareImportCsvAll = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01SoftwareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01SoftwareImportCsvAll) { if ($Endpoint -notin $script:AutoChart01SoftwareImportCsvPosResults) { $script:AutoChart01SoftwareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01SoftwareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SoftwareImportCsvNegResults) { $script:AutoChart01SoftwareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01SoftwareImportCsvPosResults.count))"
    $script:AutoChart01SoftwareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01SoftwareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01SoftwareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01SoftwareTrimOffLastGroupBox.Location.X + $script:AutoChart01SoftwareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SoftwareTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareCheckDiffButton
$script:AutoChart01SoftwareCheckDiffButton.Add_Click({
    $script:AutoChart01SoftwareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01SoftwareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01SoftwareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SoftwareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SoftwareInvestDiffDropDownLabel.Location.y + $script:AutoChart01SoftwareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01SoftwareInvestDiffDropDownArray) { $script:AutoChart01SoftwareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01SoftwareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SoftwareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01SoftwareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SoftwareInvestDiffDropDownComboBox.Location.y + $script:AutoChart01SoftwareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareInvestDiffExecuteButton
    $script:AutoChart01SoftwareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SoftwareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01SoftwareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SoftwareInvestDiffExecuteButton.Location.y + $script:AutoChart01SoftwareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SoftwareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Location.y + $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01SoftwareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Location.x + $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01SoftwareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SoftwareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01SoftwareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01SoftwareInvestDiffNegResultsLabel.Location.y + $script:AutoChart01SoftwareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01SoftwareInvestDiffForm.Controls.AddRange(@($script:AutoChart01SoftwareInvestDiffDropDownLabel,$script:AutoChart01SoftwareInvestDiffDropDownComboBox,$script:AutoChart01SoftwareInvestDiffExecuteButton,$script:AutoChart01SoftwareInvestDiffPosResultsLabel,$script:AutoChart01SoftwareInvestDiffPosResultsTextBox,$script:AutoChart01SoftwareInvestDiffNegResultsLabel,$script:AutoChart01SoftwareInvestDiffNegResultsTextBox))
    $script:AutoChart01SoftwareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01SoftwareInvestDiffForm.ShowDialog()
})
$script:AutoChart01SoftwareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01SoftwareManipulationPanel.controls.Add($script:AutoChart01SoftwareCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01SoftwareCheckDiffButton.Location.X + $script:AutoChart01SoftwareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01SoftwareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSoftwareFileName -QueryName "Software" -QueryTabName "Software Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01SoftwareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01SoftwareCheckDiffButton.Location.X
                   Y = $script:AutoChart01SoftwareCheckDiffButton.Location.Y + $script:AutoChart01SoftwareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareOpenInShell
$script:AutoChart01SoftwareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01SoftwareManipulationPanel.controls.Add($script:AutoChart01SoftwareOpenInShell)


$script:AutoChart01SoftwareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01SoftwareOpenInShell.Location.X + $script:AutoChart01SoftwareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SoftwareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareViewResults
$script:AutoChart01SoftwareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSoftware | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01SoftwareManipulationPanel.controls.Add($script:AutoChart01SoftwareViewResults)


### Save the chart to file
$script:AutoChart01SoftwareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01SoftwareOpenInShell.Location.X
                  Y = $script:AutoChart01SoftwareOpenInShell.Location.Y + $script:AutoChart01SoftwareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SoftwareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SoftwareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01Software -Title $script:AutoChart01SoftwareTitle
})
$script:AutoChart01SoftwareManipulationPanel.controls.Add($script:AutoChart01SoftwareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01SoftwareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SoftwareSaveButton.Location.X
                        Y = $script:AutoChart01SoftwareSaveButton.Location.Y + $script:AutoChart01SoftwareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01SoftwareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01SoftwareManipulationPanel.Controls.Add($script:AutoChart01SoftwareNoticeTextbox)

$script:AutoChart01Software.Series["Software Names"].Points.Clear()
$script:AutoChart01SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Software.Series["Software Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02Software = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Software.Location.X + $script:AutoChart01Software.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01Software.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02Software.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02SoftwareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02Software.Titles.Add($script:AutoChart02SoftwareTitle)

### Create Charts Area
$script:AutoChart02SoftwareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02SoftwareArea.Name        = 'Chart Area'
$script:AutoChart02SoftwareArea.AxisX.Title = 'Hosts'
$script:AutoChart02SoftwareArea.AxisX.Interval          = 1
$script:AutoChart02SoftwareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02SoftwareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02SoftwareArea.Area3DStyle.Inclination = 75
$script:AutoChart02Software.ChartAreas.Add($script:AutoChart02SoftwareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02Software.Series.Add("Software Count Per Host")
$script:AutoChart02Software.Series["Software Count Per Host"].Enabled           = $True
$script:AutoChart02Software.Series["Software Count Per Host"].BorderWidth       = 1
$script:AutoChart02Software.Series["Software Count Per Host"].IsVisibleInLegend = $false
$script:AutoChart02Software.Series["Software Count Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02Software.Series["Software Count Per Host"].Legend            = 'Legend'
$script:AutoChart02Software.Series["Software Count Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02Software.Series["Software Count Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02Software.Series["Software Count Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02Software.Series["Software Count Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02Software.Series["Software Count Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02SoftwareCsvFileHosts     = ($script:AutoChartDataSourceCsvSoftware).PSComputerName | Sort-Object -Unique
            $script:AutoChart02SoftwareUniqueDataFields = ($script:AutoChartDataSourceCsvSoftware).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02SoftwareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02SoftwareUniqueDataFields.count -gt 0){
                $script:AutoChart02SoftwareTitle.ForeColor = 'Black'
                $script:AutoChart02SoftwareTitle.Text = "Software Count Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02SoftwareOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvSoftware | Sort-Object PSComputerName) ) {
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
                            $script:AutoChart02SoftwareOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02SoftwareOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02SoftwareOverallDataResults | ForEach-Object { $script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
                $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SoftwareOverallDataResults.count))
                $script:AutoChart02SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SoftwareOverallDataResults.count))
            }
            else {
                $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
                $script:AutoChart02SoftwareTitle.ForeColor = 'Red'
                $script:AutoChart02SoftwareTitle.Text = "Software Count Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02SoftwareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02Software.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02Software.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareOptionsButton
$script:AutoChart02SoftwareOptionsButton.Add_Click({
    if ($script:AutoChart02SoftwareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02SoftwareOptionsButton.Text = 'Options ^'
        $script:AutoChart02Software.Controls.Add($script:AutoChart02SoftwareManipulationPanel)
    }
    elseif ($script:AutoChart02SoftwareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02SoftwareOptionsButton.Text = 'Options v'
        $script:AutoChart02Software.Controls.Remove($script:AutoChart02SoftwareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02SoftwareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02Software)

$script:AutoChart02SoftwareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02Software.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02Software.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02SoftwareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02SoftwareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SoftwareOverallDataResults.count))
    $script:AutoChart02SoftwareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02SoftwareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02SoftwareTrimOffFirstTrackBarValue = $script:AutoChart02SoftwareTrimOffFirstTrackBar.Value
        $script:AutoChart02SoftwareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02SoftwareTrimOffFirstTrackBar.Value)"
        $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
        $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02SoftwareTrimOffFirstGroupBox.Controls.Add($script:AutoChart02SoftwareTrimOffFirstTrackBar)
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02SoftwareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02SoftwareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02SoftwareTrimOffFirstGroupBox.Location.X + $script:AutoChart02SoftwareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02SoftwareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02SoftwareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02SoftwareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SoftwareOverallDataResults.count))
    $script:AutoChart02SoftwareTrimOffLastTrackBar.Value         = $($script:AutoChart02SoftwareOverallDataResults.count)
    $script:AutoChart02SoftwareTrimOffLastTrackBarValue   = 0
    $script:AutoChart02SoftwareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02SoftwareTrimOffLastTrackBarValue = $($script:AutoChart02SoftwareOverallDataResults.count) - $script:AutoChart02SoftwareTrimOffLastTrackBar.Value
        $script:AutoChart02SoftwareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02SoftwareOverallDataResults.count) - $script:AutoChart02SoftwareTrimOffLastTrackBar.Value)"
        $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
        $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02SoftwareTrimOffLastGroupBox.Controls.Add($script:AutoChart02SoftwareTrimOffLastTrackBar)
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02SoftwareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02SoftwareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02SoftwareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02SoftwareTrimOffFirstGroupBox.Location.Y + $script:AutoChart02SoftwareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SoftwareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Software.Series["Software Count Per Host"].ChartType = $script:AutoChart02SoftwareChartTypeComboBox.SelectedItem
#    $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
#    $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02SoftwareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02SoftwareChartTypesAvailable) { $script:AutoChart02SoftwareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02SoftwareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02Software3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02SoftwareChartTypeComboBox.Location.X + $script:AutoChart02SoftwareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02SoftwareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02Software3DToggleButton
$script:AutoChart02Software3DInclination = 0
$script:AutoChart02Software3DToggleButton.Add_Click({
    $script:AutoChart02Software3DInclination += 10
    if ( $script:AutoChart02Software3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02SoftwareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02SoftwareArea.Area3DStyle.Inclination = $script:AutoChart02Software3DInclination
        $script:AutoChart02Software3DToggleButton.Text  = "3D On ($script:AutoChart02Software3DInclination)"
#        $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02Software3DInclination -le 90 ) {
        $script:AutoChart02SoftwareArea.Area3DStyle.Inclination = $script:AutoChart02Software3DInclination
        $script:AutoChart02Software3DToggleButton.Text  = "3D On ($script:AutoChart02Software3DInclination)"
#        $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02Software3DToggleButton.Text  = "3D Off"
        $script:AutoChart02Software3DInclination = 0
        $script:AutoChart02SoftwareArea.Area3DStyle.Inclination = $script:AutoChart02Software3DInclination
        $script:AutoChart02SoftwareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
#        $script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02Software3DToggleButton)

### Change the color of the chart
$script:AutoChart02SoftwareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02Software3DToggleButton.Location.X + $script:AutoChart02Software3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02Software3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SoftwareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02SoftwareColorsAvailable) { $script:AutoChart02SoftwareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02SoftwareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Software.Series["Software Count Per Host"].Color = $script:AutoChart02SoftwareChangeColorComboBox.SelectedItem
})
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02SoftwareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02SoftwareImportCsvPosResults = $script:AutoChartDataSourceCsvSoftware | Where-Object 'Name' -eq $($script:AutoChart02SoftwareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02SoftwareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SoftwareImportCsvPosResults) { $script:AutoChart02SoftwareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02SoftwareImportCsvAll = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02SoftwareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02SoftwareImportCsvAll) { if ($Endpoint -notin $script:AutoChart02SoftwareImportCsvPosResults) { $script:AutoChart02SoftwareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02SoftwareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SoftwareImportCsvNegResults) { $script:AutoChart02SoftwareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02SoftwareImportCsvPosResults.count))"
    $script:AutoChart02SoftwareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02SoftwareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02SoftwareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02SoftwareTrimOffLastGroupBox.Location.X + $script:AutoChart02SoftwareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SoftwareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareCheckDiffButton
$script:AutoChart02SoftwareCheckDiffButton.Add_Click({
    $script:AutoChart02SoftwareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02SoftwareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02SoftwareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SoftwareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SoftwareInvestDiffDropDownLabel.Location.y + $script:AutoChart02SoftwareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02SoftwareInvestDiffDropDownArray) { $script:AutoChart02SoftwareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02SoftwareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SoftwareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02SoftwareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SoftwareInvestDiffDropDownComboBox.Location.y + $script:AutoChart02SoftwareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareInvestDiffExecuteButton
    $script:AutoChart02SoftwareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SoftwareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02SoftwareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SoftwareInvestDiffExecuteButton.Location.y + $script:AutoChart02SoftwareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SoftwareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Location.y + $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02SoftwareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Location.x + $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02SoftwareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SoftwareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02SoftwareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02SoftwareInvestDiffNegResultsLabel.Location.y + $script:AutoChart02SoftwareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02SoftwareInvestDiffForm.Controls.AddRange(@($script:AutoChart02SoftwareInvestDiffDropDownLabel,$script:AutoChart02SoftwareInvestDiffDropDownComboBox,$script:AutoChart02SoftwareInvestDiffExecuteButton,$script:AutoChart02SoftwareInvestDiffPosResultsLabel,$script:AutoChart02SoftwareInvestDiffPosResultsTextBox,$script:AutoChart02SoftwareInvestDiffNegResultsLabel,$script:AutoChart02SoftwareInvestDiffNegResultsTextBox))
    $script:AutoChart02SoftwareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02SoftwareInvestDiffForm.ShowDialog()
})
$script:AutoChart02SoftwareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02SoftwareManipulationPanel.controls.Add($script:AutoChart02SoftwareCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02SoftwareCheckDiffButton.Location.X + $script:AutoChart02SoftwareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02SoftwareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSoftwareFileName -QueryName "Software" -QueryTabName "Software Count Per Host" -PropertyX "PSComputerName" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02SoftwareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02SoftwareCheckDiffButton.Location.X
                   Y = $script:AutoChart02SoftwareCheckDiffButton.Location.Y + $script:AutoChart02SoftwareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareOpenInShell
$script:AutoChart02SoftwareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02SoftwareManipulationPanel.controls.Add($script:AutoChart02SoftwareOpenInShell)


$script:AutoChart02SoftwareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02SoftwareOpenInShell.Location.X + $script:AutoChart02SoftwareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SoftwareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareViewResults
$script:AutoChart02SoftwareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSoftware | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02SoftwareManipulationPanel.controls.Add($script:AutoChart02SoftwareViewResults)


### Save the chart to file
$script:AutoChart02SoftwareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02SoftwareOpenInShell.Location.X
                  Y = $script:AutoChart02SoftwareOpenInShell.Location.Y + $script:AutoChart02SoftwareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SoftwareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SoftwareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02Software -Title $script:AutoChart02SoftwareTitle
})
$script:AutoChart02SoftwareManipulationPanel.controls.Add($script:AutoChart02SoftwareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02SoftwareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SoftwareSaveButton.Location.X
                        Y = $script:AutoChart02SoftwareSaveButton.Location.Y + $script:AutoChart02SoftwareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02SoftwareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02SoftwareManipulationPanel.Controls.Add($script:AutoChart02SoftwareNoticeTextbox)

$script:AutoChart02Software.Series["Software Count Per Host"].Points.Clear()
$script:AutoChart02SoftwareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Software.Series["Software Count Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03Software = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Software.Location.X
                  Y = $script:AutoChart01Software.Location.Y + $script:AutoChart01Software.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03Software.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03SoftwareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03Software.Titles.Add($script:AutoChart03SoftwareTitle)

### Create Charts Area
$script:AutoChart03SoftwareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03SoftwareArea.Name        = 'Chart Area'
$script:AutoChart03SoftwareArea.AxisX.Title = 'Hosts'
$script:AutoChart03SoftwareArea.AxisX.Interval          = 1
$script:AutoChart03SoftwareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03SoftwareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03SoftwareArea.Area3DStyle.Inclination = 75
$script:AutoChart03Software.ChartAreas.Add($script:AutoChart03SoftwareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03Software.Series.Add("Software Vendor")
$script:AutoChart03Software.Series["Software Vendor"].Enabled           = $True
$script:AutoChart03Software.Series["Software Vendor"].BorderWidth       = 1
$script:AutoChart03Software.Series["Software Vendor"].IsVisibleInLegend = $false
$script:AutoChart03Software.Series["Software Vendor"].Chartarea         = 'Chart Area'
$script:AutoChart03Software.Series["Software Vendor"].Legend            = 'Legend'
$script:AutoChart03Software.Series["Software Vendor"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03Software.Series["Software Vendor"]['PieLineColor']   = 'Black'
$script:AutoChart03Software.Series["Software Vendor"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03Software.Series["Software Vendor"].ChartType         = 'Column'
$script:AutoChart03Software.Series["Software Vendor"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03SoftwareCsvFileHosts      = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03SoftwareUniqueDataFields  = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'Vendor' | Sort-Object -Property 'Vendor' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03SoftwareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()

            if ($script:AutoChart03SoftwareUniqueDataFields.count -gt 0){
                $script:AutoChart03SoftwareTitle.ForeColor = 'Black'
                $script:AutoChart03SoftwareTitle.Text = "Software Vendor"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03SoftwareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03SoftwareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03SoftwareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSoftware ) {
                        if ($Line.Vendor -eq $DataField.Vendor) {
                            $Count += 1
                            if ( $script:AutoChart03SoftwareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03SoftwareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03SoftwareUniqueCount = $script:AutoChart03SoftwareCsvComputers.Count
                    $script:AutoChart03SoftwareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03SoftwareUniqueCount
                        Computers   = $script:AutoChart03SoftwareCsvComputers
                    }
                    $script:AutoChart03SoftwareOverallDataResults += $script:AutoChart03SoftwareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount) }

                $script:AutoChart03SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SoftwareOverallDataResults.count))
                $script:AutoChart03SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SoftwareOverallDataResults.count))
            }
            else {
                $script:AutoChart03SoftwareTitle.ForeColor = 'Red'
                $script:AutoChart03SoftwareTitle.Text = "Software Vendor`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03SoftwareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03Software.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03Software.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareOptionsButton
$script:AutoChart03SoftwareOptionsButton.Add_Click({
    if ($script:AutoChart03SoftwareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03SoftwareOptionsButton.Text = 'Options ^'
        $script:AutoChart03Software.Controls.Add($script:AutoChart03SoftwareManipulationPanel)
    }
    elseif ($script:AutoChart03SoftwareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03SoftwareOptionsButton.Text = 'Options v'
        $script:AutoChart03Software.Controls.Remove($script:AutoChart03SoftwareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03SoftwareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03Software)

$script:AutoChart03SoftwareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03Software.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03Software.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03SoftwareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03SoftwareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SoftwareOverallDataResults.count))
    $script:AutoChart03SoftwareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03SoftwareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03SoftwareTrimOffFirstTrackBarValue = $script:AutoChart03SoftwareTrimOffFirstTrackBar.Value
        $script:AutoChart03SoftwareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03SoftwareTrimOffFirstTrackBar.Value)"
        $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
        $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
    })
    $script:AutoChart03SoftwareTrimOffFirstGroupBox.Controls.Add($script:AutoChart03SoftwareTrimOffFirstTrackBar)
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03SoftwareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03SoftwareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03SoftwareTrimOffFirstGroupBox.Location.X + $script:AutoChart03SoftwareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03SoftwareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03SoftwareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03SoftwareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SoftwareOverallDataResults.count))
    $script:AutoChart03SoftwareTrimOffLastTrackBar.Value         = $($script:AutoChart03SoftwareOverallDataResults.count)
    $script:AutoChart03SoftwareTrimOffLastTrackBarValue   = 0
    $script:AutoChart03SoftwareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03SoftwareTrimOffLastTrackBarValue = $($script:AutoChart03SoftwareOverallDataResults.count) - $script:AutoChart03SoftwareTrimOffLastTrackBar.Value
        $script:AutoChart03SoftwareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03SoftwareOverallDataResults.count) - $script:AutoChart03SoftwareTrimOffLastTrackBar.Value)"
        $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
        $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
    })
$script:AutoChart03SoftwareTrimOffLastGroupBox.Controls.Add($script:AutoChart03SoftwareTrimOffLastTrackBar)
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03SoftwareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03SoftwareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03SoftwareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03SoftwareTrimOffFirstGroupBox.Location.Y + $script:AutoChart03SoftwareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SoftwareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Software.Series["Software Vendor"].ChartType = $script:AutoChart03SoftwareChartTypeComboBox.SelectedItem
#    $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
#    $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
})
$script:AutoChart03SoftwareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03SoftwareChartTypesAvailable) { $script:AutoChart03SoftwareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03SoftwareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03Software3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03SoftwareChartTypeComboBox.Location.X + $script:AutoChart03SoftwareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03SoftwareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03Software3DToggleButton
$script:AutoChart03Software3DInclination = 0
$script:AutoChart03Software3DToggleButton.Add_Click({
    $script:AutoChart03Software3DInclination += 10
    if ( $script:AutoChart03Software3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03SoftwareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03SoftwareArea.Area3DStyle.Inclination = $script:AutoChart03Software3DInclination
        $script:AutoChart03Software3DToggleButton.Text  = "3D On ($script:AutoChart03Software3DInclination)"
#        $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
#        $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03Software3DInclination -le 90 ) {
        $script:AutoChart03SoftwareArea.Area3DStyle.Inclination = $script:AutoChart03Software3DInclination
        $script:AutoChart03Software3DToggleButton.Text  = "3D On ($script:AutoChart03Software3DInclination)"
#        $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
#        $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03Software3DToggleButton.Text  = "3D Off"
        $script:AutoChart03Software3DInclination = 0
        $script:AutoChart03SoftwareArea.Area3DStyle.Inclination = $script:AutoChart03Software3DInclination
        $script:AutoChart03SoftwareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
#        $script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}
    }
})
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03Software3DToggleButton)

### Change the color of the chart
$script:AutoChart03SoftwareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03Software3DToggleButton.Location.X + $script:AutoChart03Software3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03Software3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SoftwareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03SoftwareColorsAvailable) { $script:AutoChart03SoftwareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03SoftwareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Software.Series["Software Vendor"].Color = $script:AutoChart03SoftwareChangeColorComboBox.SelectedItem
})
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03SoftwareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03SoftwareImportCsvPosResults = $script:AutoChartDataSourceCsvSoftware | Where-Object 'Vendor' -eq $($script:AutoChart03SoftwareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03SoftwareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SoftwareImportCsvPosResults) { $script:AutoChart03SoftwareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03SoftwareImportCsvAll = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03SoftwareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03SoftwareImportCsvAll) { if ($Endpoint -notin $script:AutoChart03SoftwareImportCsvPosResults) { $script:AutoChart03SoftwareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03SoftwareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SoftwareImportCsvNegResults) { $script:AutoChart03SoftwareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03SoftwareImportCsvPosResults.count))"
    $script:AutoChart03SoftwareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03SoftwareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03SoftwareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03SoftwareTrimOffLastGroupBox.Location.X + $script:AutoChart03SoftwareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SoftwareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareCheckDiffButton
$script:AutoChart03SoftwareCheckDiffButton.Add_Click({
    $script:AutoChart03SoftwareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'Vendor' -ExpandProperty 'Vendor' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03SoftwareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03SoftwareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SoftwareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SoftwareInvestDiffDropDownLabel.Location.y + $script:AutoChart03SoftwareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03SoftwareInvestDiffDropDownArray) { $script:AutoChart03SoftwareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03SoftwareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SoftwareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03SoftwareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SoftwareInvestDiffDropDownComboBox.Location.y + $script:AutoChart03SoftwareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareInvestDiffExecuteButton
    $script:AutoChart03SoftwareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SoftwareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03SoftwareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SoftwareInvestDiffExecuteButton.Location.y + $script:AutoChart03SoftwareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SoftwareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Location.y + $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03SoftwareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Location.x + $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03SoftwareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SoftwareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03SoftwareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03SoftwareInvestDiffNegResultsLabel.Location.y + $script:AutoChart03SoftwareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03SoftwareInvestDiffForm.Controls.AddRange(@($script:AutoChart03SoftwareInvestDiffDropDownLabel,$script:AutoChart03SoftwareInvestDiffDropDownComboBox,$script:AutoChart03SoftwareInvestDiffExecuteButton,$script:AutoChart03SoftwareInvestDiffPosResultsLabel,$script:AutoChart03SoftwareInvestDiffPosResultsTextBox,$script:AutoChart03SoftwareInvestDiffNegResultsLabel,$script:AutoChart03SoftwareInvestDiffNegResultsTextBox))
    $script:AutoChart03SoftwareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03SoftwareInvestDiffForm.ShowDialog()
})
$script:AutoChart03SoftwareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03SoftwareManipulationPanel.controls.Add($script:AutoChart03SoftwareCheckDiffButton)


$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03SoftwareCheckDiffButton.Location.X + $script:AutoChart03SoftwareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03SoftwareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSoftwareFileName -QueryName "Software" -QueryTabName "Software Vendor" -PropertyX "Vendor" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03SoftwareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03SoftwareCheckDiffButton.Location.X
                   Y = $script:AutoChart03SoftwareCheckDiffButton.Location.Y + $script:AutoChart03SoftwareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareOpenInShell
$script:AutoChart03SoftwareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03SoftwareManipulationPanel.controls.Add($script:AutoChart03SoftwareOpenInShell)


$script:AutoChart03SoftwareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03SoftwareOpenInShell.Location.X + $script:AutoChart03SoftwareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SoftwareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareViewResults
$script:AutoChart03SoftwareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSoftware | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03SoftwareManipulationPanel.controls.Add($script:AutoChart03SoftwareViewResults)


### Save the chart to file
$script:AutoChart03SoftwareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03SoftwareOpenInShell.Location.X
                  Y = $script:AutoChart03SoftwareOpenInShell.Location.Y + $script:AutoChart03SoftwareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SoftwareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SoftwareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03Software -Title $script:AutoChart03SoftwareTitle
})
$script:AutoChart03SoftwareManipulationPanel.controls.Add($script:AutoChart03SoftwareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03SoftwareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SoftwareSaveButton.Location.X
                        Y = $script:AutoChart03SoftwareSaveButton.Location.Y + $script:AutoChart03SoftwareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03SoftwareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03SoftwareManipulationPanel.Controls.Add($script:AutoChart03SoftwareNoticeTextbox)

$script:AutoChart03Software.Series["Software Vendor"].Points.Clear()
$script:AutoChart03SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Software.Series["Software Vendor"].Points.AddXY($_.DataField.Vendor,$_.UniqueCount)}





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04Software = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02Software.Location.X
                  Y = $script:AutoChart02Software.Location.Y + $script:AutoChart02Software.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04Software.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04SoftwareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04Software.Titles.Add($script:AutoChart04SoftwareTitle)

### Create Charts Area
$script:AutoChart04SoftwareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04SoftwareArea.Name        = 'Chart Area'
$script:AutoChart04SoftwareArea.AxisX.Title = 'Hosts'
$script:AutoChart04SoftwareArea.AxisX.Interval          = 1
$script:AutoChart04SoftwareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04SoftwareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04SoftwareArea.Area3DStyle.Inclination = 75
$script:AutoChart04Software.ChartAreas.Add($script:AutoChart04SoftwareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04Software.Series.Add("Install Dates")
$script:AutoChart04Software.Series["Install Dates"].Enabled           = $True
$script:AutoChart04Software.Series["Install Dates"].BorderWidth       = 1
$script:AutoChart04Software.Series["Install Dates"].IsVisibleInLegend = $false
$script:AutoChart04Software.Series["Install Dates"].Chartarea         = 'Chart Area'
$script:AutoChart04Software.Series["Install Dates"].Legend            = 'Legend'
$script:AutoChart04Software.Series["Install Dates"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04Software.Series["Install Dates"]['PieLineColor']   = 'Black'
$script:AutoChart04Software.Series["Install Dates"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04Software.Series["Install Dates"].ChartType         = 'Column'
$script:AutoChart04Software.Series["Install Dates"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04SoftwareCsvFileHosts      = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04SoftwareUniqueDataFields  = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'InstallDate' | Sort-Object -Property 'InstallDate' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04SoftwareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04Software.Series["Install Dates"].Points.Clear()

            if ($script:AutoChart04SoftwareUniqueDataFields.count -gt 0){
                $script:AutoChart04SoftwareTitle.ForeColor = 'Black'
                $script:AutoChart04SoftwareTitle.Text = "Install Dates"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04SoftwareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04SoftwareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04SoftwareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSoftware ) {
                        if ($($Line.InstallDate) -eq $DataField.InstallDate) {
                            $Count += 1
                            if ( $script:AutoChart04SoftwareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04SoftwareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04SoftwareUniqueCount = $script:AutoChart04SoftwareCsvComputers.Count
                    $script:AutoChart04SoftwareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04SoftwareUniqueCount
                        Computers   = $script:AutoChart04SoftwareCsvComputers
                    }
                    $script:AutoChart04SoftwareOverallDataResults += $script:AutoChart04SoftwareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount) }

                $script:AutoChart04SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SoftwareOverallDataResults.count))
                $script:AutoChart04SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SoftwareOverallDataResults.count))
            }
            else {
                $script:AutoChart04SoftwareTitle.ForeColor = 'Red'
                $script:AutoChart04SoftwareTitle.Text = "Install Dates`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04SoftwareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04Software.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04Software.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareOptionsButton
$script:AutoChart04SoftwareOptionsButton.Add_Click({
    if ($script:AutoChart04SoftwareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04SoftwareOptionsButton.Text = 'Options ^'
        $script:AutoChart04Software.Controls.Add($script:AutoChart04SoftwareManipulationPanel)
    }
    elseif ($script:AutoChart04SoftwareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04SoftwareOptionsButton.Text = 'Options v'
        $script:AutoChart04Software.Controls.Remove($script:AutoChart04SoftwareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04SoftwareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04Software)

$script:AutoChart04SoftwareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04Software.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04Software.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04SoftwareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04SoftwareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04SoftwareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SoftwareOverallDataResults.count))
    $script:AutoChart04SoftwareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04SoftwareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04SoftwareTrimOffFirstTrackBarValue = $script:AutoChart04SoftwareTrimOffFirstTrackBar.Value
        $script:AutoChart04SoftwareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04SoftwareTrimOffFirstTrackBar.Value)"
        $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
        $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
    })
    $script:AutoChart04SoftwareTrimOffFirstGroupBox.Controls.Add($script:AutoChart04SoftwareTrimOffFirstTrackBar)
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04SoftwareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04SoftwareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04SoftwareTrimOffFirstGroupBox.Location.X + $script:AutoChart04SoftwareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04SoftwareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04SoftwareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04SoftwareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04SoftwareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SoftwareOverallDataResults.count))
    $script:AutoChart04SoftwareTrimOffLastTrackBar.Value         = $($script:AutoChart04SoftwareOverallDataResults.count)
    $script:AutoChart04SoftwareTrimOffLastTrackBarValue   = 0
    $script:AutoChart04SoftwareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04SoftwareTrimOffLastTrackBarValue = $($script:AutoChart04SoftwareOverallDataResults.count) - $script:AutoChart04SoftwareTrimOffLastTrackBar.Value
        $script:AutoChart04SoftwareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04SoftwareOverallDataResults.count) - $script:AutoChart04SoftwareTrimOffLastTrackBar.Value)"
        $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
        $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
    })
$script:AutoChart04SoftwareTrimOffLastGroupBox.Controls.Add($script:AutoChart04SoftwareTrimOffLastTrackBar)
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04SoftwareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04SoftwareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04SoftwareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04SoftwareTrimOffFirstGroupBox.Location.Y + $script:AutoChart04SoftwareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SoftwareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Software.Series["Install Dates"].ChartType = $script:AutoChart04SoftwareChartTypeComboBox.SelectedItem
#    $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
#    $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
})
$script:AutoChart04SoftwareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04SoftwareChartTypesAvailable) { $script:AutoChart04SoftwareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04SoftwareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04Software3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04SoftwareChartTypeComboBox.Location.X + $script:AutoChart04SoftwareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04SoftwareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04Software3DToggleButton
$script:AutoChart04Software3DInclination = 0
$script:AutoChart04Software3DToggleButton.Add_Click({
    $script:AutoChart04Software3DInclination += 10
    if ( $script:AutoChart04Software3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04SoftwareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04SoftwareArea.Area3DStyle.Inclination = $script:AutoChart04Software3DInclination
        $script:AutoChart04Software3DToggleButton.Text  = "3D On ($script:AutoChart04Software3DInclination)"
#        $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
#        $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04Software3DInclination -le 90 ) {
        $script:AutoChart04SoftwareArea.Area3DStyle.Inclination = $script:AutoChart04Software3DInclination
        $script:AutoChart04Software3DToggleButton.Text  = "3D On ($script:AutoChart04Software3DInclination)"
#        $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
#        $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04Software3DToggleButton.Text  = "3D Off"
        $script:AutoChart04Software3DInclination = 0
        $script:AutoChart04SoftwareArea.Area3DStyle.Inclination = $script:AutoChart04Software3DInclination
        $script:AutoChart04SoftwareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04Software.Series["Install Dates"].Points.Clear()
#        $script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}
    }
})
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04Software3DToggleButton)

### Change the color of the chart
$script:AutoChart04SoftwareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04Software3DToggleButton.Location.X + $script:AutoChart04Software3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04Software3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SoftwareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04SoftwareColorsAvailable) { $script:AutoChart04SoftwareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04SoftwareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Software.Series["Install Dates"].Color = $script:AutoChart04SoftwareChangeColorComboBox.SelectedItem
})
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04SoftwareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04SoftwareImportCsvPosResults = $script:AutoChartDataSourceCsvSoftware | Where-Object 'InstallDate' -eq $($script:AutoChart04SoftwareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04SoftwareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SoftwareImportCsvPosResults) { $script:AutoChart04SoftwareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04SoftwareImportCsvAll = $script:AutoChartDataSourceCsvSoftware | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04SoftwareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04SoftwareImportCsvAll) { if ($Endpoint -notin $script:AutoChart04SoftwareImportCsvPosResults) { $script:AutoChart04SoftwareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04SoftwareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SoftwareImportCsvNegResults) { $script:AutoChart04SoftwareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04SoftwareImportCsvPosResults.count))"
    $script:AutoChart04SoftwareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04SoftwareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04SoftwareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04SoftwareTrimOffLastGroupBox.Location.X + $script:AutoChart04SoftwareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SoftwareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareCheckDiffButton
$script:AutoChart04SoftwareCheckDiffButton.Add_Click({
    $script:AutoChart04SoftwareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSoftware | Select-Object -Property 'InstallDate' -ExpandProperty 'InstallDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04SoftwareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04SoftwareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SoftwareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SoftwareInvestDiffDropDownLabel.Location.y + $script:AutoChart04SoftwareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04SoftwareInvestDiffDropDownArray) { $script:AutoChart04SoftwareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04SoftwareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SoftwareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04SoftwareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SoftwareInvestDiffDropDownComboBox.Location.y + $script:AutoChart04SoftwareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareInvestDiffExecuteButton
    $script:AutoChart04SoftwareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SoftwareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04SoftwareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SoftwareInvestDiffExecuteButton.Location.y + $script:AutoChart04SoftwareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SoftwareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Location.y + $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04SoftwareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Location.x + $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04SoftwareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SoftwareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04SoftwareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04SoftwareInvestDiffNegResultsLabel.Location.y + $script:AutoChart04SoftwareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04SoftwareInvestDiffForm.Controls.AddRange(@($script:AutoChart04SoftwareInvestDiffDropDownLabel,$script:AutoChart04SoftwareInvestDiffDropDownComboBox,$script:AutoChart04SoftwareInvestDiffExecuteButton,$script:AutoChart04SoftwareInvestDiffPosResultsLabel,$script:AutoChart04SoftwareInvestDiffPosResultsTextBox,$script:AutoChart04SoftwareInvestDiffNegResultsLabel,$script:AutoChart04SoftwareInvestDiffNegResultsTextBox))
    $script:AutoChart04SoftwareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04SoftwareInvestDiffForm.ShowDialog()
})
$script:AutoChart04SoftwareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04SoftwareManipulationPanel.controls.Add($script:AutoChart04SoftwareCheckDiffButton)


$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04SoftwareCheckDiffButton.Location.X + $script:AutoChart04SoftwareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04SoftwareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSoftwareFileName -QueryName "Software" -QueryTabName "Install Dates" -PropertyX "InstallDate" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04SoftwareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04SoftwareCheckDiffButton.Location.X
                   Y = $script:AutoChart04SoftwareCheckDiffButton.Location.Y + $script:AutoChart04SoftwareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareOpenInShell
$script:AutoChart04SoftwareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04SoftwareManipulationPanel.controls.Add($script:AutoChart04SoftwareOpenInShell)


$script:AutoChart04SoftwareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04SoftwareOpenInShell.Location.X + $script:AutoChart04SoftwareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SoftwareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareViewResults
$script:AutoChart04SoftwareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSoftware | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04SoftwareManipulationPanel.controls.Add($script:AutoChart04SoftwareViewResults)


### Save the chart to file
$script:AutoChart04SoftwareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04SoftwareOpenInShell.Location.X
                  Y = $script:AutoChart04SoftwareOpenInShell.Location.Y + $script:AutoChart04SoftwareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SoftwareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SoftwareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04Software -Title $script:AutoChart04SoftwareTitle
})
$script:AutoChart04SoftwareManipulationPanel.controls.Add($script:AutoChart04SoftwareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04SoftwareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SoftwareSaveButton.Location.X
                        Y = $script:AutoChart04SoftwareSaveButton.Location.Y + $script:AutoChart04SoftwareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04SoftwareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04SoftwareManipulationPanel.Controls.Add($script:AutoChart04SoftwareNoticeTextbox)

$script:AutoChart04Software.Series["Install Dates"].Points.Clear()
$script:AutoChart04SoftwareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SoftwareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SoftwareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Software.Series["Install Dates"].Points.AddXY($_.DataField.InstallDate,$_.UniqueCount)}











# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURzzGRkSxpP4C8uLhoI8BDE6H
# 0YSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUHmsVyQ/LWelZE83+HwhXMEEl3LcwDQYJKoZI
# hvcNAQEBBQAEggEASvejNbqsG+ltJDj4JmE+Qg1MLVv5c8DoT1YCTmE188zrkJ1u
# JWi19H4KoqaIBuJXGSx6IrrudzTH9xMSe1ltdoO6RCWbl3ThLJPziITkIHpUyUfO
# Gp6gJmSPVIKrW+vRvB29cDLi/I6UiVQtF/HHWF4mH1ugBUYL4yVkqbgdD+0RzgI6
# gCcFydaCMyHzSuUtw2AnGZ8BCfDnLJllauAgdhUX5Rewl5An9diby44CgiqEH8as
# n6qBRcllPCNnWdxe1OyA0VXMrbjw6TPJQjI3PTKsiRhlYEdp77CR+9PQZVUACJns
# fv6R+4ks+lzb5uQko0zzqJYn25xirKzlIN+tsA==
# SIG # End signature block
