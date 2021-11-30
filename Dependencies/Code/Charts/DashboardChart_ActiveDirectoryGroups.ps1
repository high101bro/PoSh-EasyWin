$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Active Directory Groups'
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

$script:AutoChart01ADGroupsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'AD Groups' -or $CSVFile -match 'Active Directory Groups') { $script:AutoChart01ADGroupsCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ADGroupsCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart01ADGroups.Controls.Remove($script:AutoChart01ADGroupsManipulationPanel)
    $script:AutoChart02ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart02ADGroups.Controls.Remove($script:AutoChart02ADGroupsManipulationPanel)
    $script:AutoChart03ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart03ADGroups.Controls.Remove($script:AutoChart03ADGroupsManipulationPanel)
    $script:AutoChart04ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart04ADGroups.Controls.Remove($script:AutoChart04ADGroupsManipulationPanel)
    $script:AutoChart05ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart05ADGroups.Controls.Remove($script:AutoChart05ADGroupsManipulationPanel)
    $script:AutoChart06ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart06ADGroups.Controls.Remove($script:AutoChart06ADGroupsManipulationPanel)
    $script:AutoChart07ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart07ADGroups.Controls.Remove($script:AutoChart07ADGroupsManipulationPanel)
    $script:AutoChart08ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart08ADGroups.Controls.Remove($script:AutoChart08ADGroupsManipulationPanel)
    $script:AutoChart09ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart09ADGroups.Controls.Remove($script:AutoChart09ADGroupsManipulationPanel)
    $script:AutoChart10ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart10ADGroups.Controls.Remove($script:AutoChart10ADGroupsManipulationPanel)
    $script:AutoChart11ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart11ADGroups.Controls.Remove($script:AutoChart11ADGroupsManipulationPanel)
    $script:AutoChart12ADGroupsOptionsButton.Text = 'Options v'
    $script:AutoChart12ADGroups.Controls.Remove($script:AutoChart12ADGroupsManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'AD Groups'
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

        script:Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}


















##############################################################################################
# AutoChart01ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01ADGroups.Titles.Add($script:AutoChart01ADGroupsTitle)

### Create Charts Area
$script:AutoChart01ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart01ADGroupsArea.AxisX.Title = 'Name'
$script:AutoChart01ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart01ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart01ADGroups.ChartAreas.Add($script:AutoChart01ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01ADGroups.Series.Add("Name")
$script:AutoChart01ADGroups.Series["Name"].Enabled           = $True
$script:AutoChart01ADGroups.Series["Name"].BorderWidth       = 1
$script:AutoChart01ADGroups.Series["Name"].IsVisibleInLegend = $false
$script:AutoChart01ADGroups.Series["Name"].Chartarea         = 'Chart Area'
$script:AutoChart01ADGroups.Series["Name"].Legend            = 'Legend'
$script:AutoChart01ADGroups.Series["Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01ADGroups.Series["Name"]['PieLineColor']   = 'Black'
$script:AutoChart01ADGroups.Series["Name"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01ADGroups.Series["Name"].ChartType         = 'Column'
$script:AutoChart01ADGroups.Series["Name"].Color             = 'Red'

        function Generate-AutoChart01ADGroups {
            $script:AutoChart01ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart01ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Name | Sort-Object Name -unique
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01ADGroups.Series["Name"].Points.Clear()

            if ($script:AutoChart01ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart01ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart01ADGroupsTitle.Text = "Name"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart01ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ADGroupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart01ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart01ADGroupsUniqueCount = $script:AutoChart01ADGroupsCsvComputers.Count
                    $script:AutoChart01ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ADGroupsUniqueCount
                        Computers   = $script:AutoChart01ADGroupsCsvComputers
                    }
                    $script:AutoChart01ADGroupsOverallDataResults += $script:AutoChart01ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADGroupsOverallDataResults.count))
                $script:AutoChart01ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart01ADGroupsTitle.ForeColor = 'Red'
                $script:AutoChart01ADGroupsTitle.Text = "Name`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart01ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsOptionsButton
$script:AutoChart01ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart01ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart01ADGroups.Controls.Add($script:AutoChart01ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart01ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart01ADGroups.Controls.Remove($script:AutoChart01ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADGroups)


$script:AutoChart01ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADGroupsOverallDataResults.count))
    $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart01ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
        $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ADGroupsTrimOffFirstTrackBar)
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADGroupsOverallDataResults.count))
    $script:AutoChart01ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart01ADGroupsOverallDataResults.count)
    $script:AutoChart01ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart01ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart01ADGroupsOverallDataResults.count) - $script:AutoChart01ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart01ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ADGroupsOverallDataResults.count) - $script:AutoChart01ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
        $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart01ADGroupsTrimOffLastTrackBar)
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADGroups.Series["Name"].ChartType = $script:AutoChart01ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
#    $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ADGroupsChartTypesAvailable) { $script:AutoChart01ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroupsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ADGroupsChartTypeComboBox.Location.X + $script:AutoChart01ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroups3DToggleButton
$script:AutoChart01ADGroups3DInclination = 0
$script:AutoChart01ADGroups3DToggleButton.Add_Click({

    $script:AutoChart01ADGroups3DInclination += 10
    if ( $script:AutoChart01ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart01ADGroups3DInclination
        $script:AutoChart01ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart01ADGroups3DInclination)"
#        $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
#        $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01ADGroups3DInclination -le 90 ) {
        $script:AutoChart01ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart01ADGroups3DInclination
        $script:AutoChart01ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart01ADGroups3DInclination)"
#        $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
#        $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart01ADGroups3DInclination = 0
        $script:AutoChart01ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart01ADGroups3DInclination
        $script:AutoChart01ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01ADGroups.Series["Name"].Points.Clear()
#        $script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart01ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01ADGroups3DToggleButton.Location.X + $script:AutoChart01ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ADGroupsColorsAvailable) { $script:AutoChart01ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADGroups.Series["Name"].Color = $script:AutoChart01ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroupsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart01ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart01ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADGroupsImportCsvPosResults) { $script:AutoChart01ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart01ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ADGroupsImportCsvPosResults) { $script:AutoChart01ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADGroupsImportCsvNegResults) { $script:AutoChart01ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ADGroupsImportCsvPosResults.count))"
    $script:AutoChart01ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart01ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsCheckDiffButton
$script:AutoChart01ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart01ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart01ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ADGroupsInvestDiffDropDownArray) { $script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADGroups }})
    $script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart01ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsInvestDiffExecuteButton
    $script:AutoChart01ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADGroups }})
    $script:AutoChart01ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart01ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart01ADGroupsInvestDiffDropDownLabel,$script:AutoChart01ADGroupsInvestDiffDropDownComboBox,$script:AutoChart01ADGroupsInvestDiffExecuteButton,$script:AutoChart01ADGroupsInvestDiffPosResultsLabel,$script:AutoChart01ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart01ADGroupsInvestDiffNegResultsLabel,$script:AutoChart01ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart01ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart01ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ADGroupsManipulationPanel.controls.Add($script:AutoChart01ADGroupsCheckDiffButton)


$AutoChart01ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ADGroupsCheckDiffButton.Location.X + $script:AutoChart01ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Name" -PropertyX "Name" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart01ADGroupsExpandChartButton
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($AutoChart01ADGroupsExpandChartButton)


$script:AutoChart01ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart01ADGroupsCheckDiffButton.Location.Y + $script:AutoChart01ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsOpenInShell
$script:AutoChart01ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01ADGroupsManipulationPanel.controls.Add($script:AutoChart01ADGroupsOpenInShell)


$script:AutoChart01ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ADGroupsOpenInShell.Location.X + $script:AutoChart01ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsViewResults
$script:AutoChart01ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01ADGroupsManipulationPanel.controls.Add($script:AutoChart01ADGroupsViewResults)


### Save the chart to file
$script:AutoChart01ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart01ADGroupsOpenInShell.Location.Y + $script:AutoChart01ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100 #205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01ADGroups -Title $script:AutoChart01ADGroupsTitle
})
$script:AutoChart01ADGroupsManipulationPanel.controls.Add($script:AutoChart01ADGroupsSaveButton)


#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart01ADGroupsSaveButton.Location.Y + $script:AutoChart01ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ADGroupsManipulationPanel.Controls.Add($script:AutoChart01ADGroupsNoticeTextbox)

$script:AutoChart01ADGroups.Series["Name"].Points.Clear()
$script:AutoChart01ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADGroups.Series["Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart02ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADGroups.Location.X + $script:AutoChart01ADGroups.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01ADGroups.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02ADGroups.Titles.Add($script:AutoChart02ADGroupsTitle)

### Create Charts Area
$script:AutoChart02ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart02ADGroupsArea.AxisX.Title = 'GroupScope'
$script:AutoChart02ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart02ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart02ADGroups.ChartAreas.Add($script:AutoChart02ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02ADGroups.Series.Add("GroupScope")
$script:AutoChart02ADGroups.Series["GroupScope"].Enabled           = $True
$script:AutoChart02ADGroups.Series["GroupScope"].BorderWidth       = 1
$script:AutoChart02ADGroups.Series["GroupScope"].IsVisibleInLegend = $false
$script:AutoChart02ADGroups.Series["GroupScope"].Chartarea         = 'Chart Area'
$script:AutoChart02ADGroups.Series["GroupScope"].Legend            = 'Legend'
$script:AutoChart02ADGroups.Series["GroupScope"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02ADGroups.Series["GroupScope"]['PieLineColor']   = 'Black'
$script:AutoChart02ADGroups.Series["GroupScope"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02ADGroups.Series["GroupScope"].ChartType         = 'Column'
$script:AutoChart02ADGroups.Series["GroupScope"].Color             = 'Blue'

        function Generate-AutoChart02ADGroups {
            $script:AutoChart02ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart02ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object GroupScope | Sort-Object GroupScope -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()

            if ($script:AutoChart02ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart02ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart02ADGroupsTitle.Text = "Group Scope"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart02ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02ADGroupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart02ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.GroupScope) -eq $DataField.GroupScope) {
                            $Count += 1
                            if ( $script:AutoChart02ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart02ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart02ADGroupsUniqueCount = $script:AutoChart02ADGroupsCsvComputers.Count
                    $script:AutoChart02ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02ADGroupsUniqueCount
                        Computers   = $script:AutoChart02ADGroupsCsvComputers
                    }
                    $script:AutoChart02ADGroupsOverallDataResults += $script:AutoChart02ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount) }
                $script:AutoChart02ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADGroupsOverallDataResults.count))
                $script:AutoChart02ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart02ADGroupsTitle.ForeColor = 'Red'
                $script:AutoChart02ADGroupsTitle.Text = "GroupScope`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart02ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsOptionsButton
$script:AutoChart02ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart02ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart02ADGroups.Controls.Add($script:AutoChart02ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart02ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart02ADGroups.Controls.Remove($script:AutoChart02ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADGroups)


$script:AutoChart02ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADGroupsOverallDataResults.count))
    $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart02ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
        $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
    })
    $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ADGroupsTrimOffFirstTrackBar)
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADGroupsOverallDataResults.count))
    $script:AutoChart02ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart02ADGroupsOverallDataResults.count)
    $script:AutoChart02ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart02ADGroupsOverallDataResults.count) - $script:AutoChart02ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart02ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ADGroupsOverallDataResults.count) - $script:AutoChart02ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
        $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
    })
$script:AutoChart02ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart02ADGroupsTrimOffLastTrackBar)
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADGroups.Series["GroupScope"].ChartType = $script:AutoChart02ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
#    $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
})
$script:AutoChart02ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ADGroupsChartTypesAvailable) { $script:AutoChart02ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroupsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ADGroupsChartTypeComboBox.Location.X + $script:AutoChart02ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroups3DToggleButton
$script:AutoChart02ADGroups3DInclination = 0
$script:AutoChart02ADGroups3DToggleButton.Add_Click({

    $script:AutoChart02ADGroups3DInclination += 10
    if ( $script:AutoChart02ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart02ADGroups3DInclination
        $script:AutoChart02ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart02ADGroups3DInclination)"
#        $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
#        $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart02ADGroups3DInclination -le 90 ) {
        $script:AutoChart02ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart02ADGroups3DInclination
        $script:AutoChart02ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart02ADGroups3DInclination)"
#        $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
#        $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
    }
    else {
        $script:AutoChart02ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart02ADGroups3DInclination = 0
        $script:AutoChart02ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart02ADGroups3DInclination
        $script:AutoChart02ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
#        $script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}
    }
})
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart02ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02ADGroups3DToggleButton.Location.X + $script:AutoChart02ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ADGroupsColorsAvailable) { $script:AutoChart02ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADGroups.Series["GroupScope"].Color = $script:AutoChart02ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroupsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart02ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'GroupScope' -eq $($script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart02ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADGroupsImportCsvPosResults) { $script:AutoChart02ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart02ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ADGroupsImportCsvPosResults) { $script:AutoChart02ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADGroupsImportCsvNegResults) { $script:AutoChart02ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ADGroupsImportCsvPosResults.count))"
    $script:AutoChart02ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart02ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsCheckDiffButton
$script:AutoChart02ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart02ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'GroupScope' -ExpandProperty 'GroupScope' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart02ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ADGroupsInvestDiffDropDownArray) { $script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADGroups }})
    $script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart02ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsInvestDiffExecuteButton
    $script:AutoChart02ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADGroups }})
    $script:AutoChart02ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart02ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart02ADGroupsInvestDiffDropDownLabel,$script:AutoChart02ADGroupsInvestDiffDropDownComboBox,$script:AutoChart02ADGroupsInvestDiffExecuteButton,$script:AutoChart02ADGroupsInvestDiffPosResultsLabel,$script:AutoChart02ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart02ADGroupsInvestDiffNegResultsLabel,$script:AutoChart02ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart02ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart02ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ADGroupsManipulationPanel.controls.Add($script:AutoChart02ADGroupsCheckDiffButton)


$AutoChart02ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ADGroupsCheckDiffButton.Location.X + $script:AutoChart02ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "GroupScope" -PropertyX "GroupScope" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart02ADGroupsExpandChartButton
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($AutoChart02ADGroupsExpandChartButton)


$script:AutoChart02ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart02ADGroupsCheckDiffButton.Location.Y + $script:AutoChart02ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsOpenInShell
$script:AutoChart02ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02ADGroupsManipulationPanel.controls.Add($script:AutoChart02ADGroupsOpenInShell)


$script:AutoChart02ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ADGroupsOpenInShell.Location.X + $script:AutoChart02ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsViewResults
$script:AutoChart02ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02ADGroupsManipulationPanel.controls.Add($script:AutoChart02ADGroupsViewResults)


### Save the chart to file
$script:AutoChart02ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart02ADGroupsOpenInShell.Location.Y + $script:AutoChart02ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02ADGroups -Title $script:AutoChart02ADGroupsTitle
})
$script:AutoChart02ADGroupsManipulationPanel.controls.Add($script:AutoChart02ADGroupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart02ADGroupsSaveButton.Location.Y + $script:AutoChart02ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ADGroupsManipulationPanel.Controls.Add($script:AutoChart02ADGroupsNoticeTextbox)

$script:AutoChart02ADGroups.Series["GroupScope"].Points.Clear()
$script:AutoChart02ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADGroups.Series["GroupScope"].Points.AddXY($_.DataField.GroupScope,$_.UniqueCount)}




















##############################################################################################
# AutoChart03ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADGroups.Location.X
                  Y = $script:AutoChart01ADGroups.Location.Y + $script:AutoChart01ADGroups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03ADGroups.Titles.Add($script:AutoChart03ADGroupsTitle)

### Create Charts Area
$script:AutoChart03ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart03ADGroupsArea.AxisX.Title = 'Created'
$script:AutoChart03ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart03ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart03ADGroups.ChartAreas.Add($script:AutoChart03ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03ADGroups.Series.Add("Created")
$script:AutoChart03ADGroups.Series["Created"].Enabled           = $True
$script:AutoChart03ADGroups.Series["Created"].BorderWidth       = 1
$script:AutoChart03ADGroups.Series["Created"].IsVisibleInLegend = $false
$script:AutoChart03ADGroups.Series["Created"].Chartarea         = 'Chart Area'
$script:AutoChart03ADGroups.Series["Created"].Legend            = 'Legend'
$script:AutoChart03ADGroups.Series["Created"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03ADGroups.Series["Created"]['PieLineColor']   = 'Black'
$script:AutoChart03ADGroups.Series["Created"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03ADGroups.Series["Created"].ChartType         = 'Bar'
$script:AutoChart03ADGroups.Series["Created"].Color             = 'Green'

        function Generate-AutoChart03ADGroups {
            $script:AutoChart03ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart03ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Created | Sort-Object Created -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03ADGroups.Series["Created"].Points.Clear()

            if ($script:AutoChart03ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart03ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart03ADGroupsTitle.Text = "Created"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart03ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ADGroupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Created -eq $DataField.Created) {
                            $Count += 1
                            if ( $script:AutoChart03ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart03ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart03ADGroupsUniqueCount = $script:AutoChart03ADGroupsCsvComputers.Count
                    $script:AutoChart03ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ADGroupsUniqueCount
                        Computers   = $script:AutoChart03ADGroupsCsvComputers
                    }
                    $script:AutoChart03ADGroupsOverallDataResults += $script:AutoChart03ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03ADGroupsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | ForEach-Object { $script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount) }

                $script:AutoChart03ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADGroupsOverallDataResults.count))
                $script:AutoChart03ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart03ADGroupsTitle.ForeColor = 'Red'
                $script:AutoChart03ADGroupsTitle.Text = "Created`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart03ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsOptionsButton
$script:AutoChart03ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart03ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart03ADGroups.Controls.Add($script:AutoChart03ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart03ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart03ADGroups.Controls.Remove($script:AutoChart03ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADGroups)

$script:AutoChart03ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADGroupsOverallDataResults.count))
    $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart03ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
        $script:AutoChart03ADGroupsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    })
    $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ADGroupsTrimOffFirstTrackBar)
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADGroupsOverallDataResults.count))
    $script:AutoChart03ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart03ADGroupsOverallDataResults.count)
    $script:AutoChart03ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart03ADGroupsOverallDataResults.count) - $script:AutoChart03ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart03ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ADGroupsOverallDataResults.count) - $script:AutoChart03ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
        $script:AutoChart03ADGroupsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    })
$script:AutoChart03ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart03ADGroupsTrimOffLastTrackBar)
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADGroups.Series["Created"].ChartType = $script:AutoChart03ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
#    $script:AutoChart03ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
})
$script:AutoChart03ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ADGroupsChartTypesAvailable) { $script:AutoChart03ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ADGroupsChartTypeComboBox.Location.X + $script:AutoChart03ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroups3DToggleButton
$script:AutoChart03ADGroups3DInclination = 0
$script:AutoChart03ADGroups3DToggleButton.Add_Click({
    $script:AutoChart03ADGroups3DInclination += 10
    if ( $script:AutoChart03ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart03ADGroups3DInclination
        $script:AutoChart03ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart03ADGroups3DInclination)"
#        $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
#        $script:AutoChart03ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03ADGroups3DInclination -le 90 ) {
        $script:AutoChart03ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart03ADGroups3DInclination
        $script:AutoChart03ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart03ADGroups3DInclination)"
#        $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
#        $script:AutoChart03ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart03ADGroups3DInclination = 0
        $script:AutoChart03ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart03ADGroups3DInclination
        $script:AutoChart03ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03ADGroups.Series["Created"].Points.Clear()
#        $script:AutoChart03ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
})
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart03ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03ADGroups3DToggleButton.Location.X + $script:AutoChart03ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ADGroupsColorsAvailable) { $script:AutoChart03ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADGroups.Series["Created"].Color = $script:AutoChart03ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart03ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Created' -eq $($script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart03ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADGroupsImportCsvPosResults) { $script:AutoChart03ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart03ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ADGroupsImportCsvPosResults) { $script:AutoChart03ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADGroupsImportCsvNegResults) { $script:AutoChart03ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ADGroupsImportCsvPosResults.count))"
    $script:AutoChart03ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart03ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsCheckDiffButton
$script:AutoChart03ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart03ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Created' -ExpandProperty 'Created' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart03ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ADGroupsInvestDiffDropDownArray) { $script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADGroups }})
    $script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart03ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsInvestDiffExecuteButton
    $script:AutoChart03ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADGroups }})
    $script:AutoChart03ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart03ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart03ADGroupsInvestDiffDropDownLabel,$script:AutoChart03ADGroupsInvestDiffDropDownComboBox,$script:AutoChart03ADGroupsInvestDiffExecuteButton,$script:AutoChart03ADGroupsInvestDiffPosResultsLabel,$script:AutoChart03ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart03ADGroupsInvestDiffNegResultsLabel,$script:AutoChart03ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart03ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart03ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ADGroupsManipulationPanel.controls.Add($script:AutoChart03ADGroupsCheckDiffButton)


$AutoChart03ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ADGroupsCheckDiffButton.Location.X + $script:AutoChart03ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Created" -PropertyX "Created" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart03ADGroupsExpandChartButton
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($AutoChart03ADGroupsExpandChartButton)


$script:AutoChart03ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart03ADGroupsCheckDiffButton.Location.Y + $script:AutoChart03ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsOpenInShell
$script:AutoChart03ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03ADGroupsManipulationPanel.controls.Add($script:AutoChart03ADGroupsOpenInShell)


$script:AutoChart03ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ADGroupsOpenInShell.Location.X + $script:AutoChart03ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsViewResults
$script:AutoChart03ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03ADGroupsManipulationPanel.controls.Add($script:AutoChart03ADGroupsViewResults)


### Save the chart to file
$script:AutoChart03ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart03ADGroupsOpenInShell.Location.Y + $script:AutoChart03ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03ADGroups -Title $script:AutoChart03ADGroupsTitle
})
$script:AutoChart03ADGroupsManipulationPanel.controls.Add($script:AutoChart03ADGroupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart03ADGroupsSaveButton.Location.Y + $script:AutoChart03ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ADGroupsManipulationPanel.Controls.Add($script:AutoChart03ADGroupsNoticeTextbox)

$script:AutoChart03ADGroups.Series["Created"].Points.Clear()
$script:AutoChart03ADGroupsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart03ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADGroups.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}





















##############################################################################################
# AutoChart04ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02ADGroups.Location.X
                  Y = $script:AutoChart02ADGroups.Location.Y + $script:AutoChart02ADGroups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04ADGroups.Titles.Add($script:AutoChart04ADGroupsTitle)

### Create Charts Area
$script:AutoChart04ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart04ADGroupsArea.AxisX.Title = 'Modified'
$script:AutoChart04ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart04ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart04ADGroups.ChartAreas.Add($script:AutoChart04ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04ADGroups.Series.Add("Modified")
$script:AutoChart04ADGroups.Series["Modified"].Enabled           = $True
$script:AutoChart04ADGroups.Series["Modified"].BorderWidth       = 1
$script:AutoChart04ADGroups.Series["Modified"].IsVisibleInLegend = $false
$script:AutoChart04ADGroups.Series["Modified"].Chartarea         = 'Chart Area'
$script:AutoChart04ADGroups.Series["Modified"].Legend            = 'Legend'
$script:AutoChart04ADGroups.Series["Modified"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04ADGroups.Series["Modified"]['PieLineColor']   = 'Black'
$script:AutoChart04ADGroups.Series["Modified"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04ADGroups.Series["Modified"].ChartType         = 'Bar'
$script:AutoChart04ADGroups.Series["Modified"].Color             = 'Orange'

        function Generate-AutoChart04ADGroups {
            $script:AutoChart04ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart04ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Modified | Sort-Object Modified -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()

            if ($script:AutoChart04ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart04ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart04ADGroupsTitle.Text = "Modified"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart04ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ADGroupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Modified) -eq $DataField.Modified) {
                            $Count += 1
                            if ( $script:AutoChart04ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart04ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart04ADGroupsUniqueCount = $script:AutoChart04ADGroupsCsvComputers.Count
                    $script:AutoChart04ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ADGroupsUniqueCount
                        Computers   = $script:AutoChart04ADGroupsCsvComputers
                    }
                    $script:AutoChart04ADGroupsOverallDataResults += $script:AutoChart04ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | ForEach-Object { $script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount) }

                $script:AutoChart04ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADGroupsOverallDataResults.count))
                $script:AutoChart04ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart04ADGroupsTitle.ForeColor = 'Red'
                $script:AutoChart04ADGroupsTitle.Text = "Modified`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart04ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsOptionsButton
$script:AutoChart04ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart04ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart04ADGroups.Controls.Add($script:AutoChart04ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart04ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart04ADGroups.Controls.Remove($script:AutoChart04ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADGroups)

$script:AutoChart04ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADGroupsOverallDataResults.count))
    $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart04ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
        $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
    $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ADGroupsTrimOffFirstTrackBar)
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADGroupsOverallDataResults.count))
    $script:AutoChart04ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart04ADGroupsOverallDataResults.count)
    $script:AutoChart04ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart04ADGroupsOverallDataResults.count) - $script:AutoChart04ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart04ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ADGroupsOverallDataResults.count) - $script:AutoChart04ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
        $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
$script:AutoChart04ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart04ADGroupsTrimOffLastTrackBar)
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADGroups.Series["Modified"].ChartType = $script:AutoChart04ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
#    $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
})
$script:AutoChart04ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ADGroupsChartTypesAvailable) { $script:AutoChart04ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ADGroupsChartTypeComboBox.Location.X + $script:AutoChart04ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroups3DToggleButton
$script:AutoChart04ADGroups3DInclination = 0
$script:AutoChart04ADGroups3DToggleButton.Add_Click({
    $script:AutoChart04ADGroups3DInclination += 10
    if ( $script:AutoChart04ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart04ADGroups3DInclination
        $script:AutoChart04ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart04ADGroups3DInclination)"
#        $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
#        $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04ADGroups3DInclination -le 90 ) {
        $script:AutoChart04ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart04ADGroups3DInclination
        $script:AutoChart04ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart04ADGroups3DInclination)"
#        $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
#        $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart04ADGroups3DInclination = 0
        $script:AutoChart04ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart04ADGroups3DInclination
        $script:AutoChart04ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
#        $script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
})
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart04ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04ADGroups3DToggleButton.Location.X + $script:AutoChart04ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ADGroupsColorsAvailable) { $script:AutoChart04ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADGroups.Series["Modified"].Color = $script:AutoChart04ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart04ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Modified' -eq $($script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart04ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADGroupsImportCsvPosResults) { $script:AutoChart04ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart04ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ADGroupsImportCsvPosResults) { $script:AutoChart04ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADGroupsImportCsvNegResults) { $script:AutoChart04ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ADGroupsImportCsvPosResults.count))"
    $script:AutoChart04ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart04ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsCheckDiffButton
$script:AutoChart04ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart04ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Modified' -ExpandProperty 'Modified' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart04ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ADGroupsInvestDiffDropDownArray) { $script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADGroups }})
    $script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart04ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsInvestDiffExecuteButton
    $script:AutoChart04ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADGroups }})
    $script:AutoChart04ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart04ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart04ADGroupsInvestDiffDropDownLabel,$script:AutoChart04ADGroupsInvestDiffDropDownComboBox,$script:AutoChart04ADGroupsInvestDiffExecuteButton,$script:AutoChart04ADGroupsInvestDiffPosResultsLabel,$script:AutoChart04ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart04ADGroupsInvestDiffNegResultsLabel,$script:AutoChart04ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart04ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart04ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ADGroupsManipulationPanel.controls.Add($script:AutoChart04ADGroupsCheckDiffButton)


$AutoChart04ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ADGroupsCheckDiffButton.Location.X + $script:AutoChart04ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Modified" -PropertyX "Modified" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart04ADGroupsExpandChartButton
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($AutoChart04ADGroupsExpandChartButton)


$script:AutoChart04ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart04ADGroupsCheckDiffButton.Location.Y + $script:AutoChart04ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsOpenInShell
$script:AutoChart04ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04ADGroupsManipulationPanel.controls.Add($script:AutoChart04ADGroupsOpenInShell)


$script:AutoChart04ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ADGroupsOpenInShell.Location.X + $script:AutoChart04ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsViewResults
$script:AutoChart04ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04ADGroupsManipulationPanel.controls.Add($script:AutoChart04ADGroupsViewResults)


### Save the chart to file
$script:AutoChart04ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart04ADGroupsOpenInShell.Location.Y + $script:AutoChart04ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04ADGroups -Title $script:AutoChart04ADGroupsTitle
})
$script:AutoChart04ADGroupsManipulationPanel.controls.Add($script:AutoChart04ADGroupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart04ADGroupsSaveButton.Location.Y + $script:AutoChart04ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ADGroupsManipulationPanel.Controls.Add($script:AutoChart04ADGroupsNoticeTextbox)

$script:AutoChart04ADGroups.Series["Modified"].Points.Clear()
$script:AutoChart04ADGroupsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart04ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADGroups.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}


















##############################################################################################
# AutoChart05ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03ADGroups.Location.X
                  Y = $script:AutoChart03ADGroups.Location.Y + $script:AutoChart03ADGroups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05ADGroups.Titles.Add($script:AutoChart05ADGroupsTitle)

### Create Charts Area
$script:AutoChart05ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart05ADGroupsArea.AxisX.Title = 'Members'
$script:AutoChart05ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart05ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart05ADGroups.ChartAreas.Add($script:AutoChart05ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05ADGroups.Series.Add("Member Count")
$script:AutoChart05ADGroups.Series["Member Count"].Enabled           = $True
$script:AutoChart05ADGroups.Series["Member Count"].BorderWidth       = 1
$script:AutoChart05ADGroups.Series["Member Count"].IsVisibleInLegend = $false
$script:AutoChart05ADGroups.Series["Member Count"].Chartarea         = 'Chart Area'
$script:AutoChart05ADGroups.Series["Member Count"].Legend            = 'Legend'
$script:AutoChart05ADGroups.Series["Member Count"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05ADGroups.Series["Member Count"]['PieLineColor']   = 'Black'
$script:AutoChart05ADGroups.Series["Member Count"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05ADGroups.Series["Member Count"].ChartType         = 'Column'
$script:AutoChart05ADGroups.Series["Member Count"].Color             = 'Green'

        function Generate-AutoChart05ADGroups {
            $script:AutoChart05ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart05ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Members | Sort-Object Members -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05ADGroups.Series["Members Count"].Points.Clear()

            if ($script:AutoChart05ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart05ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart05ADGroupsTitle.Text = "Member Count"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart05ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05ADGroupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Members -eq $DataField.Members) {
                            $Count += 1
                            if ( $script:AutoChart05ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart05ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart05ADGroupsUniqueCount = $script:AutoChart05ADGroupsCsvComputers.Count
                    $script:AutoChart05ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05ADGroupsUniqueCount
                        Computers   = $script:AutoChart05ADGroupsCsvComputers
                    }
                    $script:AutoChart05ADGroupsOverallDataResults += $script:AutoChart05ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05ADGroupsOverallDataResults | Sort-Object TotalCount | ForEach-Object { $script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount) }

                $script:AutoChart05ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADGroupsOverallDataResults.count))
                $script:AutoChart05ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart05ADGroupsTitle.ForeColor = 'Brown'
                $script:AutoChart05ADGroupsTitle.Text = "Members`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart05ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsOptionsButton
$script:AutoChart05ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart05ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart05ADGroups.Controls.Add($script:AutoChart05ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart05ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart05ADGroups.Controls.Remove($script:AutoChart05ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADGroups)

$script:AutoChart05ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADGroupsOverallDataResults.count))
    $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart05ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
        $script:AutoChart05ADGroupsOverallDataResults | Sort-Object TotalCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
    })
    $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ADGroupsTrimOffFirstTrackBar)
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADGroupsOverallDataResults.count))
    $script:AutoChart05ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart05ADGroupsOverallDataResults.count)
    $script:AutoChart05ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart05ADGroupsOverallDataResults.count) - $script:AutoChart05ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart05ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ADGroupsOverallDataResults.count) - $script:AutoChart05ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
        $script:AutoChart05ADGroupsOverallDataResults | Sort-Object TotalCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
    })
$script:AutoChart05ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart05ADGroupsTrimOffLastTrackBar)
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADGroups.Series["Member Count"].ChartType = $script:AutoChart05ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
#    $script:AutoChart05ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
})
$script:AutoChart05ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ADGroupsChartTypesAvailable) { $script:AutoChart05ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ADGroupsChartTypeComboBox.Location.X + $script:AutoChart05ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroups3DToggleButton
$script:AutoChart05ADGroups3DInclination = 0
$script:AutoChart05ADGroups3DToggleButton.Add_Click({
    $script:AutoChart05ADGroups3DInclination += 10
    if ( $script:AutoChart05ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart05ADGroups3DInclination
        $script:AutoChart05ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart05ADGroups3DInclination)"
#        $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
#        $script:AutoChart05ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
    }
    elseif ( $script:AutoChart05ADGroups3DInclination -le 90 ) {
        $script:AutoChart05ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart05ADGroups3DInclination
        $script:AutoChart05ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart05ADGroups3DInclination)"
#        $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
#        $script:AutoChart05ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
    }
    else {
        $script:AutoChart05ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart05ADGroups3DInclination = 0
        $script:AutoChart05ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart05ADGroups3DInclination
        $script:AutoChart05ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
#        $script:AutoChart05ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}
    }
})
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart05ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05ADGroups3DToggleButton.Location.X + $script:AutoChart05ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ADGroupsColorsAvailable) { $script:AutoChart05ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADGroups.Series["Member Count"].Color = $script:AutoChart05ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart05ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Members' -eq $($script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart05ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADGroupsImportCsvPosResults) { $script:AutoChart05ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart05ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ADGroupsImportCsvPosResults) { $script:AutoChart05ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADGroupsImportCsvNegResults) { $script:AutoChart05ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ADGroupsImportCsvPosResults.count))"
    $script:AutoChart05ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart05ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsCheckDiffButton
$script:AutoChart05ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart05ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Members' -ExpandProperty 'Members' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart05ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ADGroupsInvestDiffDropDownArray) { $script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADGroups }})
    $script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart05ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsInvestDiffExecuteButton
    $script:AutoChart05ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADGroups }})
    $script:AutoChart05ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart05ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart05ADGroupsInvestDiffDropDownLabel,$script:AutoChart05ADGroupsInvestDiffDropDownComboBox,$script:AutoChart05ADGroupsInvestDiffExecuteButton,$script:AutoChart05ADGroupsInvestDiffPosResultsLabel,$script:AutoChart05ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart05ADGroupsInvestDiffNegResultsLabel,$script:AutoChart05ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart05ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart05ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ADGroupsManipulationPanel.controls.Add($script:AutoChart05ADGroupsCheckDiffButton)


$AutoChart05ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ADGroupsCheckDiffButton.Location.X + $script:AutoChart05ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Member Count" -PropertyX "Member Count" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart05ADGroupsExpandChartButton
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($AutoChart05ADGroupsExpandChartButton)


$script:AutoChart05ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart05ADGroupsCheckDiffButton.Location.Y + $script:AutoChart05ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsOpenInShell
$script:AutoChart05ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05ADGroupsManipulationPanel.controls.Add($script:AutoChart05ADGroupsOpenInShell)


$script:AutoChart05ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ADGroupsOpenInShell.Location.X + $script:AutoChart05ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsViewResults
$script:AutoChart05ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05ADGroupsManipulationPanel.controls.Add($script:AutoChart05ADGroupsViewResults)


### Save the chart to file
$script:AutoChart05ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart05ADGroupsOpenInShell.Location.Y + $script:AutoChart05ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05ADGroups -Title $script:AutoChart05ADGroupsTitle
})
$script:AutoChart05ADGroupsManipulationPanel.controls.Add($script:AutoChart05ADGroupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart05ADGroupsSaveButton.Location.Y + $script:AutoChart05ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ADGroupsManipulationPanel.Controls.Add($script:AutoChart05ADGroupsNoticeTextbox)

$script:AutoChart05ADGroups.Series["Member Count"].Points.Clear()
$script:AutoChart05ADGroupsOverallDataResults | Sort-Object TotalCount | Select-Object -skip $script:AutoChart05ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADGroups.Series["Member Count"].Points.AddXY($_.DataField.Members,$_.TotalCount)}






















##############################################################################################
# AutoChart06ADGroups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06ADGroups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04ADGroups.Location.X
                  Y = $script:AutoChart04ADGroups.Location.Y + $script:AutoChart04ADGroups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06ADGroups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06ADGroupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06ADGroups.Titles.Add($script:AutoChart06ADGroupsTitle)

### Create Charts Area
$script:AutoChart06ADGroupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ADGroupsArea.Name        = 'Chart Area'
$script:AutoChart06ADGroupsArea.AxisX.Title = 'Hosts'
$script:AutoChart06ADGroupsArea.AxisX.Interval          = 1
$script:AutoChart06ADGroupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ADGroupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ADGroupsArea.Area3DStyle.Inclination = 75
$script:AutoChart06ADGroups.ChartAreas.Add($script:AutoChart06ADGroupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06ADGroups.Series.Add("MemberOf")
$script:AutoChart06ADGroups.Series["MemberOf"].Enabled           = $True
$script:AutoChart06ADGroups.Series["MemberOf"].BorderWidth       = 1
$script:AutoChart06ADGroups.Series["MemberOf"].IsVisibleInLegend = $false
$script:AutoChart06ADGroups.Series["MemberOf"].Chartarea         = 'Chart Area'
$script:AutoChart06ADGroups.Series["MemberOf"].Legend            = 'Legend'
$script:AutoChart06ADGroups.Series["MemberOf"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06ADGroups.Series["MemberOf"]['PieLineColor']   = 'Black'
$script:AutoChart06ADGroups.Series["MemberOf"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06ADGroups.Series["MemberOf"].ChartType         = 'Column'
$script:AutoChart06ADGroups.Series["MemberOf"].Color             = 'Gray'

        function Generate-AutoChart06ADGroups {
            $script:AutoChart06ADGroupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart06ADGroupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object MemberOf | Sort-Object MemberOf -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ADGroupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()

            if ($script:AutoChart06ADGroupsUniqueDataFields.count -gt 0){
                $script:AutoChart06ADGroupsTitle.ForeColor = 'Black'
                $script:AutoChart06ADGroupsTitle.Text = "Member Of Count"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart06ADGroupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06ADGroupsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06ADGroupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.MemberOf) -eq $DataField.MemberOf) {
                            $Count += 1
                            if ( $script:AutoChart06ADGroupsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart06ADGroupsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart06ADGroupsUniqueCount = $script:AutoChart06ADGroupsCsvComputers.Count
                    $script:AutoChart06ADGroupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06ADGroupsUniqueCount
                        Computers   = $script:AutoChart06ADGroupsCsvComputers
                    }
                    $script:AutoChart06ADGroupsOverallDataResults += $script:AutoChart06ADGroupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount) }

                $script:AutoChart06ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADGroupsOverallDataResults.count))
                $script:AutoChart06ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADGroupsOverallDataResults.count))
            }
            else {
                $script:AutoChart06ADGroupsTitle.ForeColor = 'Red'
                $script:AutoChart06ADGroupsTitle.Text = "MemberOf`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart06ADGroups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06ADGroupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06ADGroups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06ADGroups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsOptionsButton
$script:AutoChart06ADGroupsOptionsButton.Add_Click({
    if ($script:AutoChart06ADGroupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ADGroupsOptionsButton.Text = 'Options ^'
        $script:AutoChart06ADGroups.Controls.Add($script:AutoChart06ADGroupsManipulationPanel)
    }
    elseif ($script:AutoChart06ADGroupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ADGroupsOptionsButton.Text = 'Options v'
        $script:AutoChart06ADGroups.Controls.Remove($script:AutoChart06ADGroupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADGroupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADGroups)

$script:AutoChart06ADGroupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06ADGroups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06ADGroups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ADGroupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ADGroupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ADGroupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADGroupsOverallDataResults.count))
    $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ADGroupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue = $script:AutoChart06ADGroupsTrimOffFirstTrackBar.Value
        $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ADGroupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
        $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
    })
    $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ADGroupsTrimOffFirstTrackBar)
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ADGroupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Location.X + $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ADGroupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ADGroupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ADGroupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADGroupsOverallDataResults.count))
    $script:AutoChart06ADGroupsTrimOffLastTrackBar.Value         = $($script:AutoChart06ADGroupsOverallDataResults.count)
    $script:AutoChart06ADGroupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ADGroupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ADGroupsTrimOffLastTrackBarValue = $($script:AutoChart06ADGroupsOverallDataResults.count) - $script:AutoChart06ADGroupsTrimOffLastTrackBar.Value
        $script:AutoChart06ADGroupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ADGroupsOverallDataResults.count) - $script:AutoChart06ADGroupsTrimOffLastTrackBar.Value)"
        $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
        $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
    })
$script:AutoChart06ADGroupsTrimOffLastGroupBox.Controls.Add($script:AutoChart06ADGroupsTrimOffLastTrackBar)
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ADGroupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ADGroupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADGroupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADGroups.Series["MemberOf"].ChartType = $script:AutoChart06ADGroupsChartTypeComboBox.SelectedItem
#    $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
#    $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
})
$script:AutoChart06ADGroupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ADGroupsChartTypesAvailable) { $script:AutoChart06ADGroupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06ADGroups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ADGroupsChartTypeComboBox.Location.X + $script:AutoChart06ADGroupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ADGroupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroups3DToggleButton
$script:AutoChart06ADGroups3DInclination = 0
$script:AutoChart06ADGroups3DToggleButton.Add_Click({
    $script:AutoChart06ADGroups3DInclination += 10
    if ( $script:AutoChart06ADGroups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06ADGroupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart06ADGroups3DInclination
        $script:AutoChart06ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart06ADGroups3DInclination)"
#        $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
#        $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06ADGroups3DInclination -le 90 ) {
        $script:AutoChart06ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart06ADGroups3DInclination
        $script:AutoChart06ADGroups3DToggleButton.Text  = "3D On ($script:AutoChart06ADGroups3DInclination)"
#        $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
#        $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06ADGroups3DToggleButton.Text  = "3D Off"
        $script:AutoChart06ADGroups3DInclination = 0
        $script:AutoChart06ADGroupsArea.Area3DStyle.Inclination = $script:AutoChart06ADGroups3DInclination
        $script:AutoChart06ADGroupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
#        $script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}
    }
})
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroups3DToggleButton)

### Change the color of the chart
$script:AutoChart06ADGroupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06ADGroups3DToggleButton.Location.X + $script:AutoChart06ADGroups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADGroups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADGroupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ADGroupsColorsAvailable) { $script:AutoChart06ADGroupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ADGroupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADGroups.Series["MemberOf"].Color = $script:AutoChart06ADGroupsChangeColorComboBox.SelectedItem
})
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06ADGroups {
    # List of Positive Endpoints that positively match
    $script:AutoChart06ADGroupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'MemberOf' -eq $($script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart06ADGroupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADGroupsImportCsvPosResults) { $script:AutoChart06ADGroupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ADGroupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart06ADGroupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ADGroupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ADGroupsImportCsvPosResults) { $script:AutoChart06ADGroupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ADGroupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADGroupsImportCsvNegResults) { $script:AutoChart06ADGroupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ADGroupsImportCsvPosResults.count))"
    $script:AutoChart06ADGroupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ADGroupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ADGroupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ADGroupsTrimOffLastGroupBox.Location.X + $script:AutoChart06ADGroupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADGroupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsCheckDiffButton
$script:AutoChart06ADGroupsCheckDiffButton.Add_Click({
    $script:AutoChart06ADGroupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'MemberOf' -ExpandProperty 'MemberOf' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ADGroupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ADGroupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADGroupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADGroupsInvestDiffDropDownLabel.Location.y + $script:AutoChart06ADGroupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ADGroupsInvestDiffDropDownArray) { $script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADGroups }})
    $script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06ADGroups })

    ### Investigate Difference Execute Button
    $script:AutoChart06ADGroupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ADGroupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsInvestDiffExecuteButton
    $script:AutoChart06ADGroupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADGroups }})
    $script:AutoChart06ADGroupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06ADGroups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ADGroupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADGroupsInvestDiffExecuteButton.Location.y + $script:AutoChart06ADGroupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADGroupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ADGroupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06ADGroupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADGroupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ADGroupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ADGroupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ADGroupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ADGroupsInvestDiffForm.Controls.AddRange(@($script:AutoChart06ADGroupsInvestDiffDropDownLabel,$script:AutoChart06ADGroupsInvestDiffDropDownComboBox,$script:AutoChart06ADGroupsInvestDiffExecuteButton,$script:AutoChart06ADGroupsInvestDiffPosResultsLabel,$script:AutoChart06ADGroupsInvestDiffPosResultsTextBox,$script:AutoChart06ADGroupsInvestDiffNegResultsLabel,$script:AutoChart06ADGroupsInvestDiffNegResultsTextBox))
    $script:AutoChart06ADGroupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ADGroupsInvestDiffForm.ShowDialog()
})
$script:AutoChart06ADGroupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ADGroupsManipulationPanel.controls.Add($script:AutoChart06ADGroupsCheckDiffButton)


$AutoChart06ADGroupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ADGroupsCheckDiffButton.Location.X + $script:AutoChart06ADGroupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ADGroupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "MemberOfes" -PropertyX "MemberOf" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart06ADGroupsExpandChartButton
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($AutoChart06ADGroupsExpandChartButton)


$script:AutoChart06ADGroupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ADGroupsCheckDiffButton.Location.X
                   Y = $script:AutoChart06ADGroupsCheckDiffButton.Location.Y + $script:AutoChart06ADGroupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsOpenInShell
$script:AutoChart06ADGroupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06ADGroupsManipulationPanel.controls.Add($script:AutoChart06ADGroupsOpenInShell)


$script:AutoChart06ADGroupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ADGroupsOpenInShell.Location.X + $script:AutoChart06ADGroupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADGroupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsViewResults
$script:AutoChart06ADGroupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06ADGroupsManipulationPanel.controls.Add($script:AutoChart06ADGroupsViewResults)


### Save the chart to file
$script:AutoChart06ADGroupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ADGroupsOpenInShell.Location.X
                  Y = $script:AutoChart06ADGroupsOpenInShell.Location.Y + $script:AutoChart06ADGroupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADGroupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ADGroupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06ADGroups -Title $script:AutoChart06ADGroupsTitle
})
$script:AutoChart06ADGroupsManipulationPanel.controls.Add($script:AutoChart06ADGroupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ADGroupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ADGroupsSaveButton.Location.X
                        Y = $script:AutoChart06ADGroupsSaveButton.Location.Y + $script:AutoChart06ADGroupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ADGroupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ADGroupsManipulationPanel.Controls.Add($script:AutoChart06ADGroupsNoticeTextbox)

$script:AutoChart06ADGroups.Series["MemberOf"].Points.Clear()
$script:AutoChart06ADGroupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADGroupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADGroupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADGroups.Series["MemberOf"].Points.AddXY($_.DataField.MemberOf,$_.UniqueCount)}














# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIbnFK/amMf0iF0SbYo+PKK/a
# VLKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWzfLv4Vdq85BorrUfjvvMAs5BeYwDQYJKoZI
# hvcNAQEBBQAEggEAjXPjUlaZQg/Gk9PqBmNheFOaUHOL5+Qc2YMuR11As1L9RcMN
# mTgERawJxQfypzcircyMmrqXebQt6Ri2QS0PD5ulSsHrePbcyIhB15Y2auUjyerw
# HqRxDhkn0UPX+dbSW5HR+EgjrvvsHkDdQZiY/3OQjNtV5292Wggnnr4lcBLMwsFQ
# LJKXw3g/ibpUnEm2epZReqJPFfgyTeKtQ3U+BWcdyYPBY68oUR2zeDBxdifesp9u
# 074Bd66JnGyb1G6nVp68/G0LXufgCItqn1hOoO3d6lQ+UgSV+2EWPdKjx7J6iXCn
# 7dJvsNOQlCOn7dPac2bt59J4SmUeC/F7AFp0hg==
# SIG # End signature block
