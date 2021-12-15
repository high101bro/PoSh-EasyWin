$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Network Connections  '
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

$script:AutoChart01NetworkConnectionsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Network Connections' -or $CSVFile -match 'NetworkConnections') { $script:AutoChart01NetworkConnectionsCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01NetworkConnectionsCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsvNetworkConnections = $null
$script:AutoChartDataSourceCsvNetworkConnections = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart01NetworkConnections.Controls.Remove($script:AutoChart01NetworkConnectionsManipulationPanel)
    $script:AutoChart02NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart02NetworkConnections.Controls.Remove($script:AutoChart02NetworkConnectionsManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Network Connections'
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

    if ($script:AutoChartDataSourceXmlPath) {
        $SavePath = Split-Path -Path $script:AutoChartDataSourceXmlPath
        $FileName = Split-Path -Path $script:AutoChartDataSourceXmlPath -Leaf
        Open-XmlResultsInShell -ViewImportResults $script:AutoChartDataSourceXmlPath -FileName $FileName -SavePath $SavePath
    }
    elseif (Test-Path $ViewImportResults) {
        $SavePath = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename
        $FileName = Split-Path -Path $script:AutoChartOpenResultsOpenFileDialogfilename -Leaf
        Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
    }
    else { [System.Windows.MessageBox]::Show("Error: Cannot Import Data!`nThe associated .xml file was not located.","PoSh-EasyWin") }
}


















##############################################################################################
# AutoChart01NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01NetworkConnections.Titles.Add($script:AutoChart01NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart01NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart01NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart01NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart01NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart01NetworkConnections.ChartAreas.Add($script:AutoChart01NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01NetworkConnections.Series.Add("IPv4 Ports Listening")
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Enabled           = $True
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].BorderWidth       = 1
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].IsVisibleInLegend = $false
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Chartarea         = 'Chart Area'
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Legend            = 'Legend'
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"]['PieLineColor']   = 'Black'
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].ChartType         = 'Column'
$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Color             = 'Red'

function Generate-AutoChart01NetworkConnections {
            $script:AutoChart01NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart01NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsvNetworkConnections| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart01NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsvNetworkConnections `
            | Where-Object {$_.State -match 'Listen' -and $_.LocalAddress -notmatch ':'} `
            | ForEach-Object {
                if ($_.LocalAddress -eq '0.0.0.0' -or $_.LocalAddress -match "127.[\d]{1,3}.[\d]{1,3}.[\d]{1,3}"){
                    $_ | Select-Object @{n='LocalAddressPort';e={$_.LocalAddress + ':' + $_.LocalPort}}
                }
                else {
                    $_ | Select-Object @{n="LocalAddressPort";e={($_.LocalAddress.split('.')[0..2] -join '.') + '.x:' + $_.LocalPort}}
                }
            }
            $script:AutoChart01NetworkConnectionsUniqueDataFields = $script:AutoChart01NetworkConnectionsUniqueDataFields `
            | Select-Object -Property 'LocalAddressPort' | Sort-Object {[string]$_.LocalAddressPort} -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.Clear()

            if ($script:AutoChart01NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart01NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart01NetworkConnectionsTitle.Text = "IPv4 Ports Listening"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01NetworkConnectionsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01NetworkConnectionsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart01NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvNetworkConnections ) {
                        if (
                            ($Line.LocalAddress.split('.')[0..2] -join '.') -eq (($DataField.LocalAddressPort).split(':')[0].split('.')[0..2] -join '.') -and
                            $Line.LocalPort -eq (($DataField.LocalAddressPort).split(':')[1])
                            ) {
                            $Count += 1
                            if ( $script:AutoChart01NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01NetworkConnectionsCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01NetworkConnectionsCsvComputers.Count
                        Computers   = $script:AutoChart01NetworkConnectionsCsvComputers
                    }
                    $script:AutoChart01NetworkConnectionsOverallDataResults += $script:AutoChart01NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart01NetworkConnectionsSortButton.text = "View: Count"
                $script:AutoChart01NetworkConnectionsOverallDataResultsSortAlphaNum = $script:AutoChart01NetworkConnectionsOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart01NetworkConnectionsOverallDataResultsSortCount    = $script:AutoChart01NetworkConnectionsOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart01NetworkConnectionsOverallDataResults = $script:AutoChart01NetworkConnectionsOverallDataResultsSortAlphaNum

                $script:AutoChart01NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.AddXY($_.DataField.LocalAddressPort,$_.UniqueCount) }
                $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01NetworkConnectionsOverallDataResults.count))
                $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart01NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart01NetworkConnectionsTitle.Text = "IPv4 Ports Listening`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsOptionsButton
$script:AutoChart01NetworkConnectionsOptionsButton.Add_Click({
    if ($script:AutoChart01NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart01NetworkConnections.Controls.Add($script:AutoChart01NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart01NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart01NetworkConnections.Controls.Remove($script:AutoChart01NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01NetworkConnections)


$script:AutoChart01NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01NetworkConnectionsOverallDataResults.count))
    $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.Clear()
        $script:AutoChart01NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.AddXY($_.DataField.LocalAddressPort,$_.UniqueCount)}
    })
    $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart01NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01NetworkConnectionsOverallDataResults.count))
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart01NetworkConnectionsOverallDataResults.count)
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart01NetworkConnectionsOverallDataResults.count) - $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart01NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01NetworkConnectionsOverallDataResults.count) - $script:AutoChart01NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.Clear()
        $script:AutoChart01NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.AddXY($_.DataField.LocalAddressPort,$_.UniqueCount)}
    })
$script:AutoChart01NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart01NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart01NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].ChartType = $script:AutoChart01NetworkConnectionsChartTypeComboBox.SelectedItem
})
$script:AutoChart01NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01NetworkConnectionsChartTypesAvailable) { $script:AutoChart01NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnectionsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart01NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnections3DToggleButton
$script:AutoChart01NetworkConnections3DInclination = 0
$script:AutoChart01NetworkConnections3DToggleButton.Add_Click({

    $script:AutoChart01NetworkConnections3DInclination += 10
    if ( $script:AutoChart01NetworkConnections3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart01NetworkConnections3DInclination
        $script:AutoChart01NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart01NetworkConnections3DInclination)"
    }
    elseif ( $script:AutoChart01NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart01NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart01NetworkConnections3DInclination
        $script:AutoChart01NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart01NetworkConnections3DInclination)"
    }
    else {
        $script:AutoChart01NetworkConnections3DToggleButton.Text  = "3D Off"
        $script:AutoChart01NetworkConnections3DInclination = 0
        $script:AutoChart01NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart01NetworkConnections3DInclination
        $script:AutoChart01NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart01NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01NetworkConnections3DToggleButton.Location.X + $script:AutoChart01NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01NetworkConnectionsColorsAvailable) { $script:AutoChart01NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Color = $script:AutoChart01NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01NetworkConnections {
    # List of Positive Endpoints that positively match
    $script:AutoChart01NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsvNetworkConnections | Where-Object 'LocalAddressPort' -eq $($script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01NetworkConnectionsImportCsvPosResults) { $script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart01NetworkConnectionsImportCsvPosResults) { $script:AutoChart01NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01NetworkConnectionsImportCsvNegResults) { $script:AutoChart01NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart01NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsCheckDiffButton
$script:AutoChart01NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -Property 'LocalAddressPort' -ExpandProperty 'LocalAddressPort' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart01NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01NetworkConnections }})
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01NetworkConnections }})
    $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart01NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart01NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart01NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart01NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart01NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart01NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart01NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsCheckDiffButton)


$AutoChart01NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart01NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvNetworkConnectionsFileName -QueryName "Network Settings" -QueryTabName "IPv4 Ports Listening" -PropertyX "LocalAddressPort" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart01NetworkConnectionsExpandChartButton
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($AutoChart01NetworkConnectionsExpandChartButton)


$script:AutoChart01NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart01NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsOpenInShell
$script:AutoChart01NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsOpenInShell)


$script:AutoChart01NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart01NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart01NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart01NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsSortButton
$script:AutoChart01NetworkConnectionsSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart01NetworkConnectionsOverallDataResults = $script:AutoChart01NetworkConnectionsOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart01NetworkConnectionsOverallDataResults = $script:AutoChart01NetworkConnectionsOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.Clear()
    $script:AutoChart01NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.AddXY($_.DataField.LocalAddressPort,$_.UniqueCount)}
})
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsSortButton)


$script:AutoChart01NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01NetworkConnectionsOpenInShell.Location.X + $script:AutoChart01NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsViewResults
$script:AutoChart01NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsvNetworkConnections | Out-GridView })
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart01NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart01NetworkConnectionsViewResults.Location.Y + $script:AutoChart01NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01NetworkConnections -Title $script:AutoChart01NetworkConnectionsTitle
})
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01NetworkConnectionsSortButton.Location.X
                        Y = $script:AutoChart01NetworkConnectionsSortButton.Location.Y + $script:AutoChart01NetworkConnectionsSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart01NetworkConnectionsNoticeTextbox)

#$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.Clear()
#$script:AutoChart01NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart01NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkConnections.Series["IPv4 Ports Listening"].Points.AddXY($_.DataField.LocalAddressPort,$_.UniqueCount)}























##############################################################################################
# AutoChart02NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01NetworkConnections.Location.X + $script:AutoChart01NetworkConnections.Size.Width + 20
                  Y = $script:AutoChart01NetworkConnections.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02NetworkConnections.Add_MouseHover({ Close-AllOptions })


### Auto Create Charts Title
$script:AutoChart02NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02NetworkConnections.Titles.Add($script:AutoChart02NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart02NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart02NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart02NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart02NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart02NetworkConnections.ChartAreas.Add($script:AutoChart02NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02NetworkConnections.Series.Add("Connections to Private Network Endpoints")
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Enabled           = $True
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].BorderWidth       = 1
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].IsVisibleInLegend = $false
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Chartarea         = 'Chart Area'
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Legend            = 'Legend'
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"]['PieLineColor']   = 'Black'
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].ChartType         = 'Column'
$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Color             = 'Blue'

function Generate-AutoChart02NetworkConnections {
            $script:AutoChart02NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart02NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsvNetworkConnections| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $LocalNetworkArray = @(10,172.16,172.17,172.18,172.19,172.20,172.21,172.22,172.23,172.24,172.25,172.26,172.27,172.28,172.29,172.30,172.31,192.168)

            $script:AutoChart02NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsvNetworkConnections `
            | Where-Object {$_.LocalAddress -notmatch ':' -and `
                (
                    $_.RemoteAddress                             -in $LocalNetworkArray -or
                    $_.RemoteAddress.split('.')[0]               -in $LocalNetworkArray -or
                   ($_.RemoteAddress.split('.')[0..1] -join '.') -in $LocalNetworkArray
                )
            }

            $script:AutoChart02NetworkConnectionsUniqueDataFields = $script:AutoChart02NetworkConnectionsUniqueDataFields `
            | Select-Object 'RemoteAddress'  | Sort-Object -Property 'RemoteAddress' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.Clear()

            if ($script:AutoChart02NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart02NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart02NetworkConnectionsTitle.Text = "Connections to Private Network Endpoints"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart02NetworkConnectionsOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02NetworkConnectionsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart02NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsvNetworkConnections ) {
                        if ($Line.RemoteAddress -eq $DataField.RemoteAddress) {
                            $Count += 1
                            if ( $script:AutoChart02NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart02NetworkConnectionsCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart02NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02NetworkConnectionsCsvComputers.Count
                        Computers   = $script:AutoChart02NetworkConnectionsCsvComputers
                    }
                    $script:AutoChart02NetworkConnectionsOverallDataResults += $script:AutoChart02NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart02NetworkConnectionsSortButton.text = "View: Count"
                $script:AutoChart02NetworkConnectionsOverallDataResultsSortAlphaNum = $script:AutoChart02NetworkConnectionsOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart02NetworkConnectionsOverallDataResultsSortCount    = $script:AutoChart02NetworkConnectionsOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart02NetworkConnectionsOverallDataResults = $script:AutoChart02NetworkConnectionsOverallDataResultsSortAlphaNum

                $script:AutoChart02NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount) }
                $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02NetworkConnectionsOverallDataResults.count))
                $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart02NetworkConnectionsTitle.ForeColor = 'Blue'
                $script:AutoChart02NetworkConnectionsTitle.Text = "Connections to Private Network Endpoints`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsOptionsButton
$script:AutoChart02NetworkConnectionsOptionsButton.Add_Click({
    if ($script:AutoChart02NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart02NetworkConnections.Controls.Add($script:AutoChart02NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart02NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart02NetworkConnections.Controls.Remove($script:AutoChart02NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02NetworkConnections)


$script:AutoChart02NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02NetworkConnectionsOverallDataResults.count))
    $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.Clear()
        $script:AutoChart02NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
    })
    $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart02NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02NetworkConnectionsOverallDataResults.count))
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart02NetworkConnectionsOverallDataResults.count)
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart02NetworkConnectionsOverallDataResults.count) - $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart02NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02NetworkConnectionsOverallDataResults.count) - $script:AutoChart02NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.Clear()
        $script:AutoChart02NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
    })
$script:AutoChart02NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart02NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart02NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].ChartType = $script:AutoChart02NetworkConnectionsChartTypeComboBox.SelectedItem
})
$script:AutoChart02NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02NetworkConnectionsChartTypesAvailable) { $script:AutoChart02NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnectionsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart02NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnections3DToggleButton
$script:AutoChart02NetworkConnections3DInclination = 0
$script:AutoChart02NetworkConnections3DToggleButton.Add_Click({

    $script:AutoChart02NetworkConnections3DInclination += 10
    if ( $script:AutoChart02NetworkConnections3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart02NetworkConnections3DInclination
        $script:AutoChart02NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart02NetworkConnections3DInclination)"
    }
    elseif ( $script:AutoChart02NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart02NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart02NetworkConnections3DInclination
        $script:AutoChart02NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart02NetworkConnections3DInclination)"
    }
    else {
        $script:AutoChart02NetworkConnections3DToggleButton.Text  = "3D Off"
        $script:AutoChart02NetworkConnections3DInclination = 0
        $script:AutoChart02NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart02NetworkConnections3DInclination
        $script:AutoChart02NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart02NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02NetworkConnections3DToggleButton.Location.X + $script:AutoChart02NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02NetworkConnectionsColorsAvailable) { $script:AutoChart02NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Color = $script:AutoChart02NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02NetworkConnections {
    # List of Positive Endpoints that positively match
    $script:AutoChart02NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsvNetworkConnections | Where-Object 'RemoteAddress' -eq $($script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02NetworkConnectionsImportCsvPosResults) { $script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart02NetworkConnectionsImportCsvPosResults) { $script:AutoChart02NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02NetworkConnectionsImportCsvNegResults) { $script:AutoChart02NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart02NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsCheckDiffButton
$script:AutoChart02NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsvNetworkConnections | Select-Object -Property 'RemoteAddress' -ExpandProperty 'RemoteAddress' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart02NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02NetworkConnections }})
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02NetworkConnections }})
    $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart02NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart02NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart02NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart02NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart02NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart02NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart02NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsCheckDiffButton)


$AutoChart02NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart02NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvNetworkConnectionsFileName -QueryName "Network Settings" -QueryTabName "Connections to Private Network Endpoints" -PropertyX "RemoteAddress" -PropertyY "PSComputerName" }
}
Apply-CommonButtonSettings -Button $AutoChart02NetworkConnectionsExpandChartButton
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($AutoChart02NetworkConnectionsExpandChartButton)


$script:AutoChart02NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart02NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsOpenInShell
$script:AutoChart02NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsOpenInShell)


$script:AutoChart02NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart02NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart02NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart02NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsSortButton
$script:AutoChart02NetworkConnectionsSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart02NetworkConnectionsOverallDataResults = $script:AutoChart02NetworkConnectionsOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart02NetworkConnectionsOverallDataResults = $script:AutoChart02NetworkConnectionsOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.Clear()
    $script:AutoChart02NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart02NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkConnections.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
})
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsSortButton)


$script:AutoChart02NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02NetworkConnectionsOpenInShell.Location.X + $script:AutoChart02NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsViewResults
$script:AutoChart02NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsvNetworkConnections | Out-GridView })
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart02NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart02NetworkConnectionsViewResults.Location.Y + $script:AutoChart02NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02NetworkConnections -Title $script:AutoChart02NetworkConnectionsTitle
})
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02NetworkConnectionsSortButton.Location.X
                        Y = $script:AutoChart02NetworkConnectionsSortButton.Location.Y + $script:AutoChart02NetworkConnectionsSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart02NetworkConnectionsNoticeTextbox)







# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUE2ZiPi3+Ue0isSEM5dCS1lQ/
# eYSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUy9ef/mt0q32BDhiEBgsqXVJOL1IwDQYJKoZI
# hvcNAQEBBQAEggEAWPHtno2xVzdVjEnPjjPNoZDcs/zPLKLfzhQ4jgDKXtHWhvhK
# kZ72o4+SY1u0W+hIA3U588EnoL3mkaVvPfGlbV1A4Xcdub4xooEnyvVDA6n8O/v4
# 1V2fCbuKNMq/i0URqu0rqvHxB3pv8q35h/JNaUr6RWvjy9KLUG8GqruDz9TQnQL0
# QAWOUJDM7yTiyJoMFdeklEGhfkn7f8z3Dbq8uIkwbfJbSCT4jJHWhMJSbKZ0rQI3
# NtSIVKtsM6/+6rd5RlCA4XlAvKM0JqcD6gfj176IhJRDDwk9pdKKEfLPuEWyqkP3
# nXHvxIQNKc2j3NdrrJscO6osL7HW6KllF9vYKg==
# SIG # End signature block
