$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'SMB Shares  '
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

$script:AutoChart01SmbShareCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'SMB Share') { $script:AutoChart01SmbShareCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01SmbShareCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsvSmbSharesSmbShares = $null
$script:AutoChartDataSourceCsvSmbSharesSmbShares = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart01SmbShare.Controls.Remove($script:AutoChart01SmbShareManipulationPanel)
    $script:AutoChart02SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart02SmbShare.Controls.Remove($script:AutoChart02SmbShareManipulationPanel)
    $script:AutoChart03SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart03SmbShare.Controls.Remove($script:AutoChart03SmbShareManipulationPanel)
    $script:AutoChart04SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart04SmbShare.Controls.Remove($script:AutoChart04SmbShareManipulationPanel)
    $script:AutoChart05SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart05SmbShare.Controls.Remove($script:AutoChart05SmbShareManipulationPanel)
    $script:AutoChart06SmbShareOptionsButton.Text = 'Options v'
    $script:AutoChart06SmbShare.Controls.Remove($script:AutoChart06SmbShareManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'SMB Share Info'
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
$script:AutoChart01SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01SmbShare.Titles.Add($script:AutoChart01SmbShareTitle)

### Create Charts Area
$script:AutoChart01SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01SmbShareArea.Name        = 'Chart Area'
$script:AutoChart01SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart01SmbShareArea.AxisX.Interval          = 1
$script:AutoChart01SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart01SmbShare.ChartAreas.Add($script:AutoChart01SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01SmbShare.Series.Add("Share Names")
$script:AutoChart01SmbShare.Series["Share Names"].Enabled           = $True
$script:AutoChart01SmbShare.Series["Share Names"].BorderWidth       = 1
$script:AutoChart01SmbShare.Series["Share Names"].IsVisibleInLegend = $false
$script:AutoChart01SmbShare.Series["Share Names"].Chartarea         = 'Chart Area'
$script:AutoChart01SmbShare.Series["Share Names"].Legend            = 'Legend'
$script:AutoChart01SmbShare.Series["Share Names"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01SmbShare.Series["Share Names"]['PieLineColor']   = 'Black'
$script:AutoChart01SmbShare.Series["Share Names"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01SmbShare.Series["Share Names"].ChartType         = 'Column'
$script:AutoChart01SmbShare.Series["Share Names"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01SmbShareCsvFileHosts      = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01SmbShareUniqueDataFields  = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()

            if ($script:AutoChart01SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart01SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart01SmbShareTitle.Text = "Share Names"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01SmbShareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01SmbShareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01SmbShareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSmbSharesSmbShares ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01SmbShareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01SmbShareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01SmbShareUniqueCount = $script:AutoChart01SmbShareCsvComputers.Count
                    $script:AutoChart01SmbShareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01SmbShareUniqueCount
                        Computers   = $script:AutoChart01SmbShareCsvComputers
                    }
                    $script:AutoChart01SmbShareOverallDataResults += $script:AutoChart01SmbShareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SmbShareOverallDataResults.count))
                $script:AutoChart01SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart01SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart01SmbShareTitle.Text = "Share Names`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareOptionsButton
$script:AutoChart01SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart01SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart01SmbShare.Controls.Add($script:AutoChart01SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart01SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart01SmbShare.Controls.Remove($script:AutoChart01SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01SmbShare)


$script:AutoChart01SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01SmbShareOverallDataResults.count))
    $script:AutoChart01SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01SmbShareTrimOffFirstTrackBarValue = $script:AutoChart01SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart01SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
        $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart01SmbShareTrimOffFirstTrackBar)
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart01SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01SmbShareOverallDataResults.count))
    $script:AutoChart01SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart01SmbShareOverallDataResults.count)
    $script:AutoChart01SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart01SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01SmbShareTrimOffLastTrackBarValue = $($script:AutoChart01SmbShareOverallDataResults.count) - $script:AutoChart01SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart01SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01SmbShareOverallDataResults.count) - $script:AutoChart01SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
        $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart01SmbShareTrimOffLastTrackBar)
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart01SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01SmbShare.Series["Share Names"].ChartType = $script:AutoChart01SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
#    $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01SmbShareChartTypesAvailable) { $script:AutoChart01SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShareChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01SmbShareChartTypeComboBox.Location.X + $script:AutoChart01SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShare3DToggleButton
$script:AutoChart01SmbShare3DInclination = 0
$script:AutoChart01SmbShare3DToggleButton.Add_Click({

    $script:AutoChart01SmbShare3DInclination += 10
    if ( $script:AutoChart01SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01SmbShareArea.Area3DStyle.Inclination = $script:AutoChart01SmbShare3DInclination
        $script:AutoChart01SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart01SmbShare3DInclination)"
#        $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
#        $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01SmbShare3DInclination -le 90 ) {
        $script:AutoChart01SmbShareArea.Area3DStyle.Inclination = $script:AutoChart01SmbShare3DInclination
        $script:AutoChart01SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart01SmbShare3DInclination)"
#        $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
#        $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart01SmbShare3DInclination = 0
        $script:AutoChart01SmbShareArea.Area3DStyle.Inclination = $script:AutoChart01SmbShare3DInclination
        $script:AutoChart01SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
#        $script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart01SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01SmbShare3DToggleButton.Location.X + $script:AutoChart01SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01SmbShareColorsAvailable) { $script:AutoChart01SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01SmbShare.Series["Share Names"].Color = $script:AutoChart01SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShareChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'Name' -eq $($script:AutoChart01SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SmbShareImportCsvPosResults) { $script:AutoChart01SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart01SmbShareImportCsvPosResults) { $script:AutoChart01SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01SmbShareImportCsvNegResults) { $script:AutoChart01SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01SmbShareImportCsvPosResults.count))"
    $script:AutoChart01SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart01SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareCheckDiffButton
$script:AutoChart01SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart01SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart01SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01SmbShareInvestDiffDropDownArray) { $script:AutoChart01SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart01SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareInvestDiffExecuteButton
    $script:AutoChart01SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart01SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart01SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart01SmbShareInvestDiffDropDownLabel,$script:AutoChart01SmbShareInvestDiffDropDownComboBox,$script:AutoChart01SmbShareInvestDiffExecuteButton,$script:AutoChart01SmbShareInvestDiffPosResultsLabel,$script:AutoChart01SmbShareInvestDiffPosResultsTextBox,$script:AutoChart01SmbShareInvestDiffNegResultsLabel,$script:AutoChart01SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart01SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart01SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01SmbShareManipulationPanel.controls.Add($script:AutoChart01SmbShareCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01SmbShareCheckDiffButton.Location.X + $script:AutoChart01SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Share Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart01SmbShareCheckDiffButton.Location.Y + $script:AutoChart01SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareOpenInShell
$script:AutoChart01SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01SmbShareManipulationPanel.controls.Add($script:AutoChart01SmbShareOpenInShell)


$script:AutoChart01SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01SmbShareOpenInShell.Location.X + $script:AutoChart01SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareViewResults
$script:AutoChart01SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01SmbShareManipulationPanel.controls.Add($script:AutoChart01SmbShareViewResults)


### Save the chart to file
$script:AutoChart01SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart01SmbShareOpenInShell.Location.Y + $script:AutoChart01SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart01SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01SmbShare -Title $script:AutoChart01SmbShareTitle
})
$script:AutoChart01SmbShareManipulationPanel.controls.Add($script:AutoChart01SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SmbShareSaveButton.Location.X
                        Y = $script:AutoChart01SmbShareSaveButton.Location.Y + $script:AutoChart01SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01SmbShareManipulationPanel.Controls.Add($script:AutoChart01SmbShareNoticeTextbox)

$script:AutoChart01SmbShare.Series["Share Names"].Points.Clear()
$script:AutoChart01SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01SmbShare.Series["Share Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01SmbShare.Location.X + $script:AutoChart01SmbShare.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01SmbShare.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02SmbShare.Titles.Add($script:AutoChart02SmbShareTitle)

### Create Charts Area
$script:AutoChart02SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02SmbShareArea.Name        = 'Chart Area'
$script:AutoChart02SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart02SmbShareArea.AxisX.Interval          = 1
$script:AutoChart02SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart02SmbShare.ChartAreas.Add($script:AutoChart02SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02SmbShare.Series.Add("Shares Per Host")
$script:AutoChart02SmbShare.Series["Shares Per Host"].Enabled           = $True
$script:AutoChart02SmbShare.Series["Shares Per Host"].BorderWidth       = 1
$script:AutoChart02SmbShare.Series["Shares Per Host"].IsVisibleInLegend = $false
$script:AutoChart02SmbShare.Series["Shares Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02SmbShare.Series["Shares Per Host"].Legend            = 'Legend'
$script:AutoChart02SmbShare.Series["Shares Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02SmbShare.Series["Shares Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02SmbShare.Series["Shares Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02SmbShare.Series["Shares Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02SmbShare.Series["Shares Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02SmbShareCsvFileHosts     = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).PSComputerName | Sort-Object -Unique
            $script:AutoChart02SmbShareUniqueDataFields = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart02SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart02SmbShareTitle.Text = "Shares Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02SmbShareOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvSmbSharesSmbShares | Sort-Object PSComputerName) ) {
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
                            $script:AutoChart02SmbShareOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02SmbShareOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02SmbShareOverallDataResults | ForEach-Object { $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
                $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SmbShareOverallDataResults.count))
                $script:AutoChart02SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
                $script:AutoChart02SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart02SmbShareTitle.Text = "Shares Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareOptionsButton
$script:AutoChart02SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart02SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart02SmbShare.Controls.Add($script:AutoChart02SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart02SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart02SmbShare.Controls.Remove($script:AutoChart02SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02SmbShare)

$script:AutoChart02SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02SmbShareOverallDataResults.count))
    $script:AutoChart02SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02SmbShareTrimOffFirstTrackBarValue = $script:AutoChart02SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart02SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
        $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart02SmbShareTrimOffFirstTrackBar)
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart02SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02SmbShareOverallDataResults.count))
    $script:AutoChart02SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart02SmbShareOverallDataResults.count)
    $script:AutoChart02SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart02SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02SmbShareTrimOffLastTrackBarValue = $($script:AutoChart02SmbShareOverallDataResults.count) - $script:AutoChart02SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart02SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02SmbShareOverallDataResults.count) - $script:AutoChart02SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
        $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart02SmbShareTrimOffLastTrackBar)
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart02SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02SmbShare.Series["Shares Per Host"].ChartType = $script:AutoChart02SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
#    $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02SmbShareChartTypesAvailable) { $script:AutoChart02SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02SmbShareChartTypeComboBox.Location.X + $script:AutoChart02SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShare3DToggleButton
$script:AutoChart02SmbShare3DInclination = 0
$script:AutoChart02SmbShare3DToggleButton.Add_Click({
    $script:AutoChart02SmbShare3DInclination += 10
    if ( $script:AutoChart02SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02SmbShareArea.Area3DStyle.Inclination = $script:AutoChart02SmbShare3DInclination
        $script:AutoChart02SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart02SmbShare3DInclination)"
#        $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02SmbShare3DInclination -le 90 ) {
        $script:AutoChart02SmbShareArea.Area3DStyle.Inclination = $script:AutoChart02SmbShare3DInclination
        $script:AutoChart02SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart02SmbShare3DInclination)"
#        $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart02SmbShare3DInclination = 0
        $script:AutoChart02SmbShareArea.Area3DStyle.Inclination = $script:AutoChart02SmbShare3DInclination
        $script:AutoChart02SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
#        $script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart02SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02SmbShare3DToggleButton.Location.X + $script:AutoChart02SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02SmbShareColorsAvailable) { $script:AutoChart02SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02SmbShare.Series["Shares Per Host"].Color = $script:AutoChart02SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'Name' -eq $($script:AutoChart02SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SmbShareImportCsvPosResults) { $script:AutoChart02SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart02SmbShareImportCsvPosResults) { $script:AutoChart02SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02SmbShareImportCsvNegResults) { $script:AutoChart02SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02SmbShareImportCsvPosResults.count))"
    $script:AutoChart02SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart02SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareCheckDiffButton
$script:AutoChart02SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart02SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart02SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02SmbShareInvestDiffDropDownArray) { $script:AutoChart02SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart02SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareInvestDiffExecuteButton
    $script:AutoChart02SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart02SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart02SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart02SmbShareInvestDiffDropDownLabel,$script:AutoChart02SmbShareInvestDiffDropDownComboBox,$script:AutoChart02SmbShareInvestDiffExecuteButton,$script:AutoChart02SmbShareInvestDiffPosResultsLabel,$script:AutoChart02SmbShareInvestDiffPosResultsTextBox,$script:AutoChart02SmbShareInvestDiffNegResultsLabel,$script:AutoChart02SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart02SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart02SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02SmbShareManipulationPanel.controls.Add($script:AutoChart02SmbShareCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02SmbShareCheckDiffButton.Location.X + $script:AutoChart02SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Shares Per Host" -PropertyX "PSComputerName" -PropertyY "Name" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart02SmbShareCheckDiffButton.Location.Y + $script:AutoChart02SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareOpenInShell
$script:AutoChart02SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02SmbShareManipulationPanel.controls.Add($script:AutoChart02SmbShareOpenInShell)


$script:AutoChart02SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02SmbShareOpenInShell.Location.X + $script:AutoChart02SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareViewResults
$script:AutoChart02SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02SmbShareManipulationPanel.controls.Add($script:AutoChart02SmbShareViewResults)


### Save the chart to file
$script:AutoChart02SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart02SmbShareOpenInShell.Location.Y + $script:AutoChart02SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart02SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02SmbShare -Title $script:AutoChart02SmbShareTitle
})
$script:AutoChart02SmbShareManipulationPanel.controls.Add($script:AutoChart02SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SmbShareSaveButton.Location.X
                        Y = $script:AutoChart02SmbShareSaveButton.Location.Y + $script:AutoChart02SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02SmbShareManipulationPanel.Controls.Add($script:AutoChart02SmbShareNoticeTextbox)

$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.Clear()
$script:AutoChart02SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02SmbShare.Series["Shares Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

























##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01SmbShare.Location.X
                  Y = $script:AutoChart01SmbShare.Location.Y + $script:AutoChart01SmbShare.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03SmbShare.Titles.Add($script:AutoChart03SmbShareTitle)

### Create Charts Area
$script:AutoChart03SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03SmbShareArea.Name        = 'Chart Area'
$script:AutoChart03SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart03SmbShareArea.AxisX.Interval          = 1
$script:AutoChart03SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart03SmbShare.ChartAreas.Add($script:AutoChart03SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03SmbShare.Series.Add("Share Paths")
$script:AutoChart03SmbShare.Series["Share Paths"].Enabled           = $True
$script:AutoChart03SmbShare.Series["Share Paths"].BorderWidth       = 1
$script:AutoChart03SmbShare.Series["Share Paths"].IsVisibleInLegend = $false
$script:AutoChart03SmbShare.Series["Share Paths"].Chartarea         = 'Chart Area'
$script:AutoChart03SmbShare.Series["Share Paths"].Legend            = 'Legend'
$script:AutoChart03SmbShare.Series["Share Paths"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03SmbShare.Series["Share Paths"]['PieLineColor']   = 'Black'
$script:AutoChart03SmbShare.Series["Share Paths"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03SmbShare.Series["Share Paths"].ChartType         = 'Column'
$script:AutoChart03SmbShare.Series["Share Paths"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03SmbShareCsvFileHosts      = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03SmbShareUniqueDataFields  = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Path' | Sort-Object -Property 'Path' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()

            if ($script:AutoChart03SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart03SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart03SmbShareTitle.Text = "Share Paths"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03SmbShareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03SmbShareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03SmbShareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSmbSharesSmbShares ) {
                        if ($Line.Path -eq $DataField.Path) {
                            $Count += 1
                            if ( $script:AutoChart03SmbShareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03SmbShareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03SmbShareUniqueCount = $script:AutoChart03SmbShareCsvComputers.Count
                    $script:AutoChart03SmbShareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03SmbShareUniqueCount
                        Computers   = $script:AutoChart03SmbShareCsvComputers
                    }
                    $script:AutoChart03SmbShareOverallDataResults += $script:AutoChart03SmbShareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount) }

                $script:AutoChart03SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SmbShareOverallDataResults.count))
                $script:AutoChart03SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart03SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart03SmbShareTitle.Text = "Share Paths`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareOptionsButton
$script:AutoChart03SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart03SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart03SmbShare.Controls.Add($script:AutoChart03SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart03SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart03SmbShare.Controls.Remove($script:AutoChart03SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03SmbShare)

$script:AutoChart03SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03SmbShareOverallDataResults.count))
    $script:AutoChart03SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03SmbShareTrimOffFirstTrackBarValue = $script:AutoChart03SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart03SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
        $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
    $script:AutoChart03SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart03SmbShareTrimOffFirstTrackBar)
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart03SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03SmbShareOverallDataResults.count))
    $script:AutoChart03SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart03SmbShareOverallDataResults.count)
    $script:AutoChart03SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart03SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03SmbShareTrimOffLastTrackBarValue = $($script:AutoChart03SmbShareOverallDataResults.count) - $script:AutoChart03SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart03SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03SmbShareOverallDataResults.count) - $script:AutoChart03SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
        $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
$script:AutoChart03SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart03SmbShareTrimOffLastTrackBar)
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart03SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03SmbShare.Series["Share Paths"].ChartType = $script:AutoChart03SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
#    $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
})
$script:AutoChart03SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03SmbShareChartTypesAvailable) { $script:AutoChart03SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03SmbShareChartTypeComboBox.Location.X + $script:AutoChart03SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShare3DToggleButton
$script:AutoChart03SmbShare3DInclination = 0
$script:AutoChart03SmbShare3DToggleButton.Add_Click({
    $script:AutoChart03SmbShare3DInclination += 10
    if ( $script:AutoChart03SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03SmbShareArea.Area3DStyle.Inclination = $script:AutoChart03SmbShare3DInclination
        $script:AutoChart03SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart03SmbShare3DInclination)"
#        $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
#        $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03SmbShare3DInclination -le 90 ) {
        $script:AutoChart03SmbShareArea.Area3DStyle.Inclination = $script:AutoChart03SmbShare3DInclination
        $script:AutoChart03SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart03SmbShare3DInclination)"
#        $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
#        $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart03SmbShare3DInclination = 0
        $script:AutoChart03SmbShareArea.Area3DStyle.Inclination = $script:AutoChart03SmbShare3DInclination
        $script:AutoChart03SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
#        $script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
})
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart03SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03SmbShare3DToggleButton.Location.X + $script:AutoChart03SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03SmbShareColorsAvailable) { $script:AutoChart03SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03SmbShare.Series["Share Paths"].Color = $script:AutoChart03SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'Path' -eq $($script:AutoChart03SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SmbShareImportCsvPosResults) { $script:AutoChart03SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart03SmbShareImportCsvPosResults) { $script:AutoChart03SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03SmbShareImportCsvNegResults) { $script:AutoChart03SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03SmbShareImportCsvPosResults.count))"
    $script:AutoChart03SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart03SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareCheckDiffButton
$script:AutoChart03SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart03SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Path' -ExpandProperty 'Path' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart03SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03SmbShareInvestDiffDropDownArray) { $script:AutoChart03SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart03SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareInvestDiffExecuteButton
    $script:AutoChart03SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart03SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart03SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart03SmbShareInvestDiffDropDownLabel,$script:AutoChart03SmbShareInvestDiffDropDownComboBox,$script:AutoChart03SmbShareInvestDiffExecuteButton,$script:AutoChart03SmbShareInvestDiffPosResultsLabel,$script:AutoChart03SmbShareInvestDiffPosResultsTextBox,$script:AutoChart03SmbShareInvestDiffNegResultsLabel,$script:AutoChart03SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart03SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart03SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03SmbShareManipulationPanel.controls.Add($script:AutoChart03SmbShareCheckDiffButton)


$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03SmbShareCheckDiffButton.Location.X + $script:AutoChart03SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Share Paths" -PropertyX "Path" -PropertyY "PSComputerName" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart03SmbShareCheckDiffButton.Location.Y + $script:AutoChart03SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareOpenInShell
$script:AutoChart03SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03SmbShareManipulationPanel.controls.Add($script:AutoChart03SmbShareOpenInShell)


$script:AutoChart03SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03SmbShareOpenInShell.Location.X + $script:AutoChart03SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareViewResults
$script:AutoChart03SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03SmbShareManipulationPanel.controls.Add($script:AutoChart03SmbShareViewResults)


### Save the chart to file
$script:AutoChart03SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart03SmbShareOpenInShell.Location.Y + $script:AutoChart03SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart03SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03SmbShare -Title $script:AutoChart03SmbShareTitle
})
$script:AutoChart03SmbShareManipulationPanel.controls.Add($script:AutoChart03SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SmbShareSaveButton.Location.X
                        Y = $script:AutoChart03SmbShareSaveButton.Location.Y + $script:AutoChart03SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03SmbShareManipulationPanel.Controls.Add($script:AutoChart03SmbShareNoticeTextbox)

$script:AutoChart03SmbShare.Series["Share Paths"].Points.Clear()
$script:AutoChart03SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03SmbShare.Series["Share Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}




























##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02SmbShare.Location.X
                  Y = $script:AutoChart02SmbShare.Location.Y + $script:AutoChart02SmbShare.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04SmbShare.Titles.Add($script:AutoChart04SmbShareTitle)

### Create Charts Area
$script:AutoChart04SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04SmbShareArea.Name        = 'Chart Area'
$script:AutoChart04SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart04SmbShareArea.AxisX.Interval          = 1
$script:AutoChart04SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart04SmbShare.ChartAreas.Add($script:AutoChart04SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04SmbShare.Series.Add("Current Users")
$script:AutoChart04SmbShare.Series["Current Users"].Enabled           = $True
$script:AutoChart04SmbShare.Series["Current Users"].BorderWidth       = 1
$script:AutoChart04SmbShare.Series["Current Users"].IsVisibleInLegend = $false
$script:AutoChart04SmbShare.Series["Current Users"].Chartarea         = 'Chart Area'
$script:AutoChart04SmbShare.Series["Current Users"].Legend            = 'Legend'
$script:AutoChart04SmbShare.Series["Current Users"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04SmbShare.Series["Current Users"]['PieLineColor']   = 'Black'
$script:AutoChart04SmbShare.Series["Current Users"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04SmbShare.Series["Current Users"].ChartType         = 'Column'
$script:AutoChart04SmbShare.Series["Current Users"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04SmbShareCsvFileHosts      = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04SmbShareUniqueDataFields  = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'CurrentUsers' | Sort-Object -Property 'CurrentUsers' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()

            if ($script:AutoChart04SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart04SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart04SmbShareTitle.Text = "Number of Current Users Accessing Shares On Endpoints"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04SmbShareOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04SmbShareUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04SmbShareCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvSmbSharesSmbShares ) {
                        if ($($Line.CurrentUsers) -eq $DataField.CurrentUsers) {
                            $Count += 1
                            if ( $script:AutoChart04SmbShareCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04SmbShareCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04SmbShareUniqueCount = $script:AutoChart04SmbShareCsvComputers.Count
                    $script:AutoChart04SmbShareDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04SmbShareUniqueCount
                        Computers   = $script:AutoChart04SmbShareCsvComputers
                    }
                    $script:AutoChart04SmbShareOverallDataResults += $script:AutoChart04SmbShareDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount) }

                $script:AutoChart04SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SmbShareOverallDataResults.count))
                $script:AutoChart04SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart04SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart04SmbShareTitle.Text = "Current Users`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareOptionsButton
$script:AutoChart04SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart04SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart04SmbShare.Controls.Add($script:AutoChart04SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart04SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart04SmbShare.Controls.Remove($script:AutoChart04SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04SmbShare)

$script:AutoChart04SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04SmbShareOverallDataResults.count))
    $script:AutoChart04SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04SmbShareTrimOffFirstTrackBarValue = $script:AutoChart04SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart04SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
        $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
    })
    $script:AutoChart04SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart04SmbShareTrimOffFirstTrackBar)
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart04SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04SmbShareOverallDataResults.count))
    $script:AutoChart04SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart04SmbShareOverallDataResults.count)
    $script:AutoChart04SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart04SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04SmbShareTrimOffLastTrackBarValue = $($script:AutoChart04SmbShareOverallDataResults.count) - $script:AutoChart04SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart04SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04SmbShareOverallDataResults.count) - $script:AutoChart04SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
        $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
    })
$script:AutoChart04SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart04SmbShareTrimOffLastTrackBar)
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart04SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04SmbShare.Series["Current Users"].ChartType = $script:AutoChart04SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
#    $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
})
$script:AutoChart04SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04SmbShareChartTypesAvailable) { $script:AutoChart04SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04SmbShareChartTypeComboBox.Location.X + $script:AutoChart04SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShare3DToggleButton
$script:AutoChart04SmbShare3DInclination = 0
$script:AutoChart04SmbShare3DToggleButton.Add_Click({
    $script:AutoChart04SmbShare3DInclination += 10
    if ( $script:AutoChart04SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04SmbShareArea.Area3DStyle.Inclination = $script:AutoChart04SmbShare3DInclination
        $script:AutoChart04SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart04SmbShare3DInclination)"
#        $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
#        $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04SmbShare3DInclination -le 90 ) {
        $script:AutoChart04SmbShareArea.Area3DStyle.Inclination = $script:AutoChart04SmbShare3DInclination
        $script:AutoChart04SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart04SmbShare3DInclination)"
#        $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
#        $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart04SmbShare3DInclination = 0
        $script:AutoChart04SmbShareArea.Area3DStyle.Inclination = $script:AutoChart04SmbShare3DInclination
        $script:AutoChart04SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
#        $script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}
    }
})
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart04SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04SmbShare3DToggleButton.Location.X + $script:AutoChart04SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04SmbShareColorsAvailable) { $script:AutoChart04SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04SmbShare.Series["Current Users"].Color = $script:AutoChart04SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'CurrentUsers' -eq $($script:AutoChart04SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SmbShareImportCsvPosResults) { $script:AutoChart04SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart04SmbShareImportCsvPosResults) { $script:AutoChart04SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04SmbShareImportCsvNegResults) { $script:AutoChart04SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04SmbShareImportCsvPosResults.count))"
    $script:AutoChart04SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart04SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareCheckDiffButton
$script:AutoChart04SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart04SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'CurrentUsers' -ExpandProperty 'CurrentUsers' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart04SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04SmbShareInvestDiffDropDownArray) { $script:AutoChart04SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart04SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareInvestDiffExecuteButton
    $script:AutoChart04SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart04SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart04SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart04SmbShareInvestDiffDropDownLabel,$script:AutoChart04SmbShareInvestDiffDropDownComboBox,$script:AutoChart04SmbShareInvestDiffExecuteButton,$script:AutoChart04SmbShareInvestDiffPosResultsLabel,$script:AutoChart04SmbShareInvestDiffPosResultsTextBox,$script:AutoChart04SmbShareInvestDiffNegResultsLabel,$script:AutoChart04SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart04SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart04SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04SmbShareManipulationPanel.controls.Add($script:AutoChart04SmbShareCheckDiffButton)


$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04SmbShareCheckDiffButton.Location.X + $script:AutoChart04SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Current Users" -PropertyX "CurrentUsers" -PropertyY "PSComputerName" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart04SmbShareCheckDiffButton.Location.Y + $script:AutoChart04SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareOpenInShell
$script:AutoChart04SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04SmbShareManipulationPanel.controls.Add($script:AutoChart04SmbShareOpenInShell)


$script:AutoChart04SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04SmbShareOpenInShell.Location.X + $script:AutoChart04SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareViewResults
$script:AutoChart04SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04SmbShareManipulationPanel.controls.Add($script:AutoChart04SmbShareViewResults)


### Save the chart to file
$script:AutoChart04SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart04SmbShareOpenInShell.Location.Y + $script:AutoChart04SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart04SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04SmbShare -Title $script:AutoChart04SmbShareTitle
})
$script:AutoChart04SmbShareManipulationPanel.controls.Add($script:AutoChart04SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SmbShareSaveButton.Location.X
                        Y = $script:AutoChart04SmbShareSaveButton.Location.Y + $script:AutoChart04SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04SmbShareManipulationPanel.Controls.Add($script:AutoChart04SmbShareNoticeTextbox)

$script:AutoChart04SmbShare.Series["Current Users"].Points.Clear()
$script:AutoChart04SmbShareOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04SmbShare.Series["Current Users"].Points.AddXY($_.DataField.CurrentUsers,$_.UniqueCount)}


























##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03SmbShare.Location.X
                  Y = $script:AutoChart03SmbShare.Location.Y + $script:AutoChart03SmbShare.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart05SmbShare.Titles.Add($script:AutoChart05SmbShareTitle)

### Create Charts Area
$script:AutoChart05SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05SmbShareArea.Name        = 'Chart Area'
$script:AutoChart05SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart05SmbShareArea.AxisX.Interval          = 1
$script:AutoChart05SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart05SmbShare.ChartAreas.Add($script:AutoChart05SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05SmbShare.Series.Add("Unencrypted Shares")
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Enabled           = $True
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].BorderWidth       = 1
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].IsVisibleInLegend = $false
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Chartarea         = 'Chart Area'
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Legend            = 'Legend'
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05SmbShare.Series["Unencrypted Shares"]['PieLineColor']   = 'Black'
$script:AutoChart05SmbShare.Series["Unencrypted Shares"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].ChartType         = 'Column'
$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Color             = 'Brown'

        function Generate-AutoChart05 {
            $script:AutoChart05SmbShareCsvFileHosts     = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).PSComputerName | Sort-Object -Unique
            $script:AutoChart05SmbShareUniqueDataFields = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart05SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart05SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart05SmbShareTitle.Text = "Unencrypted Shares"

                $AutoChart05CurrentComputer  = ''
                $AutoChart05CheckIfFirstLine = $false
                $AutoChart05ResultsCount     = 0
                $AutoChart05Computer         = @()
                $AutoChart05YResults         = @()
                $script:AutoChart05SmbShareOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object {$_.EncryptData -eq $false}| Sort-Object PSComputerName) ) {
                    if ( $AutoChart05CheckIfFirstLine -eq $false ) { $AutoChart05CurrentComputer  = $Line.PSComputerName ; $AutoChart05CheckIfFirstLine = $true }
                    if ( $AutoChart05CheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart05CurrentComputer ) {
                            if ( $AutoChart05YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart05YResults += $Line.Name ; $AutoChart05ResultsCount += 1 }
                                if ( $AutoChart05Computer -notcontains $Line.PSComputerName ) { $AutoChart05Computer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart05CurrentComputer ) {
                            $AutoChart05CurrentComputer = $Line.PSComputerName
                            $AutoChart05YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart05ResultsCount
                                Computer     = $AutoChart05Computer
                            }
                            $script:AutoChart05SmbShareOverallDataResults += $AutoChart05YDataResults
                            $AutoChart05YResults     = @()
                            $AutoChart05ResultsCount = 0
                            $AutoChart05Computer     = @()
                            if ( $AutoChart05YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart05YResults += $Line.Name ; $AutoChart05ResultsCount += 1 }
                                if ( $AutoChart05Computer -notcontains $Line.PSComputerName ) { $AutoChart05Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart05YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart05ResultsCount ; Computer = $AutoChart05Computer }
                $script:AutoChart05SmbShareOverallDataResults += $AutoChart05YDataResults
                $script:AutoChart05SmbShareOverallDataResults | ForEach-Object { $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
                $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart05SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05SmbShareOverallDataResults.count))
                $script:AutoChart05SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
                $script:AutoChart05SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart05SmbShareTitle.Text = "Unencrypted Shares`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareOptionsButton
$script:AutoChart05SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart05SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart05SmbShare.Controls.Add($script:AutoChart05SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart05SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart05SmbShare.Controls.Remove($script:AutoChart05SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05SmbShare)

$script:AutoChart05SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05SmbShareOverallDataResults.count))
    $script:AutoChart05SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05SmbShareTrimOffFirstTrackBarValue = $script:AutoChart05SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart05SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
        $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart05SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart05SmbShareTrimOffFirstTrackBar)
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart05SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart05SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05SmbShareOverallDataResults.count))
    $script:AutoChart05SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart05SmbShareOverallDataResults.count)
    $script:AutoChart05SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart05SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05SmbShareTrimOffLastTrackBarValue = $($script:AutoChart05SmbShareOverallDataResults.count) - $script:AutoChart05SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart05SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05SmbShareOverallDataResults.count) - $script:AutoChart05SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
        $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart05SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart05SmbShareTrimOffLastTrackBar)
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart05SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05SmbShare.Series["Unencrypted Shares"].ChartType = $script:AutoChart05SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
#    $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart05SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05SmbShareChartTypesAvailable) { $script:AutoChart05SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05SmbShareChartTypeComboBox.Location.X + $script:AutoChart05SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShare3DToggleButton
$script:AutoChart05SmbShare3DInclination = 0
$script:AutoChart05SmbShare3DToggleButton.Add_Click({
    $script:AutoChart05SmbShare3DInclination += 10
    if ( $script:AutoChart05SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05SmbShareArea.Area3DStyle.Inclination = $script:AutoChart05SmbShare3DInclination
        $script:AutoChart05SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart05SmbShare3DInclination)"
#        $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
#        $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart05SmbShare3DInclination -le 90 ) {
        $script:AutoChart05SmbShareArea.Area3DStyle.Inclination = $script:AutoChart05SmbShare3DInclination
        $script:AutoChart05SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart05SmbShare3DInclination)"
#        $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
#        $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart05SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart05SmbShare3DInclination = 0
        $script:AutoChart05SmbShareArea.Area3DStyle.Inclination = $script:AutoChart05SmbShare3DInclination
        $script:AutoChart05SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
#        $script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart05SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05SmbShare3DToggleButton.Location.X + $script:AutoChart05SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05SmbShareColorsAvailable) { $script:AutoChart05SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05SmbShare.Series["Unencrypted Shares"].Color = $script:AutoChart05SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {
    # List of Positive Endpoints that positively match
    $script:AutoChart05SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'Name' -eq $($script:AutoChart05SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05SmbShareImportCsvPosResults) { $script:AutoChart05SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart05SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart05SmbShareImportCsvPosResults) { $script:AutoChart05SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05SmbShareImportCsvNegResults) { $script:AutoChart05SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05SmbShareImportCsvPosResults.count))"
    $script:AutoChart05SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart05SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareCheckDiffButton
$script:AutoChart05SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart05SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart05SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05SmbShareInvestDiffDropDownArray) { $script:AutoChart05SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart05SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareInvestDiffExecuteButton
    $script:AutoChart05SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart05SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart05SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart05SmbShareInvestDiffDropDownLabel,$script:AutoChart05SmbShareInvestDiffDropDownComboBox,$script:AutoChart05SmbShareInvestDiffExecuteButton,$script:AutoChart05SmbShareInvestDiffPosResultsLabel,$script:AutoChart05SmbShareInvestDiffPosResultsTextBox,$script:AutoChart05SmbShareInvestDiffNegResultsLabel,$script:AutoChart05SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart05SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart05SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05SmbShareManipulationPanel.controls.Add($script:AutoChart05SmbShareCheckDiffButton)


$AutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05SmbShareCheckDiffButton.Location.X + $script:AutoChart05SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Unencrypted Shares" -PropertyX "PSComputerName" -PropertyY "Name" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart05SmbShareCheckDiffButton.Location.Y + $script:AutoChart05SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareOpenInShell
$script:AutoChart05SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05SmbShareManipulationPanel.controls.Add($script:AutoChart05SmbShareOpenInShell)


$script:AutoChart05SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05SmbShareOpenInShell.Location.X + $script:AutoChart05SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareViewResults
$script:AutoChart05SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05SmbShareManipulationPanel.controls.Add($script:AutoChart05SmbShareViewResults)


### Save the chart to file
$script:AutoChart05SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart05SmbShareOpenInShell.Location.Y + $script:AutoChart05SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart05SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05SmbShare -Title $script:AutoChart05SmbShareTitle
})
$script:AutoChart05SmbShareManipulationPanel.controls.Add($script:AutoChart05SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05SmbShareSaveButton.Location.X
                        Y = $script:AutoChart05SmbShareSaveButton.Location.Y + $script:AutoChart05SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05SmbShareManipulationPanel.Controls.Add($script:AutoChart05SmbShareNoticeTextbox)

$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.Clear()
$script:AutoChart05SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05SmbShare.Series["Unencrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}


























##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06SmbShare = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04SmbShare.Location.X
                  Y = $script:AutoChart04SmbShare.Location.Y + $script:AutoChart04SmbShare.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06SmbShare.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06SmbShareTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06SmbShare.Titles.Add($script:AutoChart06SmbShareTitle)

### Create Charts Area
$script:AutoChart06SmbShareArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06SmbShareArea.Name        = 'Chart Area'
$script:AutoChart06SmbShareArea.AxisX.Title = 'Hosts'
$script:AutoChart06SmbShareArea.AxisX.Interval          = 1
$script:AutoChart06SmbShareArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06SmbShareArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06SmbShareArea.Area3DStyle.Inclination = 75
$script:AutoChart06SmbShare.ChartAreas.Add($script:AutoChart06SmbShareArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06SmbShare.Series.Add("Encrypted Shares")
$script:AutoChart06SmbShare.Series["Encrypted Shares"].Enabled           = $True
$script:AutoChart06SmbShare.Series["Encrypted Shares"].BorderWidth       = 1
$script:AutoChart06SmbShare.Series["Encrypted Shares"].IsVisibleInLegend = $false
$script:AutoChart06SmbShare.Series["Encrypted Shares"].Chartarea         = 'Chart Area'
$script:AutoChart06SmbShare.Series["Encrypted Shares"].Legend            = 'Legend'
$script:AutoChart06SmbShare.Series["Encrypted Shares"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06SmbShare.Series["Encrypted Shares"]['PieLineColor']   = 'Black'
$script:AutoChart06SmbShare.Series["Encrypted Shares"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06SmbShare.Series["Encrypted Shares"].ChartType         = 'Column'
$script:AutoChart06SmbShare.Series["Encrypted Shares"].Color             = 'Brown'

        function Generate-AutoChart06 {
            $script:AutoChart06SmbShareCsvFileHosts     = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).PSComputerName | Sort-Object -Unique
            $script:AutoChart06SmbShareUniqueDataFields = ($script:AutoChartDataSourceCsvSmbSharesSmbShares).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06SmbShareUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart06SmbShareUniqueDataFields.count -gt 0){
                $script:AutoChart06SmbShareTitle.ForeColor = 'Black'
                $script:AutoChart06SmbShareTitle.Text = "Encrypted Shares"

                $AutoChart06CurrentComputer  = ''
                $AutoChart06CheckIfFirstLine = $false
                $AutoChart06ResultsCount     = 0
                $AutoChart06Computer         = @()
                $AutoChart06YResults         = @()
                $script:AutoChart06SmbShareOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object {$_.EncryptData -eq $true}| Sort-Object PSComputerName) ) {
                    if ( $AutoChart06CheckIfFirstLine -eq $false ) { $AutoChart06CurrentComputer  = $Line.PSComputerName ; $AutoChart06CheckIfFirstLine = $true }
                    if ( $AutoChart06CheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart06CurrentComputer ) {
                            if ( $AutoChart06YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart06YResults += $Line.Name ; $AutoChart06ResultsCount += 1 }
                                if ( $AutoChart06Computer -notcontains $Line.PSComputerName ) { $AutoChart06Computer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart06CurrentComputer ) {
                            $AutoChart06CurrentComputer = $Line.PSComputerName
                            $AutoChart06YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart06ResultsCount
                                Computer     = $AutoChart06Computer
                            }
                            $script:AutoChart06SmbShareOverallDataResults += $AutoChart06YDataResults
                            $AutoChart06YResults     = @()
                            $AutoChart06ResultsCount = 0
                            $AutoChart06Computer     = @()
                            if ( $AutoChart06YResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart06YResults += $Line.Name ; $AutoChart06ResultsCount += 1 }
                                if ( $AutoChart06Computer -notcontains $Line.PSComputerName ) { $AutoChart06Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart06YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart06ResultsCount ; Computer = $AutoChart06Computer }
                $script:AutoChart06SmbShareOverallDataResults += $AutoChart06YDataResults
                $script:AutoChart06SmbShareOverallDataResults | ForEach-Object { $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
                $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart06SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06SmbShareOverallDataResults.count))
                $script:AutoChart06SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06SmbShareOverallDataResults.count))
            }
            else {
                $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
                $script:AutoChart06SmbShareTitle.ForeColor = 'Red'
                $script:AutoChart06SmbShareTitle.Text = "Encrypted Shares`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06SmbShareOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06SmbShare.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06SmbShare.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareOptionsButton
$script:AutoChart06SmbShareOptionsButton.Add_Click({
    if ($script:AutoChart06SmbShareOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06SmbShareOptionsButton.Text = 'Options ^'
        $script:AutoChart06SmbShare.Controls.Add($script:AutoChart06SmbShareManipulationPanel)
    }
    elseif ($script:AutoChart06SmbShareOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06SmbShareOptionsButton.Text = 'Options v'
        $script:AutoChart06SmbShare.Controls.Remove($script:AutoChart06SmbShareManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06SmbShareOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06SmbShare)

$script:AutoChart06SmbShareManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06SmbShare.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06SmbShare.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06SmbShareTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06SmbShareTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06SmbShareTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06SmbShareOverallDataResults.count))
    $script:AutoChart06SmbShareTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06SmbShareTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06SmbShareTrimOffFirstTrackBarValue = $script:AutoChart06SmbShareTrimOffFirstTrackBar.Value
        $script:AutoChart06SmbShareTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06SmbShareTrimOffFirstTrackBar.Value)"
        $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
        $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart06SmbShareTrimOffFirstGroupBox.Controls.Add($script:AutoChart06SmbShareTrimOffFirstTrackBar)
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShareTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06SmbShareTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06SmbShareTrimOffFirstGroupBox.Location.X + $script:AutoChart06SmbShareTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart06SmbShareTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06SmbShareTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06SmbShareTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06SmbShareTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06SmbShareOverallDataResults.count))
    $script:AutoChart06SmbShareTrimOffLastTrackBar.Value         = $($script:AutoChart06SmbShareOverallDataResults.count)
    $script:AutoChart06SmbShareTrimOffLastTrackBarValue   = 0
    $script:AutoChart06SmbShareTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06SmbShareTrimOffLastTrackBarValue = $($script:AutoChart06SmbShareOverallDataResults.count) - $script:AutoChart06SmbShareTrimOffLastTrackBar.Value
        $script:AutoChart06SmbShareTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06SmbShareOverallDataResults.count) - $script:AutoChart06SmbShareTrimOffLastTrackBar.Value)"
        $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
        $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart06SmbShareTrimOffLastGroupBox.Controls.Add($script:AutoChart06SmbShareTrimOffLastTrackBar)
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShareTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06SmbShareChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06SmbShareTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06SmbShareTrimOffFirstGroupBox.Location.Y + $script:AutoChart06SmbShareTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06SmbShareChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06SmbShare.Series["Encrypted Shares"].ChartType = $script:AutoChart06SmbShareChartTypeComboBox.SelectedItem
#    $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
#    $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06SmbShareChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06SmbShareChartTypesAvailable) { $script:AutoChart06SmbShareChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShareChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06SmbShare3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06SmbShareChartTypeComboBox.Location.X + $script:AutoChart06SmbShareChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06SmbShareChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShare3DToggleButton
$script:AutoChart06SmbShare3DInclination = 0
$script:AutoChart06SmbShare3DToggleButton.Add_Click({
    $script:AutoChart06SmbShare3DInclination += 10
    if ( $script:AutoChart06SmbShare3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06SmbShareArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06SmbShareArea.Area3DStyle.Inclination = $script:AutoChart06SmbShare3DInclination
        $script:AutoChart06SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart06SmbShare3DInclination)"
#        $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
#        $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart06SmbShare3DInclination -le 90 ) {
        $script:AutoChart06SmbShareArea.Area3DStyle.Inclination = $script:AutoChart06SmbShare3DInclination
        $script:AutoChart06SmbShare3DToggleButton.Text  = "3D On ($script:AutoChart06SmbShare3DInclination)"
#        $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
#        $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart06SmbShare3DToggleButton.Text  = "3D Off"
        $script:AutoChart06SmbShare3DInclination = 0
        $script:AutoChart06SmbShareArea.Area3DStyle.Inclination = $script:AutoChart06SmbShare3DInclination
        $script:AutoChart06SmbShareArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
#        $script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShare3DToggleButton)

### Change the color of the chart
$script:AutoChart06SmbShareChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06SmbShare3DToggleButton.Location.X + $script:AutoChart06SmbShare3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06SmbShare3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06SmbShareColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06SmbShareColorsAvailable) { $script:AutoChart06SmbShareChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06SmbShareChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06SmbShare.Series["Encrypted Shares"].Color = $script:AutoChart06SmbShareChangeColorComboBox.SelectedItem
})
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShareChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {
    # List of Positive Endpoints that positively match
    $script:AutoChart06SmbShareImportCsvPosResults = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Where-Object 'Name' -eq $($script:AutoChart06SmbShareInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06SmbShareInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06SmbShareImportCsvPosResults) { $script:AutoChart06SmbShareInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06SmbShareImportCsvAll = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart06SmbShareImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06SmbShareImportCsvAll) { if ($Endpoint -notin $script:AutoChart06SmbShareImportCsvPosResults) { $script:AutoChart06SmbShareImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06SmbShareInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06SmbShareImportCsvNegResults) { $script:AutoChart06SmbShareInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06SmbShareImportCsvPosResults.count))"
    $script:AutoChart06SmbShareInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06SmbShareImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06SmbShareCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06SmbShareTrimOffLastGroupBox.Location.X + $script:AutoChart06SmbShareTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06SmbShareTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareCheckDiffButton
$script:AutoChart06SmbShareCheckDiffButton.Add_Click({
    $script:AutoChart06SmbShareInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvSmbSharesSmbShares | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06SmbShareInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06SmbShareInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06SmbShareInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06SmbShareInvestDiffDropDownLabel.Location.y + $script:AutoChart06SmbShareInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06SmbShareInvestDiffDropDownArray) { $script:AutoChart06SmbShareInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06SmbShareInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06SmbShareInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06SmbShareInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06SmbShareInvestDiffDropDownComboBox.Location.y + $script:AutoChart06SmbShareInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareInvestDiffExecuteButton
    $script:AutoChart06SmbShareInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06SmbShareInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06SmbShareInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06SmbShareInvestDiffExecuteButton.Location.y + $script:AutoChart06SmbShareInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06SmbShareInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Location.y + $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06SmbShareInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Location.x + $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06SmbShareInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06SmbShareInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06SmbShareInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06SmbShareInvestDiffNegResultsLabel.Location.y + $script:AutoChart06SmbShareInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06SmbShareInvestDiffForm.Controls.AddRange(@($script:AutoChart06SmbShareInvestDiffDropDownLabel,$script:AutoChart06SmbShareInvestDiffDropDownComboBox,$script:AutoChart06SmbShareInvestDiffExecuteButton,$script:AutoChart06SmbShareInvestDiffPosResultsLabel,$script:AutoChart06SmbShareInvestDiffPosResultsTextBox,$script:AutoChart06SmbShareInvestDiffNegResultsLabel,$script:AutoChart06SmbShareInvestDiffNegResultsTextBox))
    $script:AutoChart06SmbShareInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06SmbShareInvestDiffForm.ShowDialog()
})
$script:AutoChart06SmbShareCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06SmbShareManipulationPanel.controls.Add($script:AutoChart06SmbShareCheckDiffButton)


$AutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06SmbShareCheckDiffButton.Location.X + $script:AutoChart06SmbShareCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06SmbShareCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvSmbSharesSmbSharesFileName -QueryName "SMB Shares" -QueryTabName "Encrypted Shares" -PropertyX "PSComputerName" -PropertyY "Name" }
}
Apply-Apply-CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06SmbShareOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06SmbShareCheckDiffButton.Location.X
                   Y = $script:AutoChart06SmbShareCheckDiffButton.Location.Y + $script:AutoChart06SmbShareCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareOpenInShell
$script:AutoChart06SmbShareOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06SmbShareManipulationPanel.controls.Add($script:AutoChart06SmbShareOpenInShell)


$script:AutoChart06SmbShareViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06SmbShareOpenInShell.Location.X + $script:AutoChart06SmbShareOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06SmbShareOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareViewResults
$script:AutoChart06SmbShareViewResults.Add_Click({ $script:AutoChartDataSourceCsvSmbSharesSmbShares | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06SmbShareManipulationPanel.controls.Add($script:AutoChart06SmbShareViewResults)


### Save the chart to file
$script:AutoChart06SmbShareSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06SmbShareOpenInShell.Location.X
                  Y = $script:AutoChart06SmbShareOpenInShell.Location.Y + $script:AutoChart06SmbShareOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-Apply-CommonButtonSettings -Button $script:AutoChart06SmbShareSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06SmbShareSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06SmbShare -Title $script:AutoChart06SmbShareTitle
})
$script:AutoChart06SmbShareManipulationPanel.controls.Add($script:AutoChart06SmbShareSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06SmbShareNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06SmbShareSaveButton.Location.X
                        Y = $script:AutoChart06SmbShareSaveButton.Location.Y + $script:AutoChart06SmbShareSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06SmbShareCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06SmbShareManipulationPanel.Controls.Add($script:AutoChart06SmbShareNoticeTextbox)

$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.Clear()
$script:AutoChart06SmbShareOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06SmbShareTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06SmbShareTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06SmbShare.Series["Encrypted Shares"].Points.AddXY($_.Computer,$_.ResultsCount)}






















# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyOOE2iPP7iXSky8nnk9r7MgR
# JBOgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKttrYE7uGhMA6LCcipPR7k2YZiowDQYJKoZI
# hvcNAQEBBQAEggEAAiJ3gwS8CZUbyNn6TMhuaEiO4G+VZLkpQYKDjuDbCmofEiPH
# 8XXGK8w5yWMbWatxX8gd1cewY+zKDll1EBFwSZGsfPPpTgvCbdoFTOo7ywv5Zd3g
# ObwAqTjGAs8v3nTsiRizp+ZaHSmaRxyAt2mAk+YArhEwi9V2f6FkTg+rd6pXbJ4X
# V0VrwVdn7f5tEAkHas/pjiScUgKpeKL3esqHIvYjehlusw5M0sT6+wTe5Lfg1y/3
# WEDaapIvxNNX2hxTXdF5PA1TJ70T8IbP/JyhSsQKSNGWCjJLLKCEnwUT0StvJ786
# 6f8/QDYAb9Ley/WUelhZMVb0OaV0/bYf/t5bXw==
# SIG # End signature block
