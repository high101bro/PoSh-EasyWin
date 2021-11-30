$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Logon Activity'
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

$script:AutoChart01LogonActivityCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Logon Activity' -or $CSVFile -match 'LogonActivity') { $script:AutoChart01LogonActivityCSVFileMatch += $CSVFile } }
}

$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01LogonActivityCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsvLogonActivity = $null
$script:AutoChartDataSourceCsvLogonActivity = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart01LogonActivity.Controls.Remove($script:AutoChart01LogonActivityManipulationPanel)
    $script:AutoChart02LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart02LogonActivity.Controls.Remove($script:AutoChart02LogonActivityManipulationPanel)
    $script:AutoChart03LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart03LogonActivity.Controls.Remove($script:AutoChart03LogonActivityManipulationPanel)
    $script:AutoChart04LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart04LogonActivity.Controls.Remove($script:AutoChart04LogonActivityManipulationPanel)
    $script:AutoChart05LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart05LogonActivity.Controls.Remove($script:AutoChart05LogonActivityManipulationPanel)
    $script:AutoChart06LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart06LogonActivity.Controls.Remove($script:AutoChart06LogonActivityManipulationPanel)
    $script:AutoChart07LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart07LogonActivity.Controls.Remove($script:AutoChart07LogonActivityManipulationPanel)
    $script:AutoChart08LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart08LogonActivity.Controls.Remove($script:AutoChart08LogonActivityManipulationPanel)
    $script:AutoChart09LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart09LogonActivity.Controls.Remove($script:AutoChart09LogonActivityManipulationPanel)
    $script:AutoChart10LogonActivityOptionsButton.Text = 'Options v'
    $script:AutoChart10LogonActivity.Controls.Remove($script:AutoChart10LogonActivityManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Logon Activity'
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

    if (Test-ProfileLoaded $ViewImportResults) {
        $SaveProfileLoaded = Split-ProfileLoaded -ProfileLoaded $script:AutoChartOpenResultsOpenFileDialogfilename
        $FileName = Split-ProfileLoaded -ProfileLoaded $script:AutoChartOpenResultsOpenFileDialogfilename -Leaf

        Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SaveProfileLoaded $SaveProfileLoaded
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}
















##############################################################################################
# AutoChart01
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01LogonActivity.Titles.Add($script:AutoChart01LogonActivityTitle)

### Create Charts Area
$script:AutoChart01LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart01LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart01LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart01LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart01LogonActivity.ChartAreas.Add($script:AutoChart01LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01LogonActivity.Series.Add("Owner")
$script:AutoChart01LogonActivity.Series["Owner"].Enabled           = $True
$script:AutoChart01LogonActivity.Series["Owner"].BorderWidth       = 1
$script:AutoChart01LogonActivity.Series["Owner"].IsVisibleInLegend = $false
$script:AutoChart01LogonActivity.Series["Owner"].Chartarea         = 'Chart Area'
$script:AutoChart01LogonActivity.Series["Owner"].Legend            = 'Legend'
$script:AutoChart01LogonActivity.Series["Owner"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01LogonActivity.Series["Owner"]['PieLineColor']   = 'Black'
$script:AutoChart01LogonActivity.Series["Owner"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01LogonActivity.Series["Owner"].ChartType         = 'Column'
$script:AutoChart01LogonActivity.Series["Owner"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'Owner' | Sort-Object -Property 'Owner' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()

            if ($script:AutoChart01LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart01LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart01LogonActivityTitle.Text = "Owner"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.Owner) -eq $DataField.Owner) {
                            $Count += 1
                            if ( $script:AutoChart01LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01LogonActivityUniqueCount = $script:AutoChart01LogonActivityCsvComputers.Count
                    $script:AutoChart01LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01LogonActivityUniqueCount
                        Computers   = $script:AutoChart01LogonActivityCsvComputers
                    }
                    $script:AutoChart01LogonActivityOverallDataResults += $script:AutoChart01LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01LogonActivityOverallDataResults.count))
                $script:AutoChart01LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart01LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart01LogonActivityTitle.Text = "Owner`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivityOptionsButton
$script:AutoChart01LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart01LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart01LogonActivity.Controls.Add($script:AutoChart01LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart01LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart01LogonActivity.Controls.Remove($script:AutoChart01LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01LogonActivity)

$script:AutoChart01LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart01LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01LogonActivityOverallDataResults.count))
    $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart01LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
        $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    })
    $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart01LogonActivityTrimOffFirstTrackBar)
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01LogonActivityOverallDataResults.count))
    $script:AutoChart01LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart01LogonActivityOverallDataResults.count)
    $script:AutoChart01LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart01LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart01LogonActivityOverallDataResults.count) - $script:AutoChart01LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart01LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01LogonActivityOverallDataResults.count) - $script:AutoChart01LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
        $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    })
$script:AutoChart01LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart01LogonActivityTrimOffLastTrackBar)
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart01LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01LogonActivity.Series["Owner"].ChartType = $script:AutoChart01LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
#    $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
})
$script:AutoChart01LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01LogonActivityChartTypesAvailable) { $script:AutoChart01LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivityChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01LogonActivityChartTypeComboBox.Location.X + $script:AutoChart01LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivity3DToggleButton
$script:AutoChart01LogonActivity3DInclination = 0
$script:AutoChart01LogonActivity3DToggleButton.Add_Click({

    $script:AutoChart01LogonActivity3DInclination += 10
    if ( $script:AutoChart01LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart01LogonActivity3DInclination
        $script:AutoChart01LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart01LogonActivity3DInclination)"
#        $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01LogonActivity3DInclination -le 90 ) {
        $script:AutoChart01LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart01LogonActivity3DInclination
        $script:AutoChart01LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart01LogonActivity3DInclination)"
#        $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart01LogonActivity3DInclination = 0
        $script:AutoChart01LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart01LogonActivity3DInclination
        $script:AutoChart01LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
})
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart01LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01LogonActivity3DToggleButton.Location.X + $script:AutoChart01LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01LogonActivityColorsAvailable) { $script:AutoChart01LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01LogonActivity.Series["Owner"].Color = $script:AutoChart01LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'Owner' -eq $($script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01LogonActivityImportCsvPosResults) { $script:AutoChart01LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart01LogonActivityImportCsvPosResults) { $script:AutoChart01LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01LogonActivityImportCsvNegResults) { $script:AutoChart01LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01LogonActivityImportCsvPosResults.count))"
    $script:AutoChart01LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart01LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivityCheckDiffButton
$script:AutoChart01LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart01LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'Owner' -ExpandProperty 'Owner' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart01LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01LogonActivityInvestDiffDropDownArray) { $script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart01LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivityInvestDiffExecuteButton
    $script:AutoChart01LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart01LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart01LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart01LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart01LogonActivityInvestDiffDropDownLabel,$script:AutoChart01LogonActivityInvestDiffDropDownComboBox,$script:AutoChart01LogonActivityInvestDiffExecuteButton,$script:AutoChart01LogonActivityInvestDiffPosResultsLabel,$script:AutoChart01LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart01LogonActivityInvestDiffNegResultsLabel,$script:AutoChart01LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart01LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart01LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01LogonActivityManipulationPanel.controls.Add($script:AutoChart01LogonActivityCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01LogonActivityCheckDiffButton.Location.X + $script:AutoChart01LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Owner" -PropertyX "Owner" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart01LogonActivityCheckDiffButton.Location.Y + $script:AutoChart01LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivityOpenInShell
$script:AutoChart01LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01LogonActivityManipulationPanel.controls.Add($script:AutoChart01LogonActivityOpenInShell)


$script:AutoChart01LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01LogonActivityOpenInShell.Location.X + $script:AutoChart01LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivityViewResults
$script:AutoChart01LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01LogonActivityManipulationPanel.controls.Add($script:AutoChart01LogonActivityViewResults)


### Save the chart to file
$script:AutoChart01LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart01LogonActivityOpenInShell.Location.Y + $script:AutoChart01LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01LogonActivity -Title $script:AutoChart01LogonActivityTitle
})
$script:AutoChart01LogonActivityManipulationPanel.controls.Add($script:AutoChart01LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart01LogonActivitySaveButton.Location.Y + $script:AutoChart01LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01LogonActivityManipulationPanel.Controls.Add($script:AutoChart01LogonActivityNoticeTextbox)

$script:AutoChart01LogonActivity.Series["Owner"].Points.Clear()
$script:AutoChart01LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LogonActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01LogonActivity.Location.X + $script:AutoChart01LogonActivity.Size.Width + $($FormScale *  20)
                  Y = $script:AutoChart01LogonActivity.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02LogonActivity.Titles.Add($script:AutoChart02LogonActivityTitle)

### Create Charts Area
$script:AutoChart02LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart02LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart02LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart02LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart02LogonActivity.ChartAreas.Add($script:AutoChart02LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02LogonActivity.Series.Add("Connections Per Host")
$script:AutoChart02LogonActivity.Series["Connections Per Host"].Enabled           = $True
$script:AutoChart02LogonActivity.Series["Connections Per Host"].BorderWidth       = 1
$script:AutoChart02LogonActivity.Series["Connections Per Host"].IsVisibleInLegend = $false
$script:AutoChart02LogonActivity.Series["Connections Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02LogonActivity.Series["Connections Per Host"].Legend            = 'Legend'
$script:AutoChart02LogonActivity.Series["Connections Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02LogonActivity.Series["Connections Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02LogonActivity.Series["Connections Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02LogonActivity.Series["Connections Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02LogonActivity.Series["Connections Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02LogonActivityCsvFileHosts     = ($script:AutoChartDataSourceCsvLogonActivity).PSComputerName | Sort-Object -Unique
            $script:AutoChart02LogonActivityUniqueDataFields = ($script:AutoChartDataSourceCsvLogonActivity).ProcessID | Sort-Object -Property 'ProcessID'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart02LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart02LogonActivityTitle.Text = "Connections Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02LogonActivityOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvLogonActivity | Sort-Object PSComputerName) ) {
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.PSComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart02CurrentComputer ) {
                            $AutoChart02CurrentComputer = $Line.PSComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer
                            }
                            $script:AutoChart02LogonActivityOverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }
                $script:AutoChart02LogonActivityOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02LogonActivityOverallDataResults | ForEach-Object { $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
                $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02LogonActivityOverallDataResults.count))
                $script:AutoChart02LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
                $script:AutoChart02LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart02LogonActivityTitle.Text = "Connections Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivityOptionsButton
$script:AutoChart02LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart02LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart02LogonActivity.Controls.Add($script:AutoChart02LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart02LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart02LogonActivity.Controls.Remove($script:AutoChart02LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02LogonActivity)

$script:AutoChart02LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart02LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02LogonActivityOverallDataResults.count))
    $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart02LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
        $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart02LogonActivityTrimOffFirstTrackBar)
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02LogonActivityOverallDataResults.count))
    $script:AutoChart02LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart02LogonActivityOverallDataResults.count)
    $script:AutoChart02LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart02LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart02LogonActivityOverallDataResults.count) - $script:AutoChart02LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart02LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02LogonActivityOverallDataResults.count) - $script:AutoChart02LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
        $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart02LogonActivityTrimOffLastTrackBar)
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart02LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02LogonActivity.Series["Connections Per Host"].ChartType = $script:AutoChart02LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
#    $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02LogonActivityChartTypesAvailable) { $script:AutoChart02LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02LogonActivityChartTypeComboBox.Location.X + $script:AutoChart02LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivity3DToggleButton
$script:AutoChart02LogonActivity3DInclination = 0
$script:AutoChart02LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart02LogonActivity3DInclination += 10
    if ( $script:AutoChart02LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart02LogonActivity3DInclination
        $script:AutoChart02LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart02LogonActivity3DInclination)"
#        $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02LogonActivity3DInclination -le 90 ) {
        $script:AutoChart02LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart02LogonActivity3DInclination
        $script:AutoChart02LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart02LogonActivity3DInclination)"
#        $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart02LogonActivity3DInclination = 0
        $script:AutoChart02LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart02LogonActivity3DInclination
        $script:AutoChart02LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart02LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02LogonActivity3DToggleButton.Location.X + $script:AutoChart02LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02LogonActivityColorsAvailable) { $script:AutoChart02LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02LogonActivity.Series["Connections Per Host"].Color = $script:AutoChart02LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'Name' -eq $($script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02LogonActivityImportCsvPosResults) { $script:AutoChart02LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart02LogonActivityImportCsvPosResults) { $script:AutoChart02LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02LogonActivityImportCsvNegResults) { $script:AutoChart02LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02LogonActivityImportCsvPosResults.count))"
    $script:AutoChart02LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart02LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivityCheckDiffButton
$script:AutoChart02LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart02LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart02LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02LogonActivityInvestDiffDropDownArray) { $script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart02LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivityInvestDiffExecuteButton
    $script:AutoChart02LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart02LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart02LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart02LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart02LogonActivityInvestDiffDropDownLabel,$script:AutoChart02LogonActivityInvestDiffDropDownComboBox,$script:AutoChart02LogonActivityInvestDiffExecuteButton,$script:AutoChart02LogonActivityInvestDiffPosResultsLabel,$script:AutoChart02LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart02LogonActivityInvestDiffNegResultsLabel,$script:AutoChart02LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart02LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart02LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02LogonActivityManipulationPanel.controls.Add($script:AutoChart02LogonActivityCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02LogonActivityCheckDiffButton.Location.X + $script:AutoChart02LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Logons per Endpoint" -PropertyX "PSComputerName" -PropertyY "ProcessID" }
}
Apply-CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart02LogonActivityCheckDiffButton.Location.Y + $script:AutoChart02LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivityOpenInShell
$script:AutoChart02LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02LogonActivityManipulationPanel.controls.Add($script:AutoChart02LogonActivityOpenInShell)


$script:AutoChart02LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02LogonActivityOpenInShell.Location.X + $script:AutoChart02LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivityViewResults
$script:AutoChart02LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02LogonActivityManipulationPanel.controls.Add($script:AutoChart02LogonActivityViewResults)


### Save the chart to file
$script:AutoChart02LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart02LogonActivityOpenInShell.Location.Y + $script:AutoChart02LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02LogonActivity -Title $script:AutoChart02LogonActivityTitle
})
$script:AutoChart02LogonActivityManipulationPanel.controls.Add($script:AutoChart02LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart02LogonActivitySaveButton.Location.Y + $script:AutoChart02LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02LogonActivityManipulationPanel.Controls.Add($script:AutoChart02LogonActivityNoticeTextbox)

$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.Clear()
$script:AutoChart02LogonActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LogonActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01LogonActivity.Location.X
                  Y = $script:AutoChart01LogonActivity.Location.Y + $script:AutoChart01LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03LogonActivity.Titles.Add($script:AutoChart03LogonActivityTitle)

### Create Charts Area
$script:AutoChart03LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart03LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart03LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart03LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart03LogonActivity.ChartAreas.Add($script:AutoChart03LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03LogonActivity.Series.Add("Client IP")
$script:AutoChart03LogonActivity.Series["Client IP"].Enabled           = $True
$script:AutoChart03LogonActivity.Series["Client IP"].BorderWidth       = 1
$script:AutoChart03LogonActivity.Series["Client IP"].IsVisibleInLegend = $false
$script:AutoChart03LogonActivity.Series["Client IP"].Chartarea         = 'Chart Area'
$script:AutoChart03LogonActivity.Series["Client IP"].Legend            = 'Legend'
$script:AutoChart03LogonActivity.Series["Client IP"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03LogonActivity.Series["Client IP"]['PieLineColor']   = 'Black'
$script:AutoChart03LogonActivity.Series["Client IP"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03LogonActivity.Series["Client IP"].ChartType         = 'Column'
$script:AutoChart03LogonActivity.Series["Client IP"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ClientIP' | Sort-Object -Property 'ClientIP' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()

            if ($script:AutoChart03LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart03LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart03LogonActivityTitle.Text = "Client IP"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($Line.ClientIP -eq $DataField.ClientIP) {
                            $Count += 1
                            if ( $script:AutoChart03LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03LogonActivityUniqueCount = $script:AutoChart03LogonActivityCsvComputers.Count
                    $script:AutoChart03LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03LogonActivityUniqueCount
                        Computers   = $script:AutoChart03LogonActivityCsvComputers
                    }
                    $script:AutoChart03LogonActivityOverallDataResults += $script:AutoChart03LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount) }

                $script:AutoChart03LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03LogonActivityOverallDataResults.count))
                $script:AutoChart03LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart03LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart03LogonActivityTitle.Text = "Client IP`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivityOptionsButton
$script:AutoChart03LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart03LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart03LogonActivity.Controls.Add($script:AutoChart03LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart03LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart03LogonActivity.Controls.Remove($script:AutoChart03LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03LogonActivity)

$script:AutoChart03LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart03LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03LogonActivityOverallDataResults.count))
    $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart03LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
        $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    })
    $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart03LogonActivityTrimOffFirstTrackBar)
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03LogonActivityOverallDataResults.count))
    $script:AutoChart03LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart03LogonActivityOverallDataResults.count)
    $script:AutoChart03LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart03LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart03LogonActivityOverallDataResults.count) - $script:AutoChart03LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart03LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03LogonActivityOverallDataResults.count) - $script:AutoChart03LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
        $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    })
$script:AutoChart03LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart03LogonActivityTrimOffLastTrackBar)
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart03LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03LogonActivity.Series["Client IP"].ChartType = $script:AutoChart03LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
#    $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
})
$script:AutoChart03LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03LogonActivityChartTypesAvailable) { $script:AutoChart03LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03LogonActivityChartTypeComboBox.Location.X + $script:AutoChart03LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivity3DToggleButton
$script:AutoChart03LogonActivity3DInclination = 0
$script:AutoChart03LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart03LogonActivity3DInclination += 10
    if ( $script:AutoChart03LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart03LogonActivity3DInclination
        $script:AutoChart03LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart03LogonActivity3DInclination)"
#        $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03LogonActivity3DInclination -le 90 ) {
        $script:AutoChart03LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart03LogonActivity3DInclination
        $script:AutoChart03LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart03LogonActivity3DInclination)"
#        $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart03LogonActivity3DInclination = 0
        $script:AutoChart03LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart03LogonActivity3DInclination
        $script:AutoChart03LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
})
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart03LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03LogonActivity3DToggleButton.Location.X + $script:AutoChart03LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03LogonActivityColorsAvailable) { $script:AutoChart03LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03LogonActivity.Series["Client IP"].Color = $script:AutoChart03LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'ClientIP' -eq $($script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03LogonActivityImportCsvPosResults) { $script:AutoChart03LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart03LogonActivityImportCsvPosResults) { $script:AutoChart03LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03LogonActivityImportCsvNegResults) { $script:AutoChart03LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03LogonActivityImportCsvPosResults.count))"
    $script:AutoChart03LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart03LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivityCheckDiffButton
$script:AutoChart03LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart03LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ClientIP' -ExpandProperty 'ClientIP' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart03LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03LogonActivityInvestDiffDropDownArray) { $script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart03LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivityInvestDiffExecuteButton
    $script:AutoChart03LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart03LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart03LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart03LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart03LogonActivityInvestDiffDropDownLabel,$script:AutoChart03LogonActivityInvestDiffDropDownComboBox,$script:AutoChart03LogonActivityInvestDiffExecuteButton,$script:AutoChart03LogonActivityInvestDiffPosResultsLabel,$script:AutoChart03LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart03LogonActivityInvestDiffNegResultsLabel,$script:AutoChart03LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart03LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart03LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03LogonActivityManipulationPanel.controls.Add($script:AutoChart03LogonActivityCheckDiffButton)


$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03LogonActivityCheckDiffButton.Location.X + $script:AutoChart03LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Client IP" -PropertyX "ClientIP" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart03LogonActivityCheckDiffButton.Location.Y + $script:AutoChart03LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivityOpenInShell
$script:AutoChart03LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03LogonActivityManipulationPanel.controls.Add($script:AutoChart03LogonActivityOpenInShell)


$script:AutoChart03LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03LogonActivityOpenInShell.Location.X + $script:AutoChart03LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivityViewResults
$script:AutoChart03LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03LogonActivityManipulationPanel.controls.Add($script:AutoChart03LogonActivityViewResults)


### Save the chart to file
$script:AutoChart03LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart03LogonActivityOpenInShell.Location.Y + $script:AutoChart03LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03LogonActivity -Title $script:AutoChart03LogonActivityTitle
})
$script:AutoChart03LogonActivityManipulationPanel.controls.Add($script:AutoChart03LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart03LogonActivitySaveButton.Location.Y + $script:AutoChart03LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03LogonActivityManipulationPanel.Controls.Add($script:AutoChart03LogonActivityNoticeTextbox)

$script:AutoChart03LogonActivity.Series["Client IP"].Points.Clear()
$script:AutoChart03LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LogonActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02LogonActivity.Location.X
                  Y = $script:AutoChart02LogonActivity.Location.Y + $script:AutoChart02LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04LogonActivity.Titles.Add($script:AutoChart04LogonActivityTitle)

### Create Charts Area
$script:AutoChart04LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart04LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart04LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart04LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart04LogonActivity.ChartAreas.Add($script:AutoChart04LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04LogonActivity.Series.Add("Connection State")
$script:AutoChart04LogonActivity.Series["Connection State"].Enabled           = $True
$script:AutoChart04LogonActivity.Series["Connection State"].BorderWidth       = 1
$script:AutoChart04LogonActivity.Series["Connection State"].IsVisibleInLegend = $false
$script:AutoChart04LogonActivity.Series["Connection State"].Chartarea         = 'Chart Area'
$script:AutoChart04LogonActivity.Series["Connection State"].Legend            = 'Legend'
$script:AutoChart04LogonActivity.Series["Connection State"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04LogonActivity.Series["Connection State"]['PieLineColor']   = 'Black'
$script:AutoChart04LogonActivity.Series["Connection State"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04LogonActivity.Series["Connection State"].ChartType         = 'Column'
$script:AutoChart04LogonActivity.Series["Connection State"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'State' | Sort-Object -Property 'State' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()

            if ($script:AutoChart04LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart04LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart04LogonActivityTitle.Text = "Connection State"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.State) -eq $DataField.State) {
                            $Count += 1
                            if ( $script:AutoChart04LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04LogonActivityUniqueCount = $script:AutoChart04LogonActivityCsvComputers.Count
                    $script:AutoChart04LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04LogonActivityUniqueCount
                        Computers   = $script:AutoChart04LogonActivityCsvComputers
                    }
                    $script:AutoChart04LogonActivityOverallDataResults += $script:AutoChart04LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount) }

                $script:AutoChart04LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04LogonActivityOverallDataResults.count))
                $script:AutoChart04LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart04LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart04LogonActivityTitle.Text = "Connection State`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivityOptionsButton
$script:AutoChart04LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart04LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart04LogonActivity.Controls.Add($script:AutoChart04LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart04LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart04LogonActivity.Controls.Remove($script:AutoChart04LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04LogonActivity)

$script:AutoChart04LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart04LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04LogonActivityOverallDataResults.count))
    $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart04LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
        $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    })
    $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart04LogonActivityTrimOffFirstTrackBar)
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04LogonActivityOverallDataResults.count))
    $script:AutoChart04LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart04LogonActivityOverallDataResults.count)
    $script:AutoChart04LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart04LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart04LogonActivityOverallDataResults.count) - $script:AutoChart04LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart04LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04LogonActivityOverallDataResults.count) - $script:AutoChart04LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
        $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    })
$script:AutoChart04LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart04LogonActivityTrimOffLastTrackBar)
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart04LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04LogonActivity.Series["Connection State"].ChartType = $script:AutoChart04LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
#    $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
})
$script:AutoChart04LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04LogonActivityChartTypesAvailable) { $script:AutoChart04LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04LogonActivityChartTypeComboBox.Location.X + $script:AutoChart04LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivity3DToggleButton
$script:AutoChart04LogonActivity3DInclination = 0
$script:AutoChart04LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart04LogonActivity3DInclination += 10
    if ( $script:AutoChart04LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart04LogonActivity3DInclination
        $script:AutoChart04LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart04LogonActivity3DInclination)"
#        $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04LogonActivity3DInclination -le 90 ) {
        $script:AutoChart04LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart04LogonActivity3DInclination
        $script:AutoChart04LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart04LogonActivity3DInclination)"
#        $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart04LogonActivity3DInclination = 0
        $script:AutoChart04LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart04LogonActivity3DInclination
        $script:AutoChart04LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
})
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart04LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04LogonActivity3DToggleButton.Location.X + $script:AutoChart04LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04LogonActivityColorsAvailable) { $script:AutoChart04LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04LogonActivity.Series["Connection State"].Color = $script:AutoChart04LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'State' -eq $($script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04LogonActivityImportCsvPosResults) { $script:AutoChart04LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart04LogonActivityImportCsvPosResults) { $script:AutoChart04LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04LogonActivityImportCsvNegResults) { $script:AutoChart04LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04LogonActivityImportCsvPosResults.count))"
    $script:AutoChart04LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart04LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivityCheckDiffButton
$script:AutoChart04LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart04LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'State' -ExpandProperty 'State' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart04LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04LogonActivityInvestDiffDropDownArray) { $script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart04LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivityInvestDiffExecuteButton
    $script:AutoChart04LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart04LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart04LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart04LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart04LogonActivityInvestDiffDropDownLabel,$script:AutoChart04LogonActivityInvestDiffDropDownComboBox,$script:AutoChart04LogonActivityInvestDiffExecuteButton,$script:AutoChart04LogonActivityInvestDiffPosResultsLabel,$script:AutoChart04LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart04LogonActivityInvestDiffNegResultsLabel,$script:AutoChart04LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart04LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart04LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04LogonActivityManipulationPanel.controls.Add($script:AutoChart04LogonActivityCheckDiffButton)


$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04LogonActivityCheckDiffButton.Location.X + $script:AutoChart04LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Connection State" -PropertyX "State" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart04LogonActivityCheckDiffButton.Location.Y + $script:AutoChart04LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivityOpenInShell
$script:AutoChart04LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04LogonActivityManipulationPanel.controls.Add($script:AutoChart04LogonActivityOpenInShell)


$script:AutoChart04LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04LogonActivityOpenInShell.Location.X + $script:AutoChart04LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivityViewResults
$script:AutoChart04LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04LogonActivityManipulationPanel.controls.Add($script:AutoChart04LogonActivityViewResults)


### Save the chart to file
$script:AutoChart04LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart04LogonActivityOpenInShell.Location.Y + $script:AutoChart04LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04LogonActivity -Title $script:AutoChart04LogonActivityTitle
})
$script:AutoChart04LogonActivityManipulationPanel.controls.Add($script:AutoChart04LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart04LogonActivitySaveButton.Location.Y + $script:AutoChart04LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04LogonActivityManipulationPanel.Controls.Add($script:AutoChart04LogonActivityNoticeTextbox)

$script:AutoChart04LogonActivity.Series["Connection State"].Points.Clear()
$script:AutoChart04LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LogonActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}




















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03LogonActivity.Location.X
                  Y = $script:AutoChart03LogonActivity.Location.Y + $script:AutoChart03LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05LogonActivity.Titles.Add($script:AutoChart05LogonActivityTitle)

### Create Charts Area
$script:AutoChart05LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart05LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart05LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart05LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart05LogonActivity.ChartAreas.Add($script:AutoChart05LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05LogonActivity.Series.Add("Shell Run Time")
$script:AutoChart05LogonActivity.Series["Shell Run Time"].Enabled           = $True
$script:AutoChart05LogonActivity.Series["Shell Run Time"].BorderWidth       = 1
$script:AutoChart05LogonActivity.Series["Shell Run Time"].IsVisibleInLegend = $false
$script:AutoChart05LogonActivity.Series["Shell Run Time"].Chartarea         = 'Chart Area'
$script:AutoChart05LogonActivity.Series["Shell Run Time"].Legend            = 'Legend'
$script:AutoChart05LogonActivity.Series["Shell Run Time"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05LogonActivity.Series["Shell Run Time"]['PieLineColor']   = 'Black'
$script:AutoChart05LogonActivity.Series["Shell Run Time"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05LogonActivity.Series["Shell Run Time"].ChartType         = 'Bar'
$script:AutoChart05LogonActivity.Series["Shell Run Time"].Color             = 'Orange'

        function Generate-AutoChart05 {
            $script:AutoChart05LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart05LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ShellRunTime' | Sort-Object -Property 'ShellRunTime' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()

            if ($script:AutoChart05LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart05LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart05LogonActivityTitle.Text = "Shell Run Time"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart05LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.ShellRunTime) -eq $DataField.ShellRunTime) {
                            $Count += 1
                            if ( $script:AutoChart05LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart05LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart05LogonActivityUniqueCount = $script:AutoChart05LogonActivityCsvComputers.Count
                    $script:AutoChart05LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05LogonActivityUniqueCount
                        Computers   = $script:AutoChart05LogonActivityCsvComputers
                    }
                    $script:AutoChart05LogonActivityOverallDataResults += $script:AutoChart05LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount) }

                $script:AutoChart05LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05LogonActivityOverallDataResults.count))
                $script:AutoChart05LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart05LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart05LogonActivityTitle.Text = "Shell Run Time`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivityOptionsButton
$script:AutoChart05LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart05LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart05LogonActivity.Controls.Add($script:AutoChart05LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart05LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart05LogonActivity.Controls.Remove($script:AutoChart05LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05LogonActivity)

$script:AutoChart05LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart05LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05LogonActivityOverallDataResults.count))
    $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart05LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
        $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    })
    $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart05LogonActivityTrimOffFirstTrackBar)
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05LogonActivityOverallDataResults.count))
    $script:AutoChart05LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart05LogonActivityOverallDataResults.count)
    $script:AutoChart05LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart05LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart05LogonActivityOverallDataResults.count) - $script:AutoChart05LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart05LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05LogonActivityOverallDataResults.count) - $script:AutoChart05LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
        $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    })
$script:AutoChart05LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart05LogonActivityTrimOffLastTrackBar)
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart05LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05LogonActivity.Series["Shell Run Time"].ChartType = $script:AutoChart05LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
#    $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
})
$script:AutoChart05LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05LogonActivityChartTypesAvailable) { $script:AutoChart05LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05LogonActivityChartTypeComboBox.Location.X + $script:AutoChart05LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivity3DToggleButton
$script:AutoChart05LogonActivity3DInclination = 0
$script:AutoChart05LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart05LogonActivity3DInclination += 10
    if ( $script:AutoChart05LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart05LogonActivity3DInclination
        $script:AutoChart05LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart05LogonActivity3DInclination)"
#        $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05LogonActivity3DInclination -le 90 ) {
        $script:AutoChart05LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart05LogonActivity3DInclination
        $script:AutoChart05LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart05LogonActivity3DInclination)"
#        $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
    else {
        $script:AutoChart05LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart05LogonActivity3DInclination = 0
        $script:AutoChart05LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart05LogonActivity3DInclination
        $script:AutoChart05LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
})
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart05LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05LogonActivity3DToggleButton.Location.X + $script:AutoChart05LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05LogonActivityColorsAvailable) { $script:AutoChart05LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05LogonActivity.Series["Shell Run Time"].Color = $script:AutoChart05LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {
    # List of Positive Endpoints that positively match
    $script:AutoChart05LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'ShellRunTime' -eq $($script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05LogonActivityImportCsvPosResults) { $script:AutoChart05LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart05LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart05LogonActivityImportCsvPosResults) { $script:AutoChart05LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05LogonActivityImportCsvNegResults) { $script:AutoChart05LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05LogonActivityImportCsvPosResults.count))"
    $script:AutoChart05LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart05LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivityCheckDiffButton
$script:AutoChart05LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart05LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ShellRunTime' -ExpandProperty 'ShellRunTime' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart05LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05LogonActivityInvestDiffDropDownArray) { $script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart05LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivityInvestDiffExecuteButton
    $script:AutoChart05LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart05LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart05LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart05LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart05LogonActivityInvestDiffDropDownLabel,$script:AutoChart05LogonActivityInvestDiffDropDownComboBox,$script:AutoChart05LogonActivityInvestDiffExecuteButton,$script:AutoChart05LogonActivityInvestDiffPosResultsLabel,$script:AutoChart05LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart05LogonActivityInvestDiffNegResultsLabel,$script:AutoChart05LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart05LogonActivityInvestDiffForm.add_Load($OnLoadForm_ShellRunTimeCorrection)
    $script:AutoChart05LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart05LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05LogonActivityManipulationPanel.controls.Add($script:AutoChart05LogonActivityCheckDiffButton)


$AutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05LogonActivityCheckDiffButton.Location.X + $script:AutoChart05LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Shell Run Time" -PropertyX "ShellRunTime" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart05LogonActivityCheckDiffButton.Location.Y + $script:AutoChart05LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivityOpenInShell
$script:AutoChart05LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05LogonActivityManipulationPanel.controls.Add($script:AutoChart05LogonActivityOpenInShell)


$script:AutoChart05LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05LogonActivityOpenInShell.Location.X + $script:AutoChart05LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivityViewResults
$script:AutoChart05LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05LogonActivityManipulationPanel.controls.Add($script:AutoChart05LogonActivityViewResults)


### Save the chart to file
$script:AutoChart05LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart05LogonActivityOpenInShell.Location.Y + $script:AutoChart05LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05LogonActivity -Title $script:AutoChart05LogonActivityTitle
})
$script:AutoChart05LogonActivityManipulationPanel.controls.Add($script:AutoChart05LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart05LogonActivitySaveButton.Location.Y + $script:AutoChart05LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05LogonActivityManipulationPanel.Controls.Add($script:AutoChart05LogonActivityNoticeTextbox)

$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.Clear()
$script:AutoChart05LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LogonActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}




















##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04LogonActivity.Location.X
                  Y = $script:AutoChart04LogonActivity.Location.Y + $script:AutoChart04LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06LogonActivity.Titles.Add($script:AutoChart06LogonActivityTitle)

### Create Charts Area
$script:AutoChart06LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart06LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart06LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart06LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart06LogonActivity.ChartAreas.Add($script:AutoChart06LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06LogonActivity.Series.Add("Shell Inactivity Time")
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Enabled           = $True
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].BorderWidth       = 1
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].IsVisibleInLegend = $false
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Chartarea         = 'Chart Area'
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Legend            = 'Legend'
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"]['PieLineColor']   = 'Black'
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].ChartType         = 'Bar'
$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Color             = 'Gray'

        function Generate-AutoChart06 {
            $script:AutoChart06LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart06LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ShellInactivity' | Sort-Object -Property 'ShellInactivity' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()

            if ($script:AutoChart06LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart06LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart06LogonActivityTitle.Text = "Shell Inactivity Time"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart06LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06LogonActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.ShellInactivity) -eq $DataField.ShellInactivity) {
                            $Count += 1
                            if ( $script:AutoChart06LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart06LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart06LogonActivityUniqueCount = $script:AutoChart06LogonActivityCsvComputers.Count
                    $script:AutoChart06LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06LogonActivityUniqueCount
                        Computers   = $script:AutoChart06LogonActivityCsvComputers
                    }
                    $script:AutoChart06LogonActivityOverallDataResults += $script:AutoChart06LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount) }

                $script:AutoChart06LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06LogonActivityOverallDataResults.count))
                $script:AutoChart06LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart06LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart06LogonActivityTitle.Text = "Shell Inactivity Time`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivityOptionsButton
$script:AutoChart06LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart06LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart06LogonActivity.Controls.Add($script:AutoChart06LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart06LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart06LogonActivity.Controls.Remove($script:AutoChart06LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06LogonActivity)

$script:AutoChart06LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart06LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06LogonActivityOverallDataResults.count))
    $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart06LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
        $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    })
    $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart06LogonActivityTrimOffFirstTrackBar)
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06LogonActivityOverallDataResults.count))
    $script:AutoChart06LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart06LogonActivityOverallDataResults.count)
    $script:AutoChart06LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart06LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart06LogonActivityOverallDataResults.count) - $script:AutoChart06LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart06LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06LogonActivityOverallDataResults.count) - $script:AutoChart06LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
        $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    })
$script:AutoChart06LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart06LogonActivityTrimOffLastTrackBar)
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart06LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].ChartType = $script:AutoChart06LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
#    $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
})
$script:AutoChart06LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06LogonActivityChartTypesAvailable) { $script:AutoChart06LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06LogonActivityChartTypeComboBox.Location.X + $script:AutoChart06LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivity3DToggleButton
$script:AutoChart06LogonActivity3DInclination = 0
$script:AutoChart06LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart06LogonActivity3DInclination += 10
    if ( $script:AutoChart06LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart06LogonActivity3DInclination
        $script:AutoChart06LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart06LogonActivity3DInclination)"
#        $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06LogonActivity3DInclination -le 90 ) {
        $script:AutoChart06LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart06LogonActivity3DInclination
        $script:AutoChart06LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart06LogonActivity3DInclination)"
#        $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart06LogonActivity3DInclination = 0
        $script:AutoChart06LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart06LogonActivity3DInclination
        $script:AutoChart06LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
})
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart06LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06LogonActivity3DToggleButton.Location.X + $script:AutoChart06LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06LogonActivityColorsAvailable) { $script:AutoChart06LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Color = $script:AutoChart06LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {
    # List of Positive Endpoints that positively match
    $script:AutoChart06LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'ShellInactivity' -eq $($script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06LogonActivityImportCsvPosResults) { $script:AutoChart06LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart06LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart06LogonActivityImportCsvPosResults) { $script:AutoChart06LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06LogonActivityImportCsvNegResults) { $script:AutoChart06LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06LogonActivityImportCsvPosResults.count))"
    $script:AutoChart06LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart06LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivityCheckDiffButton
$script:AutoChart06LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart06LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ShellInactivity' -ExpandProperty 'ShellInactivity' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart06LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06LogonActivityInvestDiffDropDownArray) { $script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart06LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivityInvestDiffExecuteButton
    $script:AutoChart06LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart06LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart06LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart06LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart06LogonActivityInvestDiffDropDownLabel,$script:AutoChart06LogonActivityInvestDiffDropDownComboBox,$script:AutoChart06LogonActivityInvestDiffExecuteButton,$script:AutoChart06LogonActivityInvestDiffPosResultsLabel,$script:AutoChart06LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart06LogonActivityInvestDiffNegResultsLabel,$script:AutoChart06LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart06LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart06LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06LogonActivityManipulationPanel.controls.Add($script:AutoChart06LogonActivityCheckDiffButton)


$AutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06LogonActivityCheckDiffButton.Location.X + $script:AutoChart06LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Shell Inactivity Timees" -PropertyX "ShellInactivity" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart06LogonActivityCheckDiffButton.Location.Y + $script:AutoChart06LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivityOpenInShell
$script:AutoChart06LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06LogonActivityManipulationPanel.controls.Add($script:AutoChart06LogonActivityOpenInShell)


$script:AutoChart06LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06LogonActivityOpenInShell.Location.X + $script:AutoChart06LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivityViewResults
$script:AutoChart06LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06LogonActivityManipulationPanel.controls.Add($script:AutoChart06LogonActivityViewResults)


### Save the chart to file
$script:AutoChart06LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart06LogonActivityOpenInShell.Location.Y + $script:AutoChart06LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06LogonActivity -Title $script:AutoChart06LogonActivityTitle
})
$script:AutoChart06LogonActivityManipulationPanel.controls.Add($script:AutoChart06LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart06LogonActivitySaveButton.Location.Y + $script:AutoChart06LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06LogonActivityManipulationPanel.Controls.Add($script:AutoChart06LogonActivityNoticeTextbox)

$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.Clear()
$script:AutoChart06LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LogonActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}





















##############################################################################################
# AutoChart07
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05LogonActivity.Location.X
                  Y = $script:AutoChart05LogonActivity.Location.Y + $script:AutoChart05LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart07LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07LogonActivity.Titles.Add($script:AutoChart07LogonActivityTitle)

### Create Charts Area
$script:AutoChart07LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart07LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart07LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart07LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart07LogonActivity.ChartAreas.Add($script:AutoChart07LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07LogonActivity.Series.Add("Child Processes")
$script:AutoChart07LogonActivity.Series["Child Processes"].Enabled           = $True
$script:AutoChart07LogonActivity.Series["Child Processes"].BorderWidth       = 1
$script:AutoChart07LogonActivity.Series["Child Processes"].IsVisibleInLegend = $false
$script:AutoChart07LogonActivity.Series["Child Processes"].Chartarea         = 'Chart Area'
$script:AutoChart07LogonActivity.Series["Child Processes"].Legend            = 'Legend'
$script:AutoChart07LogonActivity.Series["Child Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07LogonActivity.Series["Child Processes"]['PieLineColor']   = 'Black'
$script:AutoChart07LogonActivity.Series["Child Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07LogonActivity.Series["Child Processes"].ChartType         = 'Column'
$script:AutoChart07LogonActivity.Series["Child Processes"].Color             = 'SlateBLue'

        function Generate-AutoChart07 {
            $script:AutoChart07LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart07LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ChildProcesses' | Sort-Object -Property 'ChildProcesses' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()

            if ($script:AutoChart07LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart07LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart07LogonActivityTitle.Text = "Child Processes"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart07LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07LogonActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.ChildProcesses) -eq $DataField.ChildProcesses) {
                            $Count += 1
                            if ( $script:AutoChart07LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart07LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart07LogonActivityUniqueCount = $script:AutoChart07LogonActivityCsvComputers.Count
                    $script:AutoChart07LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07LogonActivityUniqueCount
                        Computers   = $script:AutoChart07LogonActivityCsvComputers
                    }
                    $script:AutoChart07LogonActivityOverallDataResults += $script:AutoChart07LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount) }

                $script:AutoChart07LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07LogonActivityOverallDataResults.count))
                $script:AutoChart07LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart07LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart07LogonActivityTitle.Text = "Child Processes`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart07LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivityOptionsButton
$script:AutoChart07LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart07LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart07LogonActivity.Controls.Add($script:AutoChart07LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart07LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart07LogonActivity.Controls.Remove($script:AutoChart07LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07LogonActivity)

$script:AutoChart07LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart07LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07LogonActivityOverallDataResults.count))
    $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart07LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
        $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    })
    $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart07LogonActivityTrimOffFirstTrackBar)
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07LogonActivityOverallDataResults.count))
    $script:AutoChart07LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart07LogonActivityOverallDataResults.count)
    $script:AutoChart07LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart07LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart07LogonActivityOverallDataResults.count) - $script:AutoChart07LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart07LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07LogonActivityOverallDataResults.count) - $script:AutoChart07LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
        $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    })
$script:AutoChart07LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart07LogonActivityTrimOffLastTrackBar)
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart07LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07LogonActivity.Series["Child Processes"].ChartType = $script:AutoChart07LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
#    $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
})
$script:AutoChart07LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07LogonActivityChartTypesAvailable) { $script:AutoChart07LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07LogonActivityChartTypeComboBox.Location.X + $script:AutoChart07LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivity3DToggleButton
$script:AutoChart07LogonActivity3DInclination = 0
$script:AutoChart07LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart07LogonActivity3DInclination += 10
    if ( $script:AutoChart07LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart07LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart07LogonActivity3DInclination
        $script:AutoChart07LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart07LogonActivity3DInclination)"
#        $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart07LogonActivity3DInclination -le 90 ) {
        $script:AutoChart07LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart07LogonActivity3DInclination
        $script:AutoChart07LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart07LogonActivity3DInclination)"
#        $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
    else {
        $script:AutoChart07LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart07LogonActivity3DInclination = 0
        $script:AutoChart07LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart07LogonActivity3DInclination
        $script:AutoChart07LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
})
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart07LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07LogonActivity3DToggleButton.Location.X + $script:AutoChart07LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07LogonActivityColorsAvailable) { $script:AutoChart07LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07LogonActivity.Series["Child Processes"].Color = $script:AutoChart07LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {
    # List of Positive Endpoints that positively match
    $script:AutoChart07LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'ChildProcesses' -eq $($script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart07LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07LogonActivityImportCsvPosResults) { $script:AutoChart07LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart07LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart07LogonActivityImportCsvPosResults) { $script:AutoChart07LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07LogonActivityImportCsvNegResults) { $script:AutoChart07LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07LogonActivityImportCsvPosResults.count))"
    $script:AutoChart07LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart07LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivityCheckDiffButton
$script:AutoChart07LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart07LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ChildProcesses' -ExpandProperty 'ChildProcesses' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart07LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07LogonActivityInvestDiffDropDownArray) { $script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:AutoChart07LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart07LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivityInvestDiffExecuteButton
    $script:AutoChart07LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart07LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart07LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart07LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart07LogonActivityInvestDiffDropDownLabel,$script:AutoChart07LogonActivityInvestDiffDropDownComboBox,$script:AutoChart07LogonActivityInvestDiffExecuteButton,$script:AutoChart07LogonActivityInvestDiffPosResultsLabel,$script:AutoChart07LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart07LogonActivityInvestDiffNegResultsLabel,$script:AutoChart07LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart07LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart07LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07LogonActivityManipulationPanel.controls.Add($script:AutoChart07LogonActivityCheckDiffButton)


$AutoChart07ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07LogonActivityCheckDiffButton.Location.X + $script:AutoChart07LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Child Processes" -PropertyX "ChildProcesses" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart07ExpandChartButton
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($AutoChart07ExpandChartButton)


$script:AutoChart07LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart07LogonActivityCheckDiffButton.Location.Y + $script:AutoChart07LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivityOpenInShell
$script:AutoChart07LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart07LogonActivityManipulationPanel.controls.Add($script:AutoChart07LogonActivityOpenInShell)


$script:AutoChart07LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07LogonActivityOpenInShell.Location.X + $script:AutoChart07LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivityViewResults
$script:AutoChart07LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart07LogonActivityManipulationPanel.controls.Add($script:AutoChart07LogonActivityViewResults)


### Save the chart to file
$script:AutoChart07LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart07LogonActivityOpenInShell.Location.Y + $script:AutoChart07LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07LogonActivity -Title $script:AutoChart07LogonActivityTitle
})
$script:AutoChart07LogonActivityManipulationPanel.controls.Add($script:AutoChart07LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart07LogonActivitySaveButton.Location.Y + $script:AutoChart07LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07LogonActivityManipulationPanel.Controls.Add($script:AutoChart07LogonActivityNoticeTextbox)

$script:AutoChart07LogonActivity.Series["Child Processes"].Points.Clear()
$script:AutoChart07LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LogonActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}






















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06LogonActivity.Location.X
                  Y = $script:AutoChart06LogonActivity.Location.Y + $script:AutoChart06LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart08LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart08LogonActivity.Titles.Add($script:AutoChart08LogonActivityTitle)

### Create Charts Area
$script:AutoChart08LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart08LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart08LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart08LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart08LogonActivity.ChartAreas.Add($script:AutoChart08LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08LogonActivity.Series.Add("Memory Used")
$script:AutoChart08LogonActivity.Series["Memory Used"].Enabled           = $True
$script:AutoChart08LogonActivity.Series["Memory Used"].BorderWidth       = 1
$script:AutoChart08LogonActivity.Series["Memory Used"].IsVisibleInLegend = $false
$script:AutoChart08LogonActivity.Series["Memory Used"].Chartarea         = 'Chart Area'
$script:AutoChart08LogonActivity.Series["Memory Used"].Legend            = 'Legend'
$script:AutoChart08LogonActivity.Series["Memory Used"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08LogonActivity.Series["Memory Used"]['PieLineColor']   = 'Black'
$script:AutoChart08LogonActivity.Series["Memory Used"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08LogonActivity.Series["Memory Used"].ChartType         = 'Column'
$script:AutoChart08LogonActivity.Series["Memory Used"].Color             = 'Purple'

        function Generate-AutoChart08 {
            $script:AutoChart08LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart08LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'MemoryUsed' | Sort-Object -Property 'MemoryUsed' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()

            if ($script:AutoChart08LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart08LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart08LogonActivityTitle.Text = "Memory Used"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart08LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart08LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.MemoryUsed) -eq $DataField.MemoryUsed) {
                            $Count += 1
                            if ( $script:AutoChart08LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart08LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart08LogonActivityUniqueCount = $script:AutoChart08LogonActivityCsvComputers.Count
                    $script:AutoChart08LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08LogonActivityUniqueCount
                        Computers   = $script:AutoChart08LogonActivityCsvComputers
                    }
                    $script:AutoChart08LogonActivityOverallDataResults += $script:AutoChart08LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount) }

                $script:AutoChart08LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08LogonActivityOverallDataResults.count))
                $script:AutoChart08LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart08LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart08LogonActivityTitle.Text = "Memory Used`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart08LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivityOptionsButton
$script:AutoChart08LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart08LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart08LogonActivity.Controls.Add($script:AutoChart08LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart08LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart08LogonActivity.Controls.Remove($script:AutoChart08LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08LogonActivity)

$script:AutoChart08LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart08LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08LogonActivityOverallDataResults.count))
    $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart08LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
        $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    })
    $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart08LogonActivityTrimOffFirstTrackBar)
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08LogonActivityOverallDataResults.count))
    $script:AutoChart08LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart08LogonActivityOverallDataResults.count)
    $script:AutoChart08LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart08LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart08LogonActivityOverallDataResults.count) - $script:AutoChart08LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart08LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08LogonActivityOverallDataResults.count) - $script:AutoChart08LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
        $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    })
$script:AutoChart08LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart08LogonActivityTrimOffLastTrackBar)
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart08LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08LogonActivity.Series["Memory Used"].ChartType = $script:AutoChart08LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
#    $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
})
$script:AutoChart08LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08LogonActivityChartTypesAvailable) { $script:AutoChart08LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08LogonActivityChartTypeComboBox.Location.X + $script:AutoChart08LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivity3DToggleButton
$script:AutoChart08LogonActivity3DInclination = 0
$script:AutoChart08LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart08LogonActivity3DInclination += 10
    if ( $script:AutoChart08LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart08LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart08LogonActivity3DInclination
        $script:AutoChart08LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart08LogonActivity3DInclination)"
#        $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart08LogonActivity3DInclination -le 90 ) {
        $script:AutoChart08LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart08LogonActivity3DInclination
        $script:AutoChart08LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart08LogonActivity3DInclination)"
#        $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
    else {
        $script:AutoChart08LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart08LogonActivity3DInclination = 0
        $script:AutoChart08LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart08LogonActivity3DInclination
        $script:AutoChart08LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
})
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart08LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08LogonActivity3DToggleButton.Location.X + $script:AutoChart08LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08LogonActivityColorsAvailable) { $script:AutoChart08LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08LogonActivity.Series["Memory Used"].Color = $script:AutoChart08LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {
    # List of Positive Endpoints that positively match
    $script:AutoChart08LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'MemoryUsed' -eq $($script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart08LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08LogonActivityImportCsvPosResults) { $script:AutoChart08LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart08LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart08LogonActivityImportCsvPosResults) { $script:AutoChart08LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08LogonActivityImportCsvNegResults) { $script:AutoChart08LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08LogonActivityImportCsvPosResults.count))"
    $script:AutoChart08LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart08LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivityCheckDiffButton
$script:AutoChart08LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart08LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'MemoryUsed' -ExpandProperty 'MemoryUsed' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart08LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08LogonActivityInvestDiffDropDownArray) { $script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:AutoChart08LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart08LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivityInvestDiffExecuteButton
    $script:AutoChart08LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart08LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart08LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart08LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart08LogonActivityInvestDiffDropDownLabel,$script:AutoChart08LogonActivityInvestDiffDropDownComboBox,$script:AutoChart08LogonActivityInvestDiffExecuteButton,$script:AutoChart08LogonActivityInvestDiffPosResultsLabel,$script:AutoChart08LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart08LogonActivityInvestDiffNegResultsLabel,$script:AutoChart08LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart08LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart08LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08LogonActivityManipulationPanel.controls.Add($script:AutoChart08LogonActivityCheckDiffButton)


$AutoChart08ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08LogonActivityCheckDiffButton.Location.X + $script:AutoChart08LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Memory Used" -PropertyX "MemoryUsed" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart08ExpandChartButton
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($AutoChart08ExpandChartButton)


$script:AutoChart08LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart08LogonActivityCheckDiffButton.Location.Y + $script:AutoChart08LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivityOpenInShell
$script:AutoChart08LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart08LogonActivityManipulationPanel.controls.Add($script:AutoChart08LogonActivityOpenInShell)


$script:AutoChart08LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08LogonActivityOpenInShell.Location.X + $script:AutoChart08LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivityViewResults
$script:AutoChart08LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart08LogonActivityManipulationPanel.controls.Add($script:AutoChart08LogonActivityViewResults)


### Save the chart to file
$script:AutoChart08LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart08LogonActivityOpenInShell.Location.Y + $script:AutoChart08LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08LogonActivity -Title $script:AutoChart08LogonActivityTitle
})
$script:AutoChart08LogonActivityManipulationPanel.controls.Add($script:AutoChart08LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart08LogonActivitySaveButton.Location.Y + $script:AutoChart08LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08LogonActivityManipulationPanel.Controls.Add($script:AutoChart08LogonActivityNoticeTextbox)

$script:AutoChart08LogonActivity.Series["Memory Used"].Points.Clear()
$script:AutoChart08LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LogonActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}






















##############################################################################################
# AutoChart09
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07LogonActivity.Location.X
                  Y = $script:AutoChart07LogonActivity.Location.Y + $script:AutoChart07LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart09LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09LogonActivity.Titles.Add($script:AutoChart09LogonActivityTitle)

### Create Charts Area
$script:AutoChart09LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart09LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart09LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart09LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart09LogonActivity.ChartAreas.Add($script:AutoChart09LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09LogonActivity.Series.Add("Profile Loaded")
$script:AutoChart09LogonActivity.Series["Profile Loaded"].Enabled           = $True
$script:AutoChart09LogonActivity.Series["Profile Loaded"].BorderWidth       = 1
$script:AutoChart09LogonActivity.Series["Profile Loaded"].IsVisibleInLegend = $false
$script:AutoChart09LogonActivity.Series["Profile Loaded"].Chartarea         = 'Chart Area'
$script:AutoChart09LogonActivity.Series["Profile Loaded"].Legend            = 'Legend'
$script:AutoChart09LogonActivity.Series["Profile Loaded"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09LogonActivity.Series["Profile Loaded"]['PieLineColor']   = 'Black'
$script:AutoChart09LogonActivity.Series["Profile Loaded"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09LogonActivity.Series["Profile Loaded"].ChartType         = 'Column'
$script:AutoChart09LogonActivity.Series["Profile Loaded"].Color             = 'Yellow'

        function Generate-AutoChart09 {
            $script:AutoChart09LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart09LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ProfileLoaded' | Sort-Object -Property 'ProfileLoaded' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()

            if ($script:AutoChart09LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart09LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart09LogonActivityTitle.Text = "Profile Loaded"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart09LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09LogonActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.ProfileLoaded) -eq $DataField.ProfileLoaded) {
                            $Count += 1
                            if ( $script:AutoChart09LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart09LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart09LogonActivityUniqueCount = $script:AutoChart09LogonActivityCsvComputers.Count
                    $script:AutoChart09LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09LogonActivityUniqueCount
                        Computers   = $script:AutoChart09LogonActivityCsvComputers
                    }
                    $script:AutoChart09LogonActivityOverallDataResults += $script:AutoChart09LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount) }

                $script:AutoChart09LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09LogonActivityOverallDataResults.count))
                $script:AutoChart09LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart09LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart09LogonActivityTitle.Text = "Profile Loaded`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart09LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivityOptionsButton
$script:AutoChart09LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart09LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart09LogonActivity.Controls.Add($script:AutoChart09LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart09LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart09LogonActivity.Controls.Remove($script:AutoChart09LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09LogonActivity)

$script:AutoChart09LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart09LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09LogonActivityOverallDataResults.count))
    $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart09LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
        $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    })
    $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart09LogonActivityTrimOffFirstTrackBar)
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09LogonActivityOverallDataResults.count))
    $script:AutoChart09LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart09LogonActivityOverallDataResults.count)
    $script:AutoChart09LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart09LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart09LogonActivityOverallDataResults.count) - $script:AutoChart09LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart09LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09LogonActivityOverallDataResults.count) - $script:AutoChart09LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
        $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    })
$script:AutoChart09LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart09LogonActivityTrimOffLastTrackBar)
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart09LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09LogonActivity.Series["Profile Loaded"].ChartType = $script:AutoChart09LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
#    $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
})
$script:AutoChart09LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09LogonActivityChartTypesAvailable) { $script:AutoChart09LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09LogonActivityChartTypeComboBox.Location.X + $script:AutoChart09LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivity3DToggleButton
$script:AutoChart09LogonActivity3DInclination = 0
$script:AutoChart09LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart09LogonActivity3DInclination += 10
    if ( $script:AutoChart09LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart09LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart09LogonActivity3DInclination
        $script:AutoChart09LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart09LogonActivity3DInclination)"
#        $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09LogonActivity3DInclination -le 90 ) {
        $script:AutoChart09LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart09LogonActivity3DInclination
        $script:AutoChart09LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart09LogonActivity3DInclination)"
#        $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
    else {
        $script:AutoChart09LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart09LogonActivity3DInclination = 0
        $script:AutoChart09LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart09LogonActivity3DInclination
        $script:AutoChart09LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
})
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart09LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09LogonActivity3DToggleButton.Location.X + $script:AutoChart09LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09LogonActivityColorsAvailable) { $script:AutoChart09LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09LogonActivity.Series["Profile Loaded"].Color = $script:AutoChart09LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {
    # List of Positive Endpoints that positively match
    $script:AutoChart09LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'ProfileLoaded' -eq $($script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart09LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09LogonActivityImportCsvPosResults) { $script:AutoChart09LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart09LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart09LogonActivityImportCsvPosResults) { $script:AutoChart09LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09LogonActivityImportCsvNegResults) { $script:AutoChart09LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09LogonActivityImportCsvPosResults.count))"
    $script:AutoChart09LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart09LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivityCheckDiffButton
$script:AutoChart09LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart09LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'ProfileLoaded' -ExpandProperty 'ProfileLoaded' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart09LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09LogonActivityInvestDiffDropDownArray) { $script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:AutoChart09LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart09LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivityInvestDiffExecuteButton
    $script:AutoChart09LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart09LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart09LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart09LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart09LogonActivityInvestDiffDropDownLabel,$script:AutoChart09LogonActivityInvestDiffDropDownComboBox,$script:AutoChart09LogonActivityInvestDiffExecuteButton,$script:AutoChart09LogonActivityInvestDiffPosResultsLabel,$script:AutoChart09LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart09LogonActivityInvestDiffNegResultsLabel,$script:AutoChart09LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart09LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart09LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09LogonActivityManipulationPanel.controls.Add($script:AutoChart09LogonActivityCheckDiffButton)


$AutoChart09ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09LogonActivityCheckDiffButton.Location.X + $script:AutoChart09LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Profile Loadeds" -PropertyX "ProfileLoaded" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart09ExpandChartButton
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($AutoChart09ExpandChartButton)


$script:AutoChart09LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart09LogonActivityCheckDiffButton.Location.Y + $script:AutoChart09LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivityOpenInShell
$script:AutoChart09LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart09LogonActivityManipulationPanel.controls.Add($script:AutoChart09LogonActivityOpenInShell)


$script:AutoChart09LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09LogonActivityOpenInShell.Location.X + $script:AutoChart09LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivityViewResults
$script:AutoChart09LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart09LogonActivityManipulationPanel.controls.Add($script:AutoChart09LogonActivityViewResults)


### Save the chart to file
$script:AutoChart09LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart09LogonActivityOpenInShell.Location.Y + $script:AutoChart09LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09LogonActivity -Title $script:AutoChart09LogonActivityTitle
})
$script:AutoChart09LogonActivityManipulationPanel.controls.Add($script:AutoChart09LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart09LogonActivitySaveButton.Location.Y + $script:AutoChart09LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09LogonActivityManipulationPanel.Controls.Add($script:AutoChart09LogonActivityNoticeTextbox)

$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.Clear()
$script:AutoChart09LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LogonActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}






















##############################################################################################
# AutoChart10
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10LogonActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08LogonActivity.Location.X
                  Y = $script:AutoChart08LogonActivity.Location.Y + $script:AutoChart08LogonActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10LogonActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart10LogonActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10LogonActivity.Titles.Add($script:AutoChart10LogonActivityTitle)

### Create Charts Area
$script:AutoChart10LogonActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10LogonActivityArea.Name        = 'Chart Area'
#$script:AutoChart10LogonActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart10LogonActivityArea.AxisX.Interval          = 1
$script:AutoChart10LogonActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10LogonActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10LogonActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart10LogonActivity.ChartAreas.Add($script:AutoChart10LogonActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10LogonActivity.Series.Add("Compression Mode")
$script:AutoChart10LogonActivity.Series["Compression Mode"].Enabled           = $True
$script:AutoChart10LogonActivity.Series["Compression Mode"].BorderWidth       = 1
$script:AutoChart10LogonActivity.Series["Compression Mode"].IsVisibleInLegend = $false
$script:AutoChart10LogonActivity.Series["Compression Mode"].Chartarea         = 'Chart Area'
$script:AutoChart10LogonActivity.Series["Compression Mode"].Legend            = 'Legend'
$script:AutoChart10LogonActivity.Series["Compression Mode"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10LogonActivity.Series["Compression Mode"]['PieLineColor']   = 'Black'
$script:AutoChart10LogonActivity.Series["Compression Mode"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10LogonActivity.Series["Compression Mode"].ChartType         = 'Column'
$script:AutoChart10LogonActivity.Series["Compression Mode"].Color             = 'Red'

        function Generate-AutoChart10 {
            $script:AutoChart10LogonActivityCsvFileHosts      = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart10LogonActivityUniqueDataFields  = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'CompressionMode' | Sort-Object -Property 'CompressionMode' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10LogonActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()

            if ($script:AutoChart10LogonActivityUniqueDataFields.count -gt 0){
                $script:AutoChart10LogonActivityTitle.ForeColor = 'Black'
                $script:AutoChart10LogonActivityTitle.Text = "Compression Mode"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart10LogonActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10LogonActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10LogonActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvLogonActivity ) {
                        if ($($Line.CompressionMode) -eq $DataField.CompressionMode) {
                            $Count += 1
                            if ( $script:AutoChart10LogonActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart10LogonActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart10LogonActivityUniqueCount = $script:AutoChart10LogonActivityCsvComputers.Count
                    $script:AutoChart10LogonActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10LogonActivityUniqueCount
                        Computers   = $script:AutoChart10LogonActivityCsvComputers
                    }
                    $script:AutoChart10LogonActivityOverallDataResults += $script:AutoChart10LogonActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount) }

                $script:AutoChart10LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10LogonActivityOverallDataResults.count))
                $script:AutoChart10LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10LogonActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart10LogonActivityTitle.ForeColor = 'Red'
                $script:AutoChart10LogonActivityTitle.Text = "Compression Mode`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart10

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart10LogonActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10LogonActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10LogonActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivityOptionsButton
$script:AutoChart10LogonActivityOptionsButton.Add_Click({
    if ($script:AutoChart10LogonActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10LogonActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart10LogonActivity.Controls.Add($script:AutoChart10LogonActivityManipulationPanel)
    }
    elseif ($script:AutoChart10LogonActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10LogonActivityOptionsButton.Text = 'Options v'
        $script:AutoChart10LogonActivity.Controls.Remove($script:AutoChart10LogonActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10LogonActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10LogonActivity)

$script:AutoChart10LogonActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10LogonActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10LogonActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10LogonActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10LogonActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = $FormScale * 1
                         Y = $FormScale * 30 }
        Size        = @{ Width  = $FormScale * 160
                         Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0
    }
    $script:AutoChart10LogonActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10LogonActivityOverallDataResults.count))
    $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10LogonActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue = $script:AutoChart10LogonActivityTrimOffFirstTrackBar.Value
        $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10LogonActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
        $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    })
    $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart10LogonActivityTrimOffFirstTrackBar)
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10LogonActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10LogonActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10LogonActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10LogonActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10LogonActivityOverallDataResults.count))
    $script:AutoChart10LogonActivityTrimOffLastTrackBar.Value         = $($script:AutoChart10LogonActivityOverallDataResults.count)
    $script:AutoChart10LogonActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart10LogonActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10LogonActivityTrimOffLastTrackBarValue = $($script:AutoChart10LogonActivityOverallDataResults.count) - $script:AutoChart10LogonActivityTrimOffLastTrackBar.Value
        $script:AutoChart10LogonActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10LogonActivityOverallDataResults.count) - $script:AutoChart10LogonActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
        $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    })
$script:AutoChart10LogonActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart10LogonActivityTrimOffLastTrackBar)
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10LogonActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart10LogonActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10LogonActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10LogonActivity.Series["Compression Mode"].ChartType = $script:AutoChart10LogonActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
#    $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
})
$script:AutoChart10LogonActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10LogonActivityChartTypesAvailable) { $script:AutoChart10LogonActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10LogonActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10LogonActivityChartTypeComboBox.Location.X + $script:AutoChart10LogonActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10LogonActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivity3DToggleButton
$script:AutoChart10LogonActivity3DInclination = 0
$script:AutoChart10LogonActivity3DToggleButton.Add_Click({
    $script:AutoChart10LogonActivity3DInclination += 10
    if ( $script:AutoChart10LogonActivity3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart10LogonActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart10LogonActivity3DInclination
        $script:AutoChart10LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart10LogonActivity3DInclination)"
#        $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10LogonActivity3DInclination -le 90 ) {
        $script:AutoChart10LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart10LogonActivity3DInclination
        $script:AutoChart10LogonActivity3DToggleButton.Text  = "3D On ($script:AutoChart10LogonActivity3DInclination)"
#        $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
    else {
        $script:AutoChart10LogonActivity3DToggleButton.Text  = "3D Off"
        $script:AutoChart10LogonActivity3DInclination = 0
        $script:AutoChart10LogonActivityArea.Area3DStyle.Inclination = $script:AutoChart10LogonActivity3DInclination
        $script:AutoChart10LogonActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
})
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart10LogonActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10LogonActivity3DToggleButton.Location.X + $script:AutoChart10LogonActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LogonActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10LogonActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10LogonActivityColorsAvailable) { $script:AutoChart10LogonActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10LogonActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10LogonActivity.Series["Compression Mode"].Color = $script:AutoChart10LogonActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10 {
    # List of Positive Endpoints that positively match
    $script:AutoChart10LogonActivityImportCsvPosResults = $script:AutoChartDataSourceCsvLogonActivity | Where-Object 'CompressionMode' -eq $($script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart10LogonActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10LogonActivityImportCsvPosResults) { $script:AutoChart10LogonActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10LogonActivityImportCsvAll = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart10LogonActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10LogonActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart10LogonActivityImportCsvPosResults) { $script:AutoChart10LogonActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10LogonActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10LogonActivityImportCsvNegResults) { $script:AutoChart10LogonActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10LogonActivityImportCsvPosResults.count))"
    $script:AutoChart10LogonActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10LogonActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10LogonActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10LogonActivityTrimOffLastGroupBox.Location.X + $script:AutoChart10LogonActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LogonActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivityCheckDiffButton
$script:AutoChart10LogonActivityCheckDiffButton.Add_Click({
    $script:AutoChart10LogonActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsvLogonActivity | Select-Object -Property 'CompressionMode' -ExpandProperty 'CompressionMode' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10LogonActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon($EasyWinIcon)
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10LogonActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10LogonActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LogonActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart10LogonActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10LogonActivityInvestDiffDropDownArray) { $script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Execute Button
    $script:AutoChart10LogonActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart10LogonActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivityInvestDiffExecuteButton
    $script:AutoChart10LogonActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10LogonActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10LogonActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LogonActivityInvestDiffExecuteButton.Location.y + $script:AutoChart10LogonActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10LogonActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10LogonActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart10LogonActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10LogonActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10LogonActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10LogonActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart10LogonActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10LogonActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart10LogonActivityInvestDiffDropDownLabel,$script:AutoChart10LogonActivityInvestDiffDropDownComboBox,$script:AutoChart10LogonActivityInvestDiffExecuteButton,$script:AutoChart10LogonActivityInvestDiffPosResultsLabel,$script:AutoChart10LogonActivityInvestDiffPosResultsTextBox,$script:AutoChart10LogonActivityInvestDiffNegResultsLabel,$script:AutoChart10LogonActivityInvestDiffNegResultsTextBox))
    $script:AutoChart10LogonActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10LogonActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart10LogonActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10LogonActivityManipulationPanel.controls.Add($script:AutoChart10LogonActivityCheckDiffButton)


$AutoChart10ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10LogonActivityCheckDiffButton.Location.X + $script:AutoChart10LogonActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10LogonActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvLogonActivityFileName -QueryName "Current Logon Activity" -QueryTabName "Compression Mode" -PropertyX "CompressionMode" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart10ExpandChartButton
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($AutoChart10ExpandChartButton)


$script:AutoChart10LogonActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10LogonActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart10LogonActivityCheckDiffButton.Location.Y + $script:AutoChart10LogonActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivityOpenInShell
$script:AutoChart10LogonActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart10LogonActivityManipulationPanel.controls.Add($script:AutoChart10LogonActivityOpenInShell)


$script:AutoChart10LogonActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10LogonActivityOpenInShell.Location.X + $script:AutoChart10LogonActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LogonActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivityViewResults
$script:AutoChart10LogonActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsvLogonActivity | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart10LogonActivityManipulationPanel.controls.Add($script:AutoChart10LogonActivityViewResults)


### Save the chart to file
$script:AutoChart10LogonActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10LogonActivityOpenInShell.Location.X
                  Y = $script:AutoChart10LogonActivityOpenInShell.Location.Y + $script:AutoChart10LogonActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10LogonActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10LogonActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10LogonActivity -Title $script:AutoChart10LogonActivityTitle
})
$script:AutoChart10LogonActivityManipulationPanel.controls.Add($script:AutoChart10LogonActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10LogonActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10LogonActivitySaveButton.Location.X
                        Y = $script:AutoChart10LogonActivitySaveButton.Location.Y + $script:AutoChart10LogonActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10LogonActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10LogonActivityManipulationPanel.Controls.Add($script:AutoChart10LogonActivityNoticeTextbox)

$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.Clear()
$script:AutoChart10LogonActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LogonActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LogonActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LogonActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}






# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpL/Yak6DJZTQ6ZQO2tAMMgpt
# equgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXiwWsyMMUIbj33vskwcmb2vekgQwDQYJKoZI
# hvcNAQEBBQAEggEAJwS2w09449NDP3tFSN9pSVvVs/NTy2CbA1bkXZQ8Co8pCqsq
# 46jzZPz/bEvuOzs8boe7CvIR0ARm2n9W1BZU2JozBjkSDioSeXpUIobR/gTIXAKT
# hDR7yeLlN4P9UeBuWL9CGGsVd8jzex3twjExYTNjm6nfsD0aa/BhhWaK70ZkS2fO
# a5ZQ99kNCDcaeJt5RTpYEON6hMDkTsYVOrUmXL9S6uaEAaJe5EQyB7Y8NsuisS9J
# nGSRxS8Wj1htUiaqipPApPgVXDkWtSs3qCNlI5vkovFOGKt3pwIp4oTm4cPIFXoj
# 8bT2d9fQIlUJl3OUgb2FycBkQsW4uRcfBh/NPg==
# SIG # End signature block
