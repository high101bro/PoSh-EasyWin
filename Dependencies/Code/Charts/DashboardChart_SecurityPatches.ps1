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

$script:AutoChart01SecurityPatchesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Security Patches') { $script:AutoChart01SecurityPatchesCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01SecurityPatchesCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsvSecurityPatches = $null
$script:AutoChartDataSourceCsvSecurityPatches = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01SecurityPatchesOptionsButton.Text = 'Options v'
    $script:AutoChart01SecurityPatches.Controls.Remove($script:AutoChart01SecurityPatchesManipulationPanel)
    $script:AutoChart02SecurityPatchesOptionsButton.Text = 'Options v'
    $script:AutoChart02SecurityPatches.Controls.Remove($script:AutoChart02SecurityPatchesManipulationPanel)
    $script:AutoChart03SecurityPatchesOptionsButton.Text = 'Options v'
    $script:AutoChart03SecurityPatches.Controls.Remove($script:AutoChart03SecurityPatchesManipulationPanel)
    $script:AutoChart04SecurityPatchesOptionsButton.Text = 'Options v'
    $script:AutoChart04SecurityPatches.Controls.Remove($script:AutoChart04SecurityPatchesManipulationPanel)
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
$script:AutoChart01SecurityPatches = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01SecurityPatches.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01SecurityPatchesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01SecurityPatches.Titles.Add($script:AutoChart01SecurityPatchesTitle)

### Create Charts Area
$script:AutoChart01SecurityPatchesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01SecurityPatchesArea.Name        = 'Chart Area'
$script:AutoChart01SecurityPatchesArea.AxisX.Title = 'Hosts'
$script:AutoChart01SecurityPatchesArea.AxisX.Interval          = 1
$script:AutoChart01SecurityPatchesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01SecurityPatchesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01SecurityPatchesArea.Area3DStyle.Inclination = 75
$script:AutoChart01SecurityPatches.ChartAreas.Add($script:AutoChart01SecurityPatchesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01SecurityPatches.Series.Add("Security Patches")
$script:AutoChart01SecurityPatches.Series["Security Patches"].Enabled           = $True
$script:AutoChart01SecurityPatches.Series["Security Patches"].BorderWidth       = 1
$script:AutoChart01SecurityPatches.Series["Security Patches"].IsVisibleInLegend = $false
$script:AutoChart01SecurityPatches.Series["Security Patches"].Chartarea         = 'Chart Area'
$script:AutoChart01SecurityPatches.Series["Security Patches"].Legend            = 'Legend'
$script:AutoChart01SecurityPatches.Series["Security Patches"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01SecurityPatches.Series["Security Patches"]['PieLineColor']   = 'Black'
$script:AutoChart01SecurityPatches.Series["Security Patches"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01SecurityPatches.Series["Security Patches"].ChartType         = 'Column'
$script:AutoChart01SecurityPatches.Series["Security Patches"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01SecurityPatchesCsvFileHosts      = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01SecurityPatchesUniqueDataFields  = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'HotFixID' | Sort-Object -Property 'HotFixID' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01SecurityPatchesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()

            if ($script:AutoChart01SecurityPatchesUniqueDataFields.count -gt 0){
                $script:AutoChart01SecurityPatchesTitle.ForeColor = 'Black'
                $script:AutoChart01SecurityPatchesTitle.Text = "Security Patches"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01SecurityPatchesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01SecurityPatchesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01SecurityPatchesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSecurityPatches ) {
                        if ($($Line.HotFixID) -eq $DataField.HotFixID) {
                            $Count += 1
                            if ( $script:AutoChart01SecurityPatchesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01SecurityPatchesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01SecurityPatchesUniqueCount = $script:AutoChart01SecurityPatchesCsvComputers.Count
                    $script:AutoChart01SecurityPatchesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01SecurityPatchesUniqueCount
                        Computers   = $script:AutoChart01SecurityPatchesCsvComputers
                    }
                    $script:AutoChart01SecurityPatchesOverallDataResults += $script:AutoChart01SecurityPatchesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount) }
                $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SecurityPatchesOverallDataResults.count))
                $script:AutoChart01SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SecurityPatchesOverallDataResults.count))
            }
            else {
                $script:AutoChart01SecurityPatchesTitle.ForeColor = 'Red'
                $script:AutoChart01SecurityPatchesTitle.Text = "Security Patches`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01SecurityPatchesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01SecurityPatches.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01SecurityPatches.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesOptionsButton
$script:AutoChart01SecurityPatchesOptionsButton.Add_Click({
    if ($script:AutoChart01SecurityPatchesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01SecurityPatchesOptionsButton.Text = 'Options ^'
        $script:AutoChart01SecurityPatches.Controls.Add($script:AutoChart01SecurityPatchesManipulationPanel)
    }
    elseif ($script:AutoChart01SecurityPatchesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01SecurityPatchesOptionsButton.Text = 'Options v'
        $script:AutoChart01SecurityPatches.Controls.Remove($script:AutoChart01SecurityPatchesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01SecurityPatchesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01SecurityPatches)


$script:AutoChart01SecurityPatchesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01SecurityPatches.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01SecurityPatches.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01SecurityPatchesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01SecurityPatchesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SecurityPatchesOverallDataResults.count))
    $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01SecurityPatchesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue = $script:AutoChart01SecurityPatchesTrimOffFirstTrackBar.Value
        $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01SecurityPatchesTrimOffFirstTrackBar.Value)"
        $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
        $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    })
    $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Controls.Add($script:AutoChart01SecurityPatchesTrimOffFirstTrackBar)
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatchesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01SecurityPatchesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Location.X + $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SecurityPatchesOverallDataResults.count))
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.Value         = $($script:AutoChart01SecurityPatchesOverallDataResults.count)
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue   = 0
    $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue = $($script:AutoChart01SecurityPatchesOverallDataResults.count) - $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.Value
        $script:AutoChart01SecurityPatchesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01SecurityPatchesOverallDataResults.count) - $script:AutoChart01SecurityPatchesTrimOffLastTrackBar.Value)"
        $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
        $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    })
$script:AutoChart01SecurityPatchesTrimOffLastGroupBox.Controls.Add($script:AutoChart01SecurityPatchesTrimOffLastTrackBar)
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatchesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01SecurityPatchesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Location.Y + $script:AutoChart01SecurityPatchesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SecurityPatchesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01SecurityPatches.Series["Security Patches"].ChartType = $script:AutoChart01SecurityPatchesChartTypeComboBox.SelectedItem
#    $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
#    $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
})
$script:AutoChart01SecurityPatchesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01SecurityPatchesChartTypesAvailable) { $script:AutoChart01SecurityPatchesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatchesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01SecurityPatches3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01SecurityPatchesChartTypeComboBox.Location.X + $script:AutoChart01SecurityPatchesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01SecurityPatchesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatches3DToggleButton
$script:AutoChart01SecurityPatches3DInclination = 0
$script:AutoChart01SecurityPatches3DToggleButton.Add_Click({

    $script:AutoChart01SecurityPatches3DInclination += 10
    if ( $script:AutoChart01SecurityPatches3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01SecurityPatchesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart01SecurityPatches3DInclination
        $script:AutoChart01SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart01SecurityPatches3DInclination)"
#        $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01SecurityPatches3DInclination -le 90 ) {
        $script:AutoChart01SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart01SecurityPatches3DInclination
        $script:AutoChart01SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart01SecurityPatches3DInclination)"
#        $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01SecurityPatches3DToggleButton.Text  = "3D Off"
        $script:AutoChart01SecurityPatches3DInclination = 0
        $script:AutoChart01SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart01SecurityPatches3DInclination
        $script:AutoChart01SecurityPatchesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
#        $script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}
    }
})
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatches3DToggleButton)

### Change the color of the chart
$script:AutoChart01SecurityPatchesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01SecurityPatches3DToggleButton.Location.X + $script:AutoChart01SecurityPatches3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SecurityPatches3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SecurityPatchesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01SecurityPatchesColorsAvailable) { $script:AutoChart01SecurityPatchesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01SecurityPatchesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01SecurityPatches.Series["Security Patches"].Color = $script:AutoChart01SecurityPatchesChangeColorComboBox.SelectedItem
})
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatchesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01SecurityPatchesImportCsvPosResults = $script:AutoChartDataSourceCsvSecurityPatches | Where-Object 'HotFixID' -eq $($script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01SecurityPatchesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SecurityPatchesImportCsvPosResults) { $script:AutoChart01SecurityPatchesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01SecurityPatchesImportCsvAll = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01SecurityPatchesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01SecurityPatchesImportCsvAll) { if ($Endpoint -notin $script:AutoChart01SecurityPatchesImportCsvPosResults) { $script:AutoChart01SecurityPatchesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01SecurityPatchesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SecurityPatchesImportCsvNegResults) { $script:AutoChart01SecurityPatchesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01SecurityPatchesImportCsvPosResults.count))"
    $script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01SecurityPatchesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01SecurityPatchesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01SecurityPatchesTrimOffLastGroupBox.Location.X + $script:AutoChart01SecurityPatchesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SecurityPatchesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesCheckDiffButton
$script:AutoChart01SecurityPatchesCheckDiffButton.Add_Click({
    $script:AutoChart01SecurityPatchesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'HotFixID' -ExpandProperty 'HotFixID' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01SecurityPatchesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01SecurityPatchesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SecurityPatchesInvestDiffDropDownLabel.Location.y + $script:AutoChart01SecurityPatchesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01SecurityPatchesInvestDiffDropDownArray) { $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01SecurityPatchesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Location.y + $script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesInvestDiffExecuteButton
    $script:AutoChart01SecurityPatchesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SecurityPatchesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SecurityPatchesInvestDiffExecuteButton.Location.y + $script:AutoChart01SecurityPatchesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SecurityPatchesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Location.y + $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Location.x + $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SecurityPatchesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel.Location.y + $script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01SecurityPatchesInvestDiffForm.Controls.AddRange(@($script:AutoChart01SecurityPatchesInvestDiffDropDownLabel,$script:AutoChart01SecurityPatchesInvestDiffDropDownComboBox,$script:AutoChart01SecurityPatchesInvestDiffExecuteButton,$script:AutoChart01SecurityPatchesInvestDiffPosResultsLabel,$script:AutoChart01SecurityPatchesInvestDiffPosResultsTextBox,$script:AutoChart01SecurityPatchesInvestDiffNegResultsLabel,$script:AutoChart01SecurityPatchesInvestDiffNegResultsTextBox))
    $script:AutoChart01SecurityPatchesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01SecurityPatchesInvestDiffForm.ShowDialog()
})
$script:AutoChart01SecurityPatchesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01SecurityPatchesManipulationPanel.controls.Add($script:AutoChart01SecurityPatchesCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01SecurityPatchesCheckDiffButton.Location.X + $script:AutoChart01SecurityPatchesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01SecurityPatchesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSecurityPatchesFileName -QueryName "Security Patches" -QueryTabName "Security Patches" -PropertyX "HotFixID" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01SecurityPatchesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01SecurityPatchesCheckDiffButton.Location.X
                   Y = $script:AutoChart01SecurityPatchesCheckDiffButton.Location.Y + $script:AutoChart01SecurityPatchesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesOpenInShell
$script:AutoChart01SecurityPatchesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01SecurityPatchesManipulationPanel.controls.Add($script:AutoChart01SecurityPatchesOpenInShell)


$script:AutoChart01SecurityPatchesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01SecurityPatchesOpenInShell.Location.X + $script:AutoChart01SecurityPatchesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SecurityPatchesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesViewResults
$script:AutoChart01SecurityPatchesViewResults.Add_Click({ $script:AutoChartDataSourceCsvSecurityPatches | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01SecurityPatchesManipulationPanel.controls.Add($script:AutoChart01SecurityPatchesViewResults)


### Save the chart to file
$script:AutoChart01SecurityPatchesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01SecurityPatchesOpenInShell.Location.X
                  Y = $script:AutoChart01SecurityPatchesOpenInShell.Location.Y + $script:AutoChart01SecurityPatchesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01SecurityPatchesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SecurityPatchesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01SecurityPatches -Title $script:AutoChart01SecurityPatchesTitle
})
$script:AutoChart01SecurityPatchesManipulationPanel.controls.Add($script:AutoChart01SecurityPatchesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01SecurityPatchesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SecurityPatchesSaveButton.Location.X
                        Y = $script:AutoChart01SecurityPatchesSaveButton.Location.Y + $script:AutoChart01SecurityPatchesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01SecurityPatchesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart01SecurityPatchesNoticeTextbox)

$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.Clear()
$script:AutoChart01SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SecurityPatches.Series["Security Patches"].Points.AddXY($_.DataField.HotFixID,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02SecurityPatches = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01SecurityPatches.Location.X + $script:AutoChart01SecurityPatches.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01SecurityPatches.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02SecurityPatches.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02SecurityPatchesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02SecurityPatches.Titles.Add($script:AutoChart02SecurityPatchesTitle)

### Create Charts Area
$script:AutoChart02SecurityPatchesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02SecurityPatchesArea.Name        = 'Chart Area'
$script:AutoChart02SecurityPatchesArea.AxisX.Title = 'Hosts'
$script:AutoChart02SecurityPatchesArea.AxisX.Interval          = 1
$script:AutoChart02SecurityPatchesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02SecurityPatchesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02SecurityPatchesArea.Area3DStyle.Inclination = 75
$script:AutoChart02SecurityPatches.ChartAreas.Add($script:AutoChart02SecurityPatchesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02SecurityPatches.Series.Add("Security Patches Per Host")
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Enabled           = $True
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].BorderWidth       = 1
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].IsVisibleInLegend = $false
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Legend            = 'Legend'
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02SecurityPatchesCsvFileHosts     = ($script:AutoChartDataSourceCsvSecurityPatches).PSComputerName | Sort-Object -Unique
            $script:AutoChart02SecurityPatchesUniqueDataFields = ($script:AutoChartDataSourceCsvSecurityPatches).HotFixID | Sort-Object -Property 'HotFixID'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02SecurityPatchesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02SecurityPatchesUniqueDataFields.count -gt 0){
                $script:AutoChart02SecurityPatchesTitle.ForeColor = 'Black'
                $script:AutoChart02SecurityPatchesTitle.Text = "Security Patches Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02SecurityPatchesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvSecurityPatches | Sort-Object PSComputerName) ) {
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
                            $script:AutoChart02SecurityPatchesOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02SecurityPatchesOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02SecurityPatchesOverallDataResults | ForEach-Object { $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SecurityPatchesOverallDataResults.count))
                $script:AutoChart02SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SecurityPatchesOverallDataResults.count))
            }
            else {
                $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
                $script:AutoChart02SecurityPatchesTitle.ForeColor = 'Red'
                $script:AutoChart02SecurityPatchesTitle.Text = "Security Patches Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02SecurityPatchesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02SecurityPatches.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02SecurityPatches.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesOptionsButton
$script:AutoChart02SecurityPatchesOptionsButton.Add_Click({
    if ($script:AutoChart02SecurityPatchesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02SecurityPatchesOptionsButton.Text = 'Options ^'
        $script:AutoChart02SecurityPatches.Controls.Add($script:AutoChart02SecurityPatchesManipulationPanel)
    }
    elseif ($script:AutoChart02SecurityPatchesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02SecurityPatchesOptionsButton.Text = 'Options v'
        $script:AutoChart02SecurityPatches.Controls.Remove($script:AutoChart02SecurityPatchesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02SecurityPatchesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02SecurityPatches)

$script:AutoChart02SecurityPatchesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02SecurityPatches.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02SecurityPatches.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02SecurityPatchesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02SecurityPatchesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SecurityPatchesOverallDataResults.count))
    $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02SecurityPatchesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue = $script:AutoChart02SecurityPatchesTrimOffFirstTrackBar.Value
        $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02SecurityPatchesTrimOffFirstTrackBar.Value)"
        $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Controls.Add($script:AutoChart02SecurityPatchesTrimOffFirstTrackBar)
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatchesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02SecurityPatchesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Location.X + $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SecurityPatchesOverallDataResults.count))
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.Value         = $($script:AutoChart02SecurityPatchesOverallDataResults.count)
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue   = 0
    $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue = $($script:AutoChart02SecurityPatchesOverallDataResults.count) - $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.Value
        $script:AutoChart02SecurityPatchesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02SecurityPatchesOverallDataResults.count) - $script:AutoChart02SecurityPatchesTrimOffLastTrackBar.Value)"
        $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
        $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02SecurityPatchesTrimOffLastGroupBox.Controls.Add($script:AutoChart02SecurityPatchesTrimOffLastTrackBar)
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatchesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02SecurityPatchesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02SecurityPatchesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SecurityPatchesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].ChartType = $script:AutoChart02SecurityPatchesChartTypeComboBox.SelectedItem
#    $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
#    $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02SecurityPatchesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02SecurityPatchesChartTypesAvailable) { $script:AutoChart02SecurityPatchesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatchesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02SecurityPatches3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02SecurityPatchesChartTypeComboBox.Location.X + $script:AutoChart02SecurityPatchesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02SecurityPatchesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatches3DToggleButton
$script:AutoChart02SecurityPatches3DInclination = 0
$script:AutoChart02SecurityPatches3DToggleButton.Add_Click({
    $script:AutoChart02SecurityPatches3DInclination += 10
    if ( $script:AutoChart02SecurityPatches3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02SecurityPatchesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart02SecurityPatches3DInclination
        $script:AutoChart02SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart02SecurityPatches3DInclination)"
#        $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02SecurityPatches3DInclination -le 90 ) {
        $script:AutoChart02SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart02SecurityPatches3DInclination
        $script:AutoChart02SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart02SecurityPatches3DInclination)"
#        $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02SecurityPatches3DToggleButton.Text  = "3D Off"
        $script:AutoChart02SecurityPatches3DInclination = 0
        $script:AutoChart02SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart02SecurityPatches3DInclination
        $script:AutoChart02SecurityPatchesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
#        $script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatches3DToggleButton)

### Change the color of the chart
$script:AutoChart02SecurityPatchesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02SecurityPatches3DToggleButton.Location.X + $script:AutoChart02SecurityPatches3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SecurityPatches3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SecurityPatchesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02SecurityPatchesColorsAvailable) { $script:AutoChart02SecurityPatchesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02SecurityPatchesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Color = $script:AutoChart02SecurityPatchesChangeColorComboBox.SelectedItem
})
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatchesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02SecurityPatchesImportCsvPosResults = $script:AutoChartDataSourceCsvSecurityPatches | Where-Object 'Name' -eq $($script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02SecurityPatchesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SecurityPatchesImportCsvPosResults) { $script:AutoChart02SecurityPatchesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02SecurityPatchesImportCsvAll = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02SecurityPatchesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02SecurityPatchesImportCsvAll) { if ($Endpoint -notin $script:AutoChart02SecurityPatchesImportCsvPosResults) { $script:AutoChart02SecurityPatchesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02SecurityPatchesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SecurityPatchesImportCsvNegResults) { $script:AutoChart02SecurityPatchesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02SecurityPatchesImportCsvPosResults.count))"
    $script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02SecurityPatchesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02SecurityPatchesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02SecurityPatchesTrimOffLastGroupBox.Location.X + $script:AutoChart02SecurityPatchesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SecurityPatchesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesCheckDiffButton
$script:AutoChart02SecurityPatchesCheckDiffButton.Add_Click({
    $script:AutoChart02SecurityPatchesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02SecurityPatchesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02SecurityPatchesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SecurityPatchesInvestDiffDropDownLabel.Location.y + $script:AutoChart02SecurityPatchesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02SecurityPatchesInvestDiffDropDownArray) { $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02SecurityPatchesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Location.y + $script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesInvestDiffExecuteButton
    $script:AutoChart02SecurityPatchesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SecurityPatchesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SecurityPatchesInvestDiffExecuteButton.Location.y + $script:AutoChart02SecurityPatchesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SecurityPatchesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Location.y + $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Location.x + $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SecurityPatchesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel.Location.y + $script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02SecurityPatchesInvestDiffForm.Controls.AddRange(@($script:AutoChart02SecurityPatchesInvestDiffDropDownLabel,$script:AutoChart02SecurityPatchesInvestDiffDropDownComboBox,$script:AutoChart02SecurityPatchesInvestDiffExecuteButton,$script:AutoChart02SecurityPatchesInvestDiffPosResultsLabel,$script:AutoChart02SecurityPatchesInvestDiffPosResultsTextBox,$script:AutoChart02SecurityPatchesInvestDiffNegResultsLabel,$script:AutoChart02SecurityPatchesInvestDiffNegResultsTextBox))
    $script:AutoChart02SecurityPatchesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02SecurityPatchesInvestDiffForm.ShowDialog()
})
$script:AutoChart02SecurityPatchesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02SecurityPatchesManipulationPanel.controls.Add($script:AutoChart02SecurityPatchesCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02SecurityPatchesCheckDiffButton.Location.X + $script:AutoChart02SecurityPatchesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02SecurityPatchesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSecurityPatchesFileName -QueryName "Security Patches" -QueryTabName "Security Patches Per Host" -PropertyX "PSComputerName" -PropertyY "HotFixID" }
}
Apply-CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02SecurityPatchesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02SecurityPatchesCheckDiffButton.Location.X
                   Y = $script:AutoChart02SecurityPatchesCheckDiffButton.Location.Y + $script:AutoChart02SecurityPatchesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesOpenInShell
$script:AutoChart02SecurityPatchesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02SecurityPatchesManipulationPanel.controls.Add($script:AutoChart02SecurityPatchesOpenInShell)


$script:AutoChart02SecurityPatchesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02SecurityPatchesOpenInShell.Location.X + $script:AutoChart02SecurityPatchesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SecurityPatchesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesViewResults
$script:AutoChart02SecurityPatchesViewResults.Add_Click({ $script:AutoChartDataSourceCsvSecurityPatches | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02SecurityPatchesManipulationPanel.controls.Add($script:AutoChart02SecurityPatchesViewResults)


### Save the chart to file
$script:AutoChart02SecurityPatchesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02SecurityPatchesOpenInShell.Location.X
                  Y = $script:AutoChart02SecurityPatchesOpenInShell.Location.Y + $script:AutoChart02SecurityPatchesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02SecurityPatchesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SecurityPatchesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02SecurityPatches -Title $script:AutoChart02SecurityPatchesTitle
})
$script:AutoChart02SecurityPatchesManipulationPanel.controls.Add($script:AutoChart02SecurityPatchesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02SecurityPatchesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SecurityPatchesSaveButton.Location.X
                        Y = $script:AutoChart02SecurityPatchesSaveButton.Location.Y + $script:AutoChart02SecurityPatchesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02SecurityPatchesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart02SecurityPatchesNoticeTextbox)

$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.Clear()
$script:AutoChart02SecurityPatchesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SecurityPatches.Series["Security Patches Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03SecurityPatches = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01SecurityPatches.Location.X
                  Y = $script:AutoChart01SecurityPatches.Location.Y + $script:AutoChart01SecurityPatches.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03SecurityPatches.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03SecurityPatchesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03SecurityPatches.Titles.Add($script:AutoChart03SecurityPatchesTitle)

### Create Charts Area
$script:AutoChart03SecurityPatchesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03SecurityPatchesArea.Name        = 'Chart Area'
$script:AutoChart03SecurityPatchesArea.AxisX.Title = 'Hosts'
$script:AutoChart03SecurityPatchesArea.AxisX.Interval          = 1
$script:AutoChart03SecurityPatchesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03SecurityPatchesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03SecurityPatchesArea.Area3DStyle.Inclination = 75
$script:AutoChart03SecurityPatches.ChartAreas.Add($script:AutoChart03SecurityPatchesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03SecurityPatches.Series.Add("Service Pack In Effect")
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Enabled           = $True
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].BorderWidth       = 1
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].IsVisibleInLegend = $false
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Chartarea         = 'Chart Area'
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Legend            = 'Legend'
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"]['PieLineColor']   = 'Black'
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].ChartType         = 'Column'
$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03SecurityPatchesCsvFileHosts      = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03SecurityPatchesUniqueDataFields  = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'ServicePackInEffect' | Sort-Object -Property 'ServicePackInEffect' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03SecurityPatchesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()

            if ($script:AutoChart03SecurityPatchesUniqueDataFields.count -gt 0){
                $script:AutoChart03SecurityPatchesTitle.ForeColor = 'Black'
                $script:AutoChart03SecurityPatchesTitle.Text = "Service Pack In Effect"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03SecurityPatchesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03SecurityPatchesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03SecurityPatchesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSecurityPatches ) {
                        if ($Line.ServicePackInEffect -eq $DataField.ServicePackInEffect) {
                            $Count += 1
                            if ( $script:AutoChart03SecurityPatchesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03SecurityPatchesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03SecurityPatchesUniqueCount = $script:AutoChart03SecurityPatchesCsvComputers.Count
                    $script:AutoChart03SecurityPatchesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03SecurityPatchesUniqueCount
                        Computers   = $script:AutoChart03SecurityPatchesCsvComputers
                    }
                    $script:AutoChart03SecurityPatchesOverallDataResults += $script:AutoChart03SecurityPatchesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount) }

                $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SecurityPatchesOverallDataResults.count))
                $script:AutoChart03SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SecurityPatchesOverallDataResults.count))
            }
            else {
                $script:AutoChart03SecurityPatchesTitle.ForeColor = 'Red'
                $script:AutoChart03SecurityPatchesTitle.Text = "Service Pack In Effect`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03SecurityPatchesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03SecurityPatches.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03SecurityPatches.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesOptionsButton
$script:AutoChart03SecurityPatchesOptionsButton.Add_Click({
    if ($script:AutoChart03SecurityPatchesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03SecurityPatchesOptionsButton.Text = 'Options ^'
        $script:AutoChart03SecurityPatches.Controls.Add($script:AutoChart03SecurityPatchesManipulationPanel)
    }
    elseif ($script:AutoChart03SecurityPatchesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03SecurityPatchesOptionsButton.Text = 'Options v'
        $script:AutoChart03SecurityPatches.Controls.Remove($script:AutoChart03SecurityPatchesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03SecurityPatchesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03SecurityPatches)

$script:AutoChart03SecurityPatchesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03SecurityPatches.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03SecurityPatches.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03SecurityPatchesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03SecurityPatchesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SecurityPatchesOverallDataResults.count))
    $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03SecurityPatchesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue = $script:AutoChart03SecurityPatchesTrimOffFirstTrackBar.Value
        $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03SecurityPatchesTrimOffFirstTrackBar.Value)"
        $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
        $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    })
    $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Controls.Add($script:AutoChart03SecurityPatchesTrimOffFirstTrackBar)
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatchesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03SecurityPatchesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Location.X + $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SecurityPatchesOverallDataResults.count))
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.Value         = $($script:AutoChart03SecurityPatchesOverallDataResults.count)
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue   = 0
    $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue = $($script:AutoChart03SecurityPatchesOverallDataResults.count) - $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.Value
        $script:AutoChart03SecurityPatchesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03SecurityPatchesOverallDataResults.count) - $script:AutoChart03SecurityPatchesTrimOffLastTrackBar.Value)"
        $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
        $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    })
$script:AutoChart03SecurityPatchesTrimOffLastGroupBox.Controls.Add($script:AutoChart03SecurityPatchesTrimOffLastTrackBar)
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatchesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03SecurityPatchesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Location.Y + $script:AutoChart03SecurityPatchesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SecurityPatchesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].ChartType = $script:AutoChart03SecurityPatchesChartTypeComboBox.SelectedItem
#    $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
#    $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
})
$script:AutoChart03SecurityPatchesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03SecurityPatchesChartTypesAvailable) { $script:AutoChart03SecurityPatchesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatchesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03SecurityPatches3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03SecurityPatchesChartTypeComboBox.Location.X + $script:AutoChart03SecurityPatchesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03SecurityPatchesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatches3DToggleButton
$script:AutoChart03SecurityPatches3DInclination = 0
$script:AutoChart03SecurityPatches3DToggleButton.Add_Click({
    $script:AutoChart03SecurityPatches3DInclination += 10
    if ( $script:AutoChart03SecurityPatches3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03SecurityPatchesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart03SecurityPatches3DInclination
        $script:AutoChart03SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart03SecurityPatches3DInclination)"
#        $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03SecurityPatches3DInclination -le 90 ) {
        $script:AutoChart03SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart03SecurityPatches3DInclination
        $script:AutoChart03SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart03SecurityPatches3DInclination)"
#        $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03SecurityPatches3DToggleButton.Text  = "3D Off"
        $script:AutoChart03SecurityPatches3DInclination = 0
        $script:AutoChart03SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart03SecurityPatches3DInclination
        $script:AutoChart03SecurityPatchesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
#        $script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}
    }
})
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatches3DToggleButton)

### Change the color of the chart
$script:AutoChart03SecurityPatchesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03SecurityPatches3DToggleButton.Location.X + $script:AutoChart03SecurityPatches3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SecurityPatches3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SecurityPatchesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03SecurityPatchesColorsAvailable) { $script:AutoChart03SecurityPatchesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03SecurityPatchesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Color = $script:AutoChart03SecurityPatchesChangeColorComboBox.SelectedItem
})
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatchesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03SecurityPatchesImportCsvPosResults = $script:AutoChartDataSourceCsvSecurityPatches | Where-Object 'ServicePackInEffect' -eq $($script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03SecurityPatchesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SecurityPatchesImportCsvPosResults) { $script:AutoChart03SecurityPatchesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03SecurityPatchesImportCsvAll = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03SecurityPatchesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03SecurityPatchesImportCsvAll) { if ($Endpoint -notin $script:AutoChart03SecurityPatchesImportCsvPosResults) { $script:AutoChart03SecurityPatchesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03SecurityPatchesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SecurityPatchesImportCsvNegResults) { $script:AutoChart03SecurityPatchesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03SecurityPatchesImportCsvPosResults.count))"
    $script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03SecurityPatchesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03SecurityPatchesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03SecurityPatchesTrimOffLastGroupBox.Location.X + $script:AutoChart03SecurityPatchesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SecurityPatchesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesCheckDiffButton
$script:AutoChart03SecurityPatchesCheckDiffButton.Add_Click({
    $script:AutoChart03SecurityPatchesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'ServicePackInEffect' -ExpandProperty 'ServicePackInEffect' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03SecurityPatchesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03SecurityPatchesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SecurityPatchesInvestDiffDropDownLabel.Location.y + $script:AutoChart03SecurityPatchesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03SecurityPatchesInvestDiffDropDownArray) { $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03SecurityPatchesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Location.y + $script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesInvestDiffExecuteButton
    $script:AutoChart03SecurityPatchesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SecurityPatchesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SecurityPatchesInvestDiffExecuteButton.Location.y + $script:AutoChart03SecurityPatchesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SecurityPatchesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Location.y + $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Location.x + $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SecurityPatchesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel.Location.y + $script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03SecurityPatchesInvestDiffForm.Controls.AddRange(@($script:AutoChart03SecurityPatchesInvestDiffDropDownLabel,$script:AutoChart03SecurityPatchesInvestDiffDropDownComboBox,$script:AutoChart03SecurityPatchesInvestDiffExecuteButton,$script:AutoChart03SecurityPatchesInvestDiffPosResultsLabel,$script:AutoChart03SecurityPatchesInvestDiffPosResultsTextBox,$script:AutoChart03SecurityPatchesInvestDiffNegResultsLabel,$script:AutoChart03SecurityPatchesInvestDiffNegResultsTextBox))
    $script:AutoChart03SecurityPatchesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03SecurityPatchesInvestDiffForm.ShowDialog()
})
$script:AutoChart03SecurityPatchesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03SecurityPatchesManipulationPanel.controls.Add($script:AutoChart03SecurityPatchesCheckDiffButton)


$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03SecurityPatchesCheckDiffButton.Location.X + $script:AutoChart03SecurityPatchesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03SecurityPatchesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSecurityPatchesFileName -QueryName "Security Patches" -QueryTabName "Service Pack In Effect" -PropertyX "ServicePackInEffect" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03SecurityPatchesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03SecurityPatchesCheckDiffButton.Location.X
                   Y = $script:AutoChart03SecurityPatchesCheckDiffButton.Location.Y + $script:AutoChart03SecurityPatchesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesOpenInShell
$script:AutoChart03SecurityPatchesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03SecurityPatchesManipulationPanel.controls.Add($script:AutoChart03SecurityPatchesOpenInShell)


$script:AutoChart03SecurityPatchesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03SecurityPatchesOpenInShell.Location.X + $script:AutoChart03SecurityPatchesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SecurityPatchesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesViewResults
$script:AutoChart03SecurityPatchesViewResults.Add_Click({ $script:AutoChartDataSourceCsvSecurityPatches | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03SecurityPatchesManipulationPanel.controls.Add($script:AutoChart03SecurityPatchesViewResults)


### Save the chart to file
$script:AutoChart03SecurityPatchesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03SecurityPatchesOpenInShell.Location.X
                  Y = $script:AutoChart03SecurityPatchesOpenInShell.Location.Y + $script:AutoChart03SecurityPatchesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03SecurityPatchesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SecurityPatchesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03SecurityPatches -Title $script:AutoChart03SecurityPatchesTitle
})
$script:AutoChart03SecurityPatchesManipulationPanel.controls.Add($script:AutoChart03SecurityPatchesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03SecurityPatchesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SecurityPatchesSaveButton.Location.X
                        Y = $script:AutoChart03SecurityPatchesSaveButton.Location.Y + $script:AutoChart03SecurityPatchesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03SecurityPatchesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart03SecurityPatchesNoticeTextbox)

$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.Clear()
$script:AutoChart03SecurityPatchesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SecurityPatches.Series["Service Pack In Effect"].Points.AddXY($_.DataField.ServicePackInEffect,$_.UniqueCount)}





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04SecurityPatches = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02SecurityPatches.Location.X
                  Y = $script:AutoChart02SecurityPatches.Location.Y + $script:AutoChart02SecurityPatches.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04SecurityPatches.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04SecurityPatchesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04SecurityPatches.Titles.Add($script:AutoChart04SecurityPatchesTitle)

### Create Charts Area
$script:AutoChart04SecurityPatchesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04SecurityPatchesArea.Name        = 'Chart Area'
$script:AutoChart04SecurityPatchesArea.AxisX.Title = 'Hosts'
$script:AutoChart04SecurityPatchesArea.AxisX.Interval          = 1
$script:AutoChart04SecurityPatchesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04SecurityPatchesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04SecurityPatchesArea.Area3DStyle.Inclination = 75
$script:AutoChart04SecurityPatches.ChartAreas.Add($script:AutoChart04SecurityPatchesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04SecurityPatches.Series.Add("Install Date")
$script:AutoChart04SecurityPatches.Series["Install Date"].Enabled           = $True
$script:AutoChart04SecurityPatches.Series["Install Date"].BorderWidth       = 1
$script:AutoChart04SecurityPatches.Series["Install Date"].IsVisibleInLegend = $false
$script:AutoChart04SecurityPatches.Series["Install Date"].Chartarea         = 'Chart Area'
$script:AutoChart04SecurityPatches.Series["Install Date"].Legend            = 'Legend'
$script:AutoChart04SecurityPatches.Series["Install Date"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04SecurityPatches.Series["Install Date"]['PieLineColor']   = 'Black'
$script:AutoChart04SecurityPatches.Series["Install Date"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04SecurityPatches.Series["Install Date"].ChartType         = 'Bar'
$script:AutoChart04SecurityPatches.Series["Install Date"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04SecurityPatchesCsvFileHosts      = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04SecurityPatchesUniqueDataFields  = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'InstalledOn' | Sort-Object -Property 'InstalledOn' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04SecurityPatchesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()

            if ($script:AutoChart04SecurityPatchesUniqueDataFields.count -gt 0){
                $script:AutoChart04SecurityPatchesTitle.ForeColor = 'Black'
                $script:AutoChart04SecurityPatchesTitle.Text = "Install Date"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04SecurityPatchesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04SecurityPatchesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04SecurityPatchesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSecurityPatches ) {
                        if ($($Line.InstalledOn) -eq $DataField.InstalledOn) {
                            $Count += 1
                            if ( $script:AutoChart04SecurityPatchesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04SecurityPatchesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04SecurityPatchesUniqueCount = $script:AutoChart04SecurityPatchesCsvComputers.Count
                    $script:AutoChart04SecurityPatchesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04SecurityPatchesUniqueCount
                        Computers   = $script:AutoChart04SecurityPatchesCsvComputers
                    }
                    $script:AutoChart04SecurityPatchesOverallDataResults += $script:AutoChart04SecurityPatchesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | ForEach-Object { $script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount) }

                $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SecurityPatchesOverallDataResults.count))
                $script:AutoChart04SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SecurityPatchesOverallDataResults.count))
            }
            else {
                $script:AutoChart04SecurityPatchesTitle.ForeColor = 'Red'
                $script:AutoChart04SecurityPatchesTitle.Text = "Install Date`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04SecurityPatchesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04SecurityPatches.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04SecurityPatches.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesOptionsButton
$script:AutoChart04SecurityPatchesOptionsButton.Add_Click({
    if ($script:AutoChart04SecurityPatchesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04SecurityPatchesOptionsButton.Text = 'Options ^'
        $script:AutoChart04SecurityPatches.Controls.Add($script:AutoChart04SecurityPatchesManipulationPanel)
    }
    elseif ($script:AutoChart04SecurityPatchesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04SecurityPatchesOptionsButton.Text = 'Options v'
        $script:AutoChart04SecurityPatches.Controls.Remove($script:AutoChart04SecurityPatchesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04SecurityPatchesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04SecurityPatches)

$script:AutoChart04SecurityPatchesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04SecurityPatches.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04SecurityPatches.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04SecurityPatchesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04SecurityPatchesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04SecurityPatchesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SecurityPatchesOverallDataResults.count))
    $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04SecurityPatchesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue = $script:AutoChart04SecurityPatchesTrimOffFirstTrackBar.Value
        $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04SecurityPatchesTrimOffFirstTrackBar.Value)"
        $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
        $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    })
    $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Controls.Add($script:AutoChart04SecurityPatchesTrimOffFirstTrackBar)
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatchesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04SecurityPatchesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Location.X + $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SecurityPatchesOverallDataResults.count))
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.Value         = $($script:AutoChart04SecurityPatchesOverallDataResults.count)
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue   = 0
    $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue = $($script:AutoChart04SecurityPatchesOverallDataResults.count) - $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.Value
        $script:AutoChart04SecurityPatchesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04SecurityPatchesOverallDataResults.count) - $script:AutoChart04SecurityPatchesTrimOffLastTrackBar.Value)"
        $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
        $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    })
$script:AutoChart04SecurityPatchesTrimOffLastGroupBox.Controls.Add($script:AutoChart04SecurityPatchesTrimOffLastTrackBar)
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatchesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04SecurityPatchesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Location.Y + $script:AutoChart04SecurityPatchesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SecurityPatchesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04SecurityPatches.Series["Install Date"].ChartType = $script:AutoChart04SecurityPatchesChartTypeComboBox.SelectedItem
#    $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
#    $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
})
$script:AutoChart04SecurityPatchesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04SecurityPatchesChartTypesAvailable) { $script:AutoChart04SecurityPatchesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatchesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04SecurityPatches3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04SecurityPatchesChartTypeComboBox.Location.X + $script:AutoChart04SecurityPatchesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04SecurityPatchesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatches3DToggleButton
$script:AutoChart04SecurityPatches3DInclination = 0
$script:AutoChart04SecurityPatches3DToggleButton.Add_Click({
    $script:AutoChart04SecurityPatches3DInclination += 10
    if ( $script:AutoChart04SecurityPatches3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04SecurityPatchesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart04SecurityPatches3DInclination
        $script:AutoChart04SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart04SecurityPatches3DInclination)"
#        $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
#        $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04SecurityPatches3DInclination -le 90 ) {
        $script:AutoChart04SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart04SecurityPatches3DInclination
        $script:AutoChart04SecurityPatches3DToggleButton.Text  = "3D On ($script:AutoChart04SecurityPatches3DInclination)"
#        $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
#        $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04SecurityPatches3DToggleButton.Text  = "3D Off"
        $script:AutoChart04SecurityPatches3DInclination = 0
        $script:AutoChart04SecurityPatchesArea.Area3DStyle.Inclination = $script:AutoChart04SecurityPatches3DInclination
        $script:AutoChart04SecurityPatchesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
#        $script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}
    }
})
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatches3DToggleButton)

### Change the color of the chart
$script:AutoChart04SecurityPatchesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04SecurityPatches3DToggleButton.Location.X + $script:AutoChart04SecurityPatches3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SecurityPatches3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SecurityPatchesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04SecurityPatchesColorsAvailable) { $script:AutoChart04SecurityPatchesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04SecurityPatchesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04SecurityPatches.Series["Install Date"].Color = $script:AutoChart04SecurityPatchesChangeColorComboBox.SelectedItem
})
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatchesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04SecurityPatchesImportCsvPosResults = $script:AutoChartDataSourceCsvSecurityPatches | Where-Object 'InstalledOn' -eq $($script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04SecurityPatchesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SecurityPatchesImportCsvPosResults) { $script:AutoChart04SecurityPatchesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04SecurityPatchesImportCsvAll = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04SecurityPatchesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04SecurityPatchesImportCsvAll) { if ($Endpoint -notin $script:AutoChart04SecurityPatchesImportCsvPosResults) { $script:AutoChart04SecurityPatchesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04SecurityPatchesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SecurityPatchesImportCsvNegResults) { $script:AutoChart04SecurityPatchesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04SecurityPatchesImportCsvPosResults.count))"
    $script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04SecurityPatchesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04SecurityPatchesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04SecurityPatchesTrimOffLastGroupBox.Location.X + $script:AutoChart04SecurityPatchesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SecurityPatchesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesCheckDiffButton
$script:AutoChart04SecurityPatchesCheckDiffButton.Add_Click({
    $script:AutoChart04SecurityPatchesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSecurityPatches | Select-Object -Property 'InstalledOn' -ExpandProperty 'InstalledOn' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04SecurityPatchesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04SecurityPatchesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SecurityPatchesInvestDiffDropDownLabel.Location.y + $script:AutoChart04SecurityPatchesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04SecurityPatchesInvestDiffDropDownArray) { $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04SecurityPatchesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Location.y + $script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesInvestDiffExecuteButton
    $script:AutoChart04SecurityPatchesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SecurityPatchesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SecurityPatchesInvestDiffExecuteButton.Location.y + $script:AutoChart04SecurityPatchesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SecurityPatchesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Location.y + $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Location.x + $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SecurityPatchesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel.Location.y + $script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04SecurityPatchesInvestDiffForm.Controls.AddRange(@($script:AutoChart04SecurityPatchesInvestDiffDropDownLabel,$script:AutoChart04SecurityPatchesInvestDiffDropDownComboBox,$script:AutoChart04SecurityPatchesInvestDiffExecuteButton,$script:AutoChart04SecurityPatchesInvestDiffPosResultsLabel,$script:AutoChart04SecurityPatchesInvestDiffPosResultsTextBox,$script:AutoChart04SecurityPatchesInvestDiffNegResultsLabel,$script:AutoChart04SecurityPatchesInvestDiffNegResultsTextBox))
    $script:AutoChart04SecurityPatchesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04SecurityPatchesInvestDiffForm.ShowDialog()
})
$script:AutoChart04SecurityPatchesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04SecurityPatchesManipulationPanel.controls.Add($script:AutoChart04SecurityPatchesCheckDiffButton)


$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04SecurityPatchesCheckDiffButton.Location.X + $script:AutoChart04SecurityPatchesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04SecurityPatchesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSecurityPatchesFileName -QueryName "Security Patches" -QueryTabName "Install Date" -PropertyX "InstalledOn" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04SecurityPatchesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04SecurityPatchesCheckDiffButton.Location.X
                   Y = $script:AutoChart04SecurityPatchesCheckDiffButton.Location.Y + $script:AutoChart04SecurityPatchesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesOpenInShell
$script:AutoChart04SecurityPatchesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04SecurityPatchesManipulationPanel.controls.Add($script:AutoChart04SecurityPatchesOpenInShell)


$script:AutoChart04SecurityPatchesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04SecurityPatchesOpenInShell.Location.X + $script:AutoChart04SecurityPatchesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SecurityPatchesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesViewResults
$script:AutoChart04SecurityPatchesViewResults.Add_Click({ $script:AutoChartDataSourceCsvSecurityPatches | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04SecurityPatchesManipulationPanel.controls.Add($script:AutoChart04SecurityPatchesViewResults)


### Save the chart to file
$script:AutoChart04SecurityPatchesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04SecurityPatchesOpenInShell.Location.X
                  Y = $script:AutoChart04SecurityPatchesOpenInShell.Location.Y + $script:AutoChart04SecurityPatchesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04SecurityPatchesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SecurityPatchesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04SecurityPatches -Title $script:AutoChart04SecurityPatchesTitle
})
$script:AutoChart04SecurityPatchesManipulationPanel.controls.Add($script:AutoChart04SecurityPatchesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04SecurityPatchesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SecurityPatchesSaveButton.Location.X
                        Y = $script:AutoChart04SecurityPatchesSaveButton.Location.Y + $script:AutoChart04SecurityPatchesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04SecurityPatchesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04SecurityPatchesManipulationPanel.Controls.Add($script:AutoChart04SecurityPatchesNoticeTextbox)

$script:AutoChart04SecurityPatches.Series["Install Date"].Points.Clear()
$script:AutoChart04SecurityPatchesOverallDataResults | Sort-Object { $_.DataField.InstalledOn -as [datetime] } | Select-Object -skip $script:AutoChart04SecurityPatchesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SecurityPatchesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SecurityPatches.Series["Install Date"].Points.AddXY($_.DataField.InstalledOn,$_.UniqueCount)}








# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtvfUJYg4i8pkoxrQXCdqU+N/
# X3KgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/E1HvAaC+WI7wsm/Ys6+bXs0/iowDQYJKoZI
# hvcNAQEBBQAEggEAOGg7aPs7z44gxy4QtBGdFtlj2Q7xF1wCVQgtLP82qhS2Ey9V
# yXFWMZ+vlwx/Cmiv4MlPnVT9jKDaW/L4gELOJFxBwqd9QP/SdyAGgqgDTHoxRgT0
# pZH0BxX60BQzJC2rDEL8UKntqUxKSj8QIjTNg+6S940DIW7GH1NiM1tYsaPZ5cid
# QwD61n+AetHhuX8sxAVf94Czpjpy+m6jJnQoLT21V6lGiQ674k/48rvaOUiZfqoP
# XUqXkMmBYUGHgYLIoTCaE99AzhVlGGhyOANPm2tJ0dbGdp7IbhFg2DKvf7WnNT9f
# ea9SOkWqx9EArwgiALQ3HvX8EzTrOedpw4trjg==
# SIG # End signature block
