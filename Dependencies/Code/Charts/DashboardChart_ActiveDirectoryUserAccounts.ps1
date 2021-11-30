$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Active Directory User Accounts'
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

$script:AutoChart01ADUserAccountsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'AD Accounts' -or $CSVFile -match 'Active Directory User Accounts') { $script:AutoChart01ADUserAccountsCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ADUserAccountsCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart01ADUserAccounts.Controls.Remove($script:AutoChart01ADUserAccountsManipulationPanel)
    $script:AutoChart02ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart02ADUserAccounts.Controls.Remove($script:AutoChart02ADUserAccountsManipulationPanel)
    $script:AutoChart03ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart03ADUserAccounts.Controls.Remove($script:AutoChart03ADUserAccountsManipulationPanel)
    $script:AutoChart04ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart04ADUserAccounts.Controls.Remove($script:AutoChart04ADUserAccountsManipulationPanel)
    $script:AutoChart05ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart05ADUserAccounts.Controls.Remove($script:AutoChart05ADUserAccountsManipulationPanel)
    $script:AutoChart06ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart06ADUserAccounts.Controls.Remove($script:AutoChart06ADUserAccountsManipulationPanel)
    $script:AutoChart07ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart07ADUserAccounts.Controls.Remove($script:AutoChart07ADUserAccountsManipulationPanel)
    $script:AutoChart08ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart08ADUserAccounts.Controls.Remove($script:AutoChart08ADUserAccountsManipulationPanel)
    $script:AutoChart09ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart09ADUserAccounts.Controls.Remove($script:AutoChart09ADUserAccountsManipulationPanel)
    $script:AutoChart10ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart10ADUserAccounts.Controls.Remove($script:AutoChart10ADUserAccountsManipulationPanel)
    $script:AutoChart11ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart11ADUserAccounts.Controls.Remove($script:AutoChart11ADUserAccountsManipulationPanel)
    $script:AutoChart12ADUserAccountsOptionsButton.Text = 'Options v'
    $script:AutoChart12ADUserAccounts.Controls.Remove($script:AutoChart12ADUserAccountsManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'AD User Accounts'
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
# AutoChart01ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01ADUserAccounts.Titles.Add($script:AutoChart01ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart01ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart01ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart01ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart01ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart01ADUserAccounts.ChartAreas.Add($script:AutoChart01ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01ADUserAccounts.Series.Add("Created")
$script:AutoChart01ADUserAccounts.Series["Created"].Enabled           = $True
$script:AutoChart01ADUserAccounts.Series["Created"].BorderWidth       = 1
$script:AutoChart01ADUserAccounts.Series["Created"].IsVisibleInLegend = $false
$script:AutoChart01ADUserAccounts.Series["Created"].Chartarea         = 'Chart Area'
$script:AutoChart01ADUserAccounts.Series["Created"].Legend            = 'Legend'
$script:AutoChart01ADUserAccounts.Series["Created"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01ADUserAccounts.Series["Created"]['PieLineColor']   = 'Black'
$script:AutoChart01ADUserAccounts.Series["Created"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01ADUserAccounts.Series["Created"].ChartType         = 'Bar'
$script:AutoChart01ADUserAccounts.Series["Created"].Color             = 'Red'

        function Generate-AutoChart01ADUserAccounts {
            $script:AutoChart01ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart01ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Created | Sort-Object Created -unique
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()

            if ($script:AutoChart01ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart01ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart01ADUserAccountsTitle.Text = "Created"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart01ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ADUserAccountsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Created) -eq $DataField.Created) {
                            $Count += 1
                            if ( $script:AutoChart01ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart01ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart01ADUserAccountsUniqueCount = $script:AutoChart01ADUserAccountsCsvComputers.Count
                    $script:AutoChart01ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart01ADUserAccountsCsvComputers
                    }
                    $script:AutoChart01ADUserAccountsOverallDataResults += $script:AutoChart01ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | ForEach-Object { $script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount) }
                $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADUserAccountsOverallDataResults.count))
                $script:AutoChart01ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart01ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart01ADUserAccountsTitle.Text = "Created`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart01ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsOptionsButton
$script:AutoChart01ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart01ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart01ADUserAccounts.Controls.Add($script:AutoChart01ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart01ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart01ADUserAccounts.Controls.Remove($script:AutoChart01ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADUserAccounts)


$script:AutoChart01ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADUserAccountsOverallDataResults.count))
    $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart01ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
        $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    })
    $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADUserAccountsOverallDataResults.count))
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart01ADUserAccountsOverallDataResults.count)
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart01ADUserAccountsOverallDataResults.count) - $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart01ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ADUserAccountsOverallDataResults.count) - $script:AutoChart01ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
        $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    })
$script:AutoChart01ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart01ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADUserAccounts.Series["Created"].ChartType = $script:AutoChart01ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
#    $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
})
$script:AutoChart01ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ADUserAccountsChartTypesAvailable) { $script:AutoChart01ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccountsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart01ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccounts3DToggleButton
$script:AutoChart01ADUserAccounts3DInclination = 0
$script:AutoChart01ADUserAccounts3DToggleButton.Add_Click({

    $script:AutoChart01ADUserAccounts3DInclination += 10
    if ( $script:AutoChart01ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart01ADUserAccounts3DInclination
        $script:AutoChart01ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart01ADUserAccounts3DInclination)"
#        $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
#        $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart01ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart01ADUserAccounts3DInclination
        $script:AutoChart01ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart01ADUserAccounts3DInclination)"
#        $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
#        $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart01ADUserAccounts3DInclination = 0
        $script:AutoChart01ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart01ADUserAccounts3DInclination
        $script:AutoChart01ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
#        $script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
})
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart01ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01ADUserAccounts3DToggleButton.Location.X + $script:AutoChart01ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ADUserAccountsColorsAvailable) { $script:AutoChart01ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADUserAccounts.Series["Created"].Color = $script:AutoChart01ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccountsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart01ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Created' -eq $($script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart01ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADUserAccountsImportCsvPosResults) { $script:AutoChart01ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart01ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ADUserAccountsImportCsvPosResults) { $script:AutoChart01ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADUserAccountsImportCsvNegResults) { $script:AutoChart01ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart01ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsCheckDiffButton
$script:AutoChart01ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart01ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Created' -ExpandProperty 'Created' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart01ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADUserAccounts }})
    $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart01ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart01ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADUserAccounts }})
    $script:AutoChart01ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart01ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart01ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart01ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart01ADUserAccountsInvestDiffExecuteButton,$script:AutoChart01ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart01ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart01ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart01ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart01ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart01ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ADUserAccountsManipulationPanel.controls.Add($script:AutoChart01ADUserAccountsCheckDiffButton)


$AutoChart01ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart01ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Created" -PropertyX "Created" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart01ADUserAccountsExpandChartButton
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($AutoChart01ADUserAccountsExpandChartButton)


$script:AutoChart01ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart01ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart01ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsOpenInShell
$script:AutoChart01ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01ADUserAccountsManipulationPanel.controls.Add($script:AutoChart01ADUserAccountsOpenInShell)


$script:AutoChart01ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ADUserAccountsOpenInShell.Location.X + $script:AutoChart01ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsViewResults
$script:AutoChart01ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01ADUserAccountsManipulationPanel.controls.Add($script:AutoChart01ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart01ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart01ADUserAccountsOpenInShell.Location.Y + $script:AutoChart01ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100 #205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart01ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01ADUserAccounts -Title $script:AutoChart01ADUserAccountsTitle
})
$script:AutoChart01ADUserAccountsManipulationPanel.controls.Add($script:AutoChart01ADUserAccountsSaveButton)


#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart01ADUserAccountsSaveButton.Location.Y + $script:AutoChart01ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart01ADUserAccountsNoticeTextbox)

$script:AutoChart01ADUserAccounts.Series["Created"].Points.Clear()
$script:AutoChart01ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart01ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADUserAccounts.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}























##############################################################################################
# AutoChart02ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADUserAccounts.Location.X + $script:AutoChart01ADUserAccounts.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01ADUserAccounts.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02ADUserAccounts.Titles.Add($script:AutoChart02ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart02ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart02ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart02ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart02ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart02ADUserAccounts.ChartAreas.Add($script:AutoChart02ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02ADUserAccounts.Series.Add("Modified")
$script:AutoChart02ADUserAccounts.Series["Modified"].Enabled           = $True
$script:AutoChart02ADUserAccounts.Series["Modified"].BorderWidth       = 1
$script:AutoChart02ADUserAccounts.Series["Modified"].IsVisibleInLegend = $false
$script:AutoChart02ADUserAccounts.Series["Modified"].Chartarea         = 'Chart Area'
$script:AutoChart02ADUserAccounts.Series["Modified"].Legend            = 'Legend'
$script:AutoChart02ADUserAccounts.Series["Modified"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02ADUserAccounts.Series["Modified"]['PieLineColor']   = 'Black'
$script:AutoChart02ADUserAccounts.Series["Modified"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02ADUserAccounts.Series["Modified"].ChartType         = 'Bar'
$script:AutoChart02ADUserAccounts.Series["Modified"].Color             = 'Blue'

        function Generate-AutoChart02ADUserAccounts {
            $script:AutoChart02ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart02ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Modified | Sort-Object Modified -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()

            if ($script:AutoChart02ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart02ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart02ADUserAccountsTitle.Text = "Modified"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart02ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02ADUserAccountsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart02ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Modified) -eq $DataField.Modified) {
                            $Count += 1
                            if ( $script:AutoChart02ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart02ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart02ADUserAccountsUniqueCount = $script:AutoChart02ADUserAccountsCsvComputers.Count
                    $script:AutoChart02ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart02ADUserAccountsCsvComputers
                    }
                    $script:AutoChart02ADUserAccountsOverallDataResults += $script:AutoChart02ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | ForEach-Object { $script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount) }
                $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADUserAccountsOverallDataResults.count))
                $script:AutoChart02ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart02ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart02ADUserAccountsTitle.Text = "Modified`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart02ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsOptionsButton
$script:AutoChart02ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart02ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart02ADUserAccounts.Controls.Add($script:AutoChart02ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart02ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart02ADUserAccounts.Controls.Remove($script:AutoChart02ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADUserAccounts)


$script:AutoChart02ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADUserAccountsOverallDataResults.count))
    $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart02ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
        $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
    $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADUserAccountsOverallDataResults.count))
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart02ADUserAccountsOverallDataResults.count)
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart02ADUserAccountsOverallDataResults.count) - $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart02ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ADUserAccountsOverallDataResults.count) - $script:AutoChart02ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
        $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
$script:AutoChart02ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart02ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADUserAccounts.Series["Modified"].ChartType = $script:AutoChart02ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
#    $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
})
$script:AutoChart02ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ADUserAccountsChartTypesAvailable) { $script:AutoChart02ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccountsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart02ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccounts3DToggleButton
$script:AutoChart02ADUserAccounts3DInclination = 0
$script:AutoChart02ADUserAccounts3DToggleButton.Add_Click({

    $script:AutoChart02ADUserAccounts3DInclination += 10
    if ( $script:AutoChart02ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart02ADUserAccounts3DInclination
        $script:AutoChart02ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart02ADUserAccounts3DInclination)"
#        $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
#        $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart02ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart02ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart02ADUserAccounts3DInclination
        $script:AutoChart02ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart02ADUserAccounts3DInclination)"
#        $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
#        $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    else {
        $script:AutoChart02ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart02ADUserAccounts3DInclination = 0
        $script:AutoChart02ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart02ADUserAccounts3DInclination
        $script:AutoChart02ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
#        $script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
})
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart02ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02ADUserAccounts3DToggleButton.Location.X + $script:AutoChart02ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ADUserAccountsColorsAvailable) { $script:AutoChart02ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADUserAccounts.Series["Modified"].Color = $script:AutoChart02ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccountsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart02ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Modified' -eq $($script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart02ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADUserAccountsImportCsvPosResults) { $script:AutoChart02ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart02ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ADUserAccountsImportCsvPosResults) { $script:AutoChart02ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADUserAccountsImportCsvNegResults) { $script:AutoChart02ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart02ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsCheckDiffButton
$script:AutoChart02ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart02ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Modified' -ExpandProperty 'Modified' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart02ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADUserAccounts }})
    $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart02ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart02ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADUserAccounts }})
    $script:AutoChart02ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart02ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart02ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart02ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart02ADUserAccountsInvestDiffExecuteButton,$script:AutoChart02ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart02ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart02ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart02ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart02ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart02ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ADUserAccountsManipulationPanel.controls.Add($script:AutoChart02ADUserAccountsCheckDiffButton)


$AutoChart02ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart02ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Modified" -PropertyX "Modified" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart02ADUserAccountsExpandChartButton
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($AutoChart02ADUserAccountsExpandChartButton)


$script:AutoChart02ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart02ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart02ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsOpenInShell
$script:AutoChart02ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02ADUserAccountsManipulationPanel.controls.Add($script:AutoChart02ADUserAccountsOpenInShell)


$script:AutoChart02ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ADUserAccountsOpenInShell.Location.X + $script:AutoChart02ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsViewResults
$script:AutoChart02ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02ADUserAccountsManipulationPanel.controls.Add($script:AutoChart02ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart02ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart02ADUserAccountsOpenInShell.Location.Y + $script:AutoChart02ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart02ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02ADUserAccounts -Title $script:AutoChart02ADUserAccountsTitle
})
$script:AutoChart02ADUserAccountsManipulationPanel.controls.Add($script:AutoChart02ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart02ADUserAccountsSaveButton.Location.Y + $script:AutoChart02ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart02ADUserAccountsNoticeTextbox)

$script:AutoChart02ADUserAccounts.Series["Modified"].Points.Clear()
$script:AutoChart02ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart02ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADUserAccounts.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}




















##############################################################################################
# AutoChart03ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADUserAccounts.Location.X
                  Y = $script:AutoChart01ADUserAccounts.Location.Y + $script:AutoChart01ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03ADUserAccounts.Titles.Add($script:AutoChart03ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart03ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart03ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart03ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart03ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart03ADUserAccounts.ChartAreas.Add($script:AutoChart03ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03ADUserAccounts.Series.Add("Last Logon Date")
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Enabled           = $True
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].BorderWidth       = 1
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].IsVisibleInLegend = $false
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Chartarea         = 'Chart Area'
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Legend            = 'Legend'
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"]['PieLineColor']   = 'Black'
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].ChartType         = 'Bar'
$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Color             = 'Green'

        function Generate-AutoChart03ADUserAccounts {
            $script:AutoChart03ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart03ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object LastLogonDate | Sort-Object LastLogonDate -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()

            if ($script:AutoChart03ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart03ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart03ADUserAccountsTitle.Text = "Last Logon Date"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart03ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ADUserAccountsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.LastLogonDate -eq $DataField.LastLogonDate) {
                            $Count += 1
                            if ( $script:AutoChart03ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart03ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart03ADUserAccountsUniqueCount = $script:AutoChart03ADUserAccountsCsvComputers.Count
                    $script:AutoChart03ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart03ADUserAccountsCsvComputers
                    }
                    $script:AutoChart03ADUserAccountsOverallDataResults += $script:AutoChart03ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | ForEach-Object { $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount) }

                $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADUserAccountsOverallDataResults.count))
                $script:AutoChart03ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart03ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart03ADUserAccountsTitle.Text = "Last Logon Date`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart03ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsOptionsButton
$script:AutoChart03ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart03ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart03ADUserAccounts.Controls.Add($script:AutoChart03ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart03ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart03ADUserAccounts.Controls.Remove($script:AutoChart03ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADUserAccounts)

$script:AutoChart03ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADUserAccountsOverallDataResults.count))
    $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart03ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
        $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    })
    $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADUserAccountsOverallDataResults.count))
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart03ADUserAccountsOverallDataResults.count)
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart03ADUserAccountsOverallDataResults.count) - $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart03ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ADUserAccountsOverallDataResults.count) - $script:AutoChart03ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
        $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    })
$script:AutoChart03ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart03ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].ChartType = $script:AutoChart03ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
#    $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
})
$script:AutoChart03ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ADUserAccountsChartTypesAvailable) { $script:AutoChart03ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart03ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccounts3DToggleButton
$script:AutoChart03ADUserAccounts3DInclination = 0
$script:AutoChart03ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart03ADUserAccounts3DInclination += 10
    if ( $script:AutoChart03ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart03ADUserAccounts3DInclination
        $script:AutoChart03ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart03ADUserAccounts3DInclination)"
#        $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
#        $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart03ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart03ADUserAccounts3DInclination
        $script:AutoChart03ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart03ADUserAccounts3DInclination)"
#        $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
#        $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart03ADUserAccounts3DInclination = 0
        $script:AutoChart03ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart03ADUserAccounts3DInclination
        $script:AutoChart03ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
#        $script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
})
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart03ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03ADUserAccounts3DToggleButton.Location.X + $script:AutoChart03ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ADUserAccountsColorsAvailable) { $script:AutoChart03ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Color = $script:AutoChart03ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart03ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'LastLogonDate' -eq $($script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart03ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADUserAccountsImportCsvPosResults) { $script:AutoChart03ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart03ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ADUserAccountsImportCsvPosResults) { $script:AutoChart03ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADUserAccountsImportCsvNegResults) { $script:AutoChart03ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart03ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsCheckDiffButton
$script:AutoChart03ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart03ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'LastLogonDate' -ExpandProperty 'LastLogonDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart03ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADUserAccounts }})
    $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart03ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart03ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADUserAccounts }})
    $script:AutoChart03ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart03ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart03ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart03ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart03ADUserAccountsInvestDiffExecuteButton,$script:AutoChart03ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart03ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart03ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart03ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart03ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart03ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ADUserAccountsManipulationPanel.controls.Add($script:AutoChart03ADUserAccountsCheckDiffButton)


$AutoChart03ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart03ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Last Logon Date" -PropertyX "LastLogonDate" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart03ADUserAccountsExpandChartButton
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($AutoChart03ADUserAccountsExpandChartButton)


$script:AutoChart03ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart03ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart03ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsOpenInShell
$script:AutoChart03ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03ADUserAccountsManipulationPanel.controls.Add($script:AutoChart03ADUserAccountsOpenInShell)


$script:AutoChart03ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ADUserAccountsOpenInShell.Location.X + $script:AutoChart03ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsViewResults
$script:AutoChart03ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03ADUserAccountsManipulationPanel.controls.Add($script:AutoChart03ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart03ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart03ADUserAccountsOpenInShell.Location.Y + $script:AutoChart03ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart03ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03ADUserAccounts -Title $script:AutoChart03ADUserAccountsTitle
})
$script:AutoChart03ADUserAccountsManipulationPanel.controls.Add($script:AutoChart03ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart03ADUserAccountsSaveButton.Location.Y + $script:AutoChart03ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart03ADUserAccountsNoticeTextbox)

$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.Clear()
$script:AutoChart03ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart03ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADUserAccounts.Series["Last Logon Date"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}





















##############################################################################################
# AutoChart04ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02ADUserAccounts.Location.X
                  Y = $script:AutoChart02ADUserAccounts.Location.Y + $script:AutoChart02ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04ADUserAccounts.Titles.Add($script:AutoChart04ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart04ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart04ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart04ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart04ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart04ADUserAccounts.ChartAreas.Add($script:AutoChart04ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04ADUserAccounts.Series.Add("Last Bad Password Attempt")
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Enabled           = $True
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].BorderWidth       = 1
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].IsVisibleInLegend = $false
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Chartarea         = 'Chart Area'
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Legend            = 'Legend'
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"]['PieLineColor']   = 'Black'
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].ChartType         = 'Bar'
$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Color             = 'Orange'

        function Generate-AutoChart04ADUserAccounts {
            $script:AutoChart04ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart04ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object LastBadPasswordAttempt | Sort-Object LastBadPasswordAttempt -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()

            if ($script:AutoChart04ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart04ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart04ADUserAccountsTitle.Text = "Last Bad Password Attempt"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart04ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ADUserAccountsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.LastBadPasswordAttempt) -eq $DataField.LastBadPasswordAttempt) {
                            $Count += 1
                            if ( $script:AutoChart04ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart04ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart04ADUserAccountsUniqueCount = $script:AutoChart04ADUserAccountsCsvComputers.Count
                    $script:AutoChart04ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart04ADUserAccountsCsvComputers
                    }
                    $script:AutoChart04ADUserAccountsOverallDataResults += $script:AutoChart04ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | ForEach-Object { $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount) }

                $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADUserAccountsOverallDataResults.count))
                $script:AutoChart04ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart04ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart04ADUserAccountsTitle.Text = "Last Bad Password Attempt`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart04ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsOptionsButton
$script:AutoChart04ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart04ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart04ADUserAccounts.Controls.Add($script:AutoChart04ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart04ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart04ADUserAccounts.Controls.Remove($script:AutoChart04ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADUserAccounts)

$script:AutoChart04ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADUserAccountsOverallDataResults.count))
    $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart04ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
        $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
    })
    $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADUserAccountsOverallDataResults.count))
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart04ADUserAccountsOverallDataResults.count)
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart04ADUserAccountsOverallDataResults.count) - $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart04ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ADUserAccountsOverallDataResults.count) - $script:AutoChart04ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
        $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
    })
$script:AutoChart04ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart04ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].ChartType = $script:AutoChart04ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
#    $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
})
$script:AutoChart04ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ADUserAccountsChartTypesAvailable) { $script:AutoChart04ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart04ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccounts3DToggleButton
$script:AutoChart04ADUserAccounts3DInclination = 0
$script:AutoChart04ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart04ADUserAccounts3DInclination += 10
    if ( $script:AutoChart04ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart04ADUserAccounts3DInclination
        $script:AutoChart04ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart04ADUserAccounts3DInclination)"
#        $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart04ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart04ADUserAccounts3DInclination
        $script:AutoChart04ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart04ADUserAccounts3DInclination)"
#        $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart04ADUserAccounts3DInclination = 0
        $script:AutoChart04ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart04ADUserAccounts3DInclination
        $script:AutoChart04ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
#        $script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}
    }
})
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart04ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04ADUserAccounts3DToggleButton.Location.X + $script:AutoChart04ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ADUserAccountsColorsAvailable) { $script:AutoChart04ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Color = $script:AutoChart04ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart04ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'LastBadPasswordAttempt' -eq $($script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart04ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADUserAccountsImportCsvPosResults) { $script:AutoChart04ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart04ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ADUserAccountsImportCsvPosResults) { $script:AutoChart04ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADUserAccountsImportCsvNegResults) { $script:AutoChart04ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart04ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsCheckDiffButton
$script:AutoChart04ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart04ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'LastBadPasswordAttempt' -ExpandProperty 'LastBadPasswordAttempt' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart04ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADUserAccounts }})
    $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart04ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart04ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADUserAccounts }})
    $script:AutoChart04ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart04ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart04ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart04ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart04ADUserAccountsInvestDiffExecuteButton,$script:AutoChart04ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart04ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart04ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart04ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart04ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart04ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ADUserAccountsManipulationPanel.controls.Add($script:AutoChart04ADUserAccountsCheckDiffButton)


$AutoChart04ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart04ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Last Bad Password Attempt" -PropertyX "LastBadPasswordAttempt" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart04ADUserAccountsExpandChartButton
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($AutoChart04ADUserAccountsExpandChartButton)


$script:AutoChart04ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart04ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart04ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsOpenInShell
$script:AutoChart04ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04ADUserAccountsManipulationPanel.controls.Add($script:AutoChart04ADUserAccountsOpenInShell)


$script:AutoChart04ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ADUserAccountsOpenInShell.Location.X + $script:AutoChart04ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsViewResults
$script:AutoChart04ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04ADUserAccountsManipulationPanel.controls.Add($script:AutoChart04ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart04ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart04ADUserAccountsOpenInShell.Location.Y + $script:AutoChart04ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart04ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04ADUserAccounts -Title $script:AutoChart04ADUserAccountsTitle
})
$script:AutoChart04ADUserAccountsManipulationPanel.controls.Add($script:AutoChart04ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart04ADUserAccountsSaveButton.Location.Y + $script:AutoChart04ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart04ADUserAccountsNoticeTextbox)

$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.Clear()
$script:AutoChart04ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.LastBadPasswordAttempt -as [datetime] } | Select-Object -skip $script:AutoChart04ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADUserAccounts.Series["Last Bad Password Attempt"].Points.AddXY($_.DataField.LastBadPasswordAttempt,$_.UniqueCount)}



















##############################################################################################
# AutoChart05ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03ADUserAccounts.Location.X
                  Y = $script:AutoChart03ADUserAccounts.Location.Y + $script:AutoChart03ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05ADUserAccounts.Titles.Add($script:AutoChart05ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart05ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart05ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart05ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart05ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart05ADUserAccounts.ChartAreas.Add($script:AutoChart05ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05ADUserAccounts.Series.Add("Password Last Set")
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Enabled           = $True
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].BorderWidth       = 1
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].IsVisibleInLegend = $false
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Chartarea         = 'Chart Area'
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Legend            = 'Legend'
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05ADUserAccounts.Series["Password Last Set"]['PieLineColor']   = 'Black'
$script:AutoChart05ADUserAccounts.Series["Password Last Set"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].ChartType         = 'Bar'
$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Color             = 'Brown'

        function Generate-AutoChart05ADUserAccounts {
            $script:AutoChart05ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart05ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object PasswordLastSet | Sort-Object PasswordLastSet -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()

            if ($script:AutoChart05ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart05ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart05ADUserAccountsTitle.Text = "Password Last Set"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart05ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05ADUserAccountsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.PasswordLastSet) -eq $DataField.PasswordLastSet) {
                            $Count += 1
                            if ( $script:AutoChart05ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart05ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart05ADUserAccountsUniqueCount = $script:AutoChart05ADUserAccountsCsvComputers.Count
                    $script:AutoChart05ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart05ADUserAccountsCsvComputers
                    }
                    $script:AutoChart05ADUserAccountsOverallDataResults += $script:AutoChart05ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | ForEach-Object { $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount) }
                $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADUserAccountsOverallDataResults.count))
                $script:AutoChart05ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart05ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart05ADUserAccountsTitle.Text = "Password Last Set`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart05ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsOptionsButton
$script:AutoChart05ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart05ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart05ADUserAccounts.Controls.Add($script:AutoChart05ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart05ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart05ADUserAccounts.Controls.Remove($script:AutoChart05ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADUserAccounts)


$script:AutoChart05ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADUserAccountsOverallDataResults.count))
    $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart05ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
        $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    })
    $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADUserAccountsOverallDataResults.count))
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart05ADUserAccountsOverallDataResults.count)
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart05ADUserAccountsOverallDataResults.count) - $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart05ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ADUserAccountsOverallDataResults.count) - $script:AutoChart05ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
        $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    })
$script:AutoChart05ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart05ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADUserAccounts.Series["Password Last Set"].ChartType = $script:AutoChart05ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
#    $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
})
$script:AutoChart05ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ADUserAccountsChartTypesAvailable) { $script:AutoChart05ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccountsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart05ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccounts3DToggleButton
$script:AutoChart05ADUserAccounts3DInclination = 0
$script:AutoChart05ADUserAccounts3DToggleButton.Add_Click({

    $script:AutoChart05ADUserAccounts3DInclination += 10
    if ( $script:AutoChart05ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart05ADUserAccounts3DInclination
        $script:AutoChart05ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart05ADUserAccounts3DInclination)"
#        $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
#        $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart05ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart05ADUserAccounts3DInclination
        $script:AutoChart05ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart05ADUserAccounts3DInclination)"
#        $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
#        $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
    else {
        $script:AutoChart05ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart05ADUserAccounts3DInclination = 0
        $script:AutoChart05ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart05ADUserAccounts3DInclination
        $script:AutoChart05ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
#        $script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
})
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart05ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05ADUserAccounts3DToggleButton.Location.X + $script:AutoChart05ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ADUserAccountsColorsAvailable) { $script:AutoChart05ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADUserAccounts.Series["Password Last Set"].Color = $script:AutoChart05ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccountsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart05ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'PasswordLastSet' -eq $($script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart05ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADUserAccountsImportCsvPosResults) { $script:AutoChart05ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart05ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ADUserAccountsImportCsvPosResults) { $script:AutoChart05ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADUserAccountsImportCsvNegResults) { $script:AutoChart05ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart05ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsCheckDiffButton
$script:AutoChart05ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart05ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'PasswordLastSet' -ExpandProperty 'PasswordLastSet' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart05ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADUserAccounts }})
    $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart05ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart05ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADUserAccounts }})
    $script:AutoChart05ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart05ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart05ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart05ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart05ADUserAccountsInvestDiffExecuteButton,$script:AutoChart05ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart05ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart05ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart05ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart05ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart05ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ADUserAccountsManipulationPanel.controls.Add($script:AutoChart05ADUserAccountsCheckDiffButton)


$AutoChart05ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart05ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Password Last Set" -PropertyX "PasswordLastSet" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart05ADUserAccountsExpandChartButton
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($AutoChart05ADUserAccountsExpandChartButton)


$script:AutoChart05ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart05ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart05ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsOpenInShell
$script:AutoChart05ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05ADUserAccountsManipulationPanel.controls.Add($script:AutoChart05ADUserAccountsOpenInShell)


$script:AutoChart05ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ADUserAccountsOpenInShell.Location.X + $script:AutoChart05ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsViewResults
$script:AutoChart05ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05ADUserAccountsManipulationPanel.controls.Add($script:AutoChart05ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart05ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart05ADUserAccountsOpenInShell.Location.Y + $script:AutoChart05ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart05ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05ADUserAccounts -Title $script:AutoChart05ADUserAccountsTitle
})
$script:AutoChart05ADUserAccountsManipulationPanel.controls.Add($script:AutoChart05ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart05ADUserAccountsSaveButton.Location.Y + $script:AutoChart05ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart05ADUserAccountsNoticeTextbox)

$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.Clear()
$script:AutoChart05ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart05ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADUserAccounts.Series["Password Last Set"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}






















##############################################################################################
# AutoChart06ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04ADUserAccounts.Location.X
                  Y = $script:AutoChart04ADUserAccounts.Location.Y + $script:AutoChart04ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06ADUserAccounts.Titles.Add($script:AutoChart06ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart06ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart06ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart06ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart06ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart06ADUserAccounts.ChartAreas.Add($script:AutoChart06ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06ADUserAccounts.Series.Add("AccountExpirationDate")
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Enabled           = $True
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].BorderWidth       = 1
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].IsVisibleInLegend = $false
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Chartarea         = 'Chart Area'
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Legend            = 'Legend'
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"]['PieLineColor']   = 'Black'
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].ChartType         = 'Bar'
$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Color             = 'Gray'

        function Generate-AutoChart06ADUserAccounts {
            $script:AutoChart06ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart06ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object AccountExpirationDate | Sort-Object AccountExpirationDate -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()

            if ($script:AutoChart06ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart06ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart06ADUserAccountsTitle.Text = "Account Expiration Date"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart06ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AccountExpirationDate) -eq $DataField.AccountExpirationDate) {
                            $Count += 1
                            if ( $script:AutoChart06ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart06ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart06ADUserAccountsUniqueCount = $script:AutoChart06ADUserAccountsCsvComputers.Count
                    $script:AutoChart06ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart06ADUserAccountsCsvComputers
                    }
                    $script:AutoChart06ADUserAccountsOverallDataResults += $script:AutoChart06ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | ForEach-Object { $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount) }

                $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADUserAccountsOverallDataResults.count))
                $script:AutoChart06ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart06ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart06ADUserAccountsTitle.Text = "AccountExpirationDate`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart06ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsOptionsButton
$script:AutoChart06ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart06ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart06ADUserAccounts.Controls.Add($script:AutoChart06ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart06ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart06ADUserAccounts.Controls.Remove($script:AutoChart06ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADUserAccounts)

$script:AutoChart06ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADUserAccountsOverallDataResults.count))
    $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart06ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
        $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
    })
    $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADUserAccountsOverallDataResults.count))
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart06ADUserAccountsOverallDataResults.count)
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart06ADUserAccountsOverallDataResults.count) - $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart06ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ADUserAccountsOverallDataResults.count) - $script:AutoChart06ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
        $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
    })
$script:AutoChart06ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart06ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].ChartType = $script:AutoChart06ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
#    $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
})
$script:AutoChart06ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ADUserAccountsChartTypesAvailable) { $script:AutoChart06ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart06ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccounts3DToggleButton
$script:AutoChart06ADUserAccounts3DInclination = 0
$script:AutoChart06ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart06ADUserAccounts3DInclination += 10
    if ( $script:AutoChart06ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart06ADUserAccounts3DInclination
        $script:AutoChart06ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart06ADUserAccounts3DInclination)"
#        $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
#        $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart06ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart06ADUserAccounts3DInclination
        $script:AutoChart06ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart06ADUserAccounts3DInclination)"
#        $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
#        $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart06ADUserAccounts3DInclination = 0
        $script:AutoChart06ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart06ADUserAccounts3DInclination
        $script:AutoChart06ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
#        $script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}
    }
})
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart06ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06ADUserAccounts3DToggleButton.Location.X + $script:AutoChart06ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ADUserAccountsColorsAvailable) { $script:AutoChart06ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Color = $script:AutoChart06ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart06ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AccountExpirationDate' -eq $($script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart06ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADUserAccountsImportCsvPosResults) { $script:AutoChart06ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart06ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ADUserAccountsImportCsvPosResults) { $script:AutoChart06ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADUserAccountsImportCsvNegResults) { $script:AutoChart06ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart06ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsCheckDiffButton
$script:AutoChart06ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart06ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AccountExpirationDate' -ExpandProperty 'AccountExpirationDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart06ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADUserAccounts }})
    $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart06ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart06ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADUserAccounts }})
    $script:AutoChart06ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart06ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart06ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart06ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart06ADUserAccountsInvestDiffExecuteButton,$script:AutoChart06ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart06ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart06ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart06ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart06ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart06ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ADUserAccountsManipulationPanel.controls.Add($script:AutoChart06ADUserAccountsCheckDiffButton)


$AutoChart06ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart06ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "AccountExpirationDatees" -PropertyX "AccountExpirationDate" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart06ADUserAccountsExpandChartButton
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($AutoChart06ADUserAccountsExpandChartButton)


$script:AutoChart06ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart06ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart06ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsOpenInShell
$script:AutoChart06ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06ADUserAccountsManipulationPanel.controls.Add($script:AutoChart06ADUserAccountsOpenInShell)


$script:AutoChart06ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ADUserAccountsOpenInShell.Location.X + $script:AutoChart06ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsViewResults
$script:AutoChart06ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06ADUserAccountsManipulationPanel.controls.Add($script:AutoChart06ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart06ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart06ADUserAccountsOpenInShell.Location.Y + $script:AutoChart06ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart06ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06ADUserAccounts -Title $script:AutoChart06ADUserAccountsTitle
})
$script:AutoChart06ADUserAccountsManipulationPanel.controls.Add($script:AutoChart06ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart06ADUserAccountsSaveButton.Location.Y + $script:AutoChart06ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart06ADUserAccountsNoticeTextbox)

$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.Clear()
$script:AutoChart06ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.AccountExpirationDate -as [datetime] } | Select-Object -skip $script:AutoChart06ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADUserAccounts.Series["AccountExpirationDate"].Points.AddXY($_.DataField.AccountExpirationDate,$_.UniqueCount)}





















##############################################################################################
# AutoChart07ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05ADUserAccounts.Location.X
                  Y = $script:AutoChart05ADUserAccounts.Location.Y + $script:AutoChart05ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart07ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07ADUserAccounts.Titles.Add($script:AutoChart07ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart07ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart07ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart07ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart07ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart07ADUserAccounts.ChartAreas.Add($script:AutoChart07ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07ADUserAccounts.Series.Add("BadLogonCount")
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Enabled           = $True
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].BorderWidth       = 1
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].IsVisibleInLegend = $false
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Chartarea         = 'Chart Area'
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Legend            = 'Legend'
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"]['PieLineColor']   = 'Black'
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].ChartType         = 'Column'
$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Color             = 'SlateBLue'



function Generate-AutoChart07ADUserAccounts {
            $script:AutoChart07ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart07ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object BadLogonCount | Sort-Object BadLogonCount -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()

            if ($script:AutoChart07ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart07ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart07ADUserAccountsTitle.Text = "Bad Logon Count"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart07ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.BadLogonCount) -eq $DataField.BadLogonCount) {
                            $Count += 1
                            if ( $script:AutoChart07ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart07ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart07ADUserAccountsUniqueCount = $script:AutoChart07ADUserAccountsCsvComputers.Count
                    $script:AutoChart07ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart07ADUserAccountsCsvComputers
                    }
                    $script:AutoChart07ADUserAccountsOverallDataResults += $script:AutoChart07ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | ForEach-Object { $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount) }

                $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ADUserAccountsOverallDataResults.count))
                $script:AutoChart07ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart07ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart07ADUserAccountsTitle.Text = "BadLogonCount`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart07ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart07ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsOptionsButton
$script:AutoChart07ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart07ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart07ADUserAccounts.Controls.Add($script:AutoChart07ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart07ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart07ADUserAccounts.Controls.Remove($script:AutoChart07ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ADUserAccounts)

$script:AutoChart07ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ADUserAccountsOverallDataResults.count))
    $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart07ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
        $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
    })
    $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart07ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ADUserAccountsOverallDataResults.count))
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart07ADUserAccountsOverallDataResults.count)
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart07ADUserAccountsOverallDataResults.count) - $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart07ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07ADUserAccountsOverallDataResults.count) - $script:AutoChart07ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
        $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
    })
$script:AutoChart07ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart07ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart07ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].ChartType = $script:AutoChart07ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
#    $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
})
$script:AutoChart07ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ADUserAccountsChartTypesAvailable) { $script:AutoChart07ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart07ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccounts3DToggleButton
$script:AutoChart07ADUserAccounts3DInclination = 0
$script:AutoChart07ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart07ADUserAccounts3DInclination += 10
    if ( $script:AutoChart07ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart07ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart07ADUserAccounts3DInclination
        $script:AutoChart07ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart07ADUserAccounts3DInclination)"
#        $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
#        $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart07ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart07ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart07ADUserAccounts3DInclination
        $script:AutoChart07ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart07ADUserAccounts3DInclination)"
#        $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
#        $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
    }
    else {
        $script:AutoChart07ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart07ADUserAccounts3DInclination = 0
        $script:AutoChart07ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart07ADUserAccounts3DInclination
        $script:AutoChart07ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
#        $script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}
    }
})
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart07ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07ADUserAccounts3DToggleButton.Location.X + $script:AutoChart07ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ADUserAccountsColorsAvailable) { $script:AutoChart07ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Color = $script:AutoChart07ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart07ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'BadLogonCount' -eq $($script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart07ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ADUserAccountsImportCsvPosResults) { $script:AutoChart07ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart07ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart07ADUserAccountsImportCsvPosResults) { $script:AutoChart07ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ADUserAccountsImportCsvNegResults) { $script:AutoChart07ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart07ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsCheckDiffButton
$script:AutoChart07ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart07ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'BadLogonCount' -ExpandProperty 'BadLogonCount' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart07ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ADUserAccounts }})
    $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart07ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart07ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ADUserAccounts }})
    $script:AutoChart07ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart07ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart07ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart07ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart07ADUserAccountsInvestDiffExecuteButton,$script:AutoChart07ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart07ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart07ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart07ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart07ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart07ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07ADUserAccountsManipulationPanel.controls.Add($script:AutoChart07ADUserAccountsCheckDiffButton)


$AutoChart07ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart07ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process BadLogonCount" -PropertyX "BadLogonCount" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart07ADUserAccountsExpandChartButton
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($AutoChart07ADUserAccountsExpandChartButton)


$script:AutoChart07ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart07ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart07ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsOpenInShell
$script:AutoChart07ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart07ADUserAccountsManipulationPanel.controls.Add($script:AutoChart07ADUserAccountsOpenInShell)


$script:AutoChart07ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07ADUserAccountsOpenInShell.Location.X + $script:AutoChart07ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsViewResults
$script:AutoChart07ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart07ADUserAccountsManipulationPanel.controls.Add($script:AutoChart07ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart07ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart07ADUserAccountsOpenInShell.Location.Y + $script:AutoChart07ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart07ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07ADUserAccounts -Title $script:AutoChart07ADUserAccountsTitle
})
$script:AutoChart07ADUserAccountsManipulationPanel.controls.Add($script:AutoChart07ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart07ADUserAccountsSaveButton.Location.Y + $script:AutoChart07ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart07ADUserAccountsNoticeTextbox)

$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.Clear()
$script:AutoChart07ADUserAccountsOverallDataResults | Sort-Object { $_.DataField.BadLogonCount -as [datetime] } | Select-Object -skip $script:AutoChart07ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADUserAccounts.Series["BadLogonCount"].Points.AddXY($_.DataField.BadLogonCount,$_.UniqueCount)}


















##############################################################################################
# AutoChart08ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06ADUserAccounts.Location.X
                  Y = $script:AutoChart06ADUserAccounts.Location.Y + $script:AutoChart06ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart08ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart08ADUserAccounts.Titles.Add($script:AutoChart08ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart08ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart08ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart08ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart08ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart08ADUserAccounts.ChartAreas.Add($script:AutoChart08ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08ADUserAccounts.Series.Add("Enabled Accounts")
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Enabled           = $True
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].BorderWidth       = 1
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].IsVisibleInLegend = $false
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Chartarea         = 'Chart Area'
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Legend            = 'Legend'
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"]['PieLineColor']   = 'Black'
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].ChartType         = 'Column'
$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Color             = 'Purple'

        function Generate-AutoChart08ADUserAccounts {
            $script:AutoChart08ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart08ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Enabled | Sort-Object Enabled -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()

            if ($script:AutoChart08ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart08ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart08ADUserAccountsTitle.Text = "Enabled Accounts"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart08ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart08ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Enabled) -eq $DataField.Enabled) {
                            $Count += 1
                            if ( $script:AutoChart08ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart08ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart08ADUserAccountsUniqueCount = $script:AutoChart08ADUserAccountsCsvComputers.Count
                    $script:AutoChart08ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart08ADUserAccountsCsvComputers
                    }
                    $script:AutoChart08ADUserAccountsOverallDataResults += $script:AutoChart08ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount) }

                $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ADUserAccountsOverallDataResults.count))
                $script:AutoChart08ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart08ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart08ADUserAccountsTitle.Text = "Enabled Accounts`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart08ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart08ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsOptionsButton
$script:AutoChart08ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart08ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart08ADUserAccounts.Controls.Add($script:AutoChart08ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart08ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart08ADUserAccounts.Controls.Remove($script:AutoChart08ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ADUserAccounts)

$script:AutoChart08ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ADUserAccountsOverallDataResults.count))
    $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart08ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
        $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    })
    $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart08ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ADUserAccountsOverallDataResults.count))
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart08ADUserAccountsOverallDataResults.count)
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart08ADUserAccountsOverallDataResults.count) - $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart08ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08ADUserAccountsOverallDataResults.count) - $script:AutoChart08ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
        $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    })
$script:AutoChart08ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart08ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart08ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].ChartType = $script:AutoChart08ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
#    $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
})
$script:AutoChart08ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ADUserAccountsChartTypesAvailable) { $script:AutoChart08ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart08ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccounts3DToggleButton
$script:AutoChart08ADUserAccounts3DInclination = 0
$script:AutoChart08ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart08ADUserAccounts3DInclination += 10
    if ( $script:AutoChart08ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart08ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart08ADUserAccounts3DInclination
        $script:AutoChart08ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart08ADUserAccounts3DInclination)"
#        $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart08ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart08ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart08ADUserAccounts3DInclination
        $script:AutoChart08ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart08ADUserAccounts3DInclination)"
#        $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    else {
        $script:AutoChart08ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart08ADUserAccounts3DInclination = 0
        $script:AutoChart08ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart08ADUserAccounts3DInclination
        $script:AutoChart08ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
#        $script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
})
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart08ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08ADUserAccounts3DToggleButton.Location.X + $script:AutoChart08ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ADUserAccountsColorsAvailable) { $script:AutoChart08ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Color = $script:AutoChart08ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart08ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Enabled' -eq $($script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart08ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ADUserAccountsImportCsvPosResults) { $script:AutoChart08ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart08ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart08ADUserAccountsImportCsvPosResults) { $script:AutoChart08ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ADUserAccountsImportCsvNegResults) { $script:AutoChart08ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart08ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsCheckDiffButton
$script:AutoChart08ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart08ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Enabled' -ExpandProperty 'Enabled' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart08ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ADUserAccounts }})
    $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart08ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart08ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ADUserAccounts }})
    $script:AutoChart08ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart08ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart08ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart08ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart08ADUserAccountsInvestDiffExecuteButton,$script:AutoChart08ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart08ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart08ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart08ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart08ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart08ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08ADUserAccountsManipulationPanel.controls.Add($script:AutoChart08ADUserAccountsCheckDiffButton)


$AutoChart08ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart08ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Enabled Accountses" -PropertyX "Enabled" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart08ADUserAccountsExpandChartButton
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($AutoChart08ADUserAccountsExpandChartButton)


$script:AutoChart08ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart08ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart08ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsOpenInShell
$script:AutoChart08ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart08ADUserAccountsManipulationPanel.controls.Add($script:AutoChart08ADUserAccountsOpenInShell)


$script:AutoChart08ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08ADUserAccountsOpenInShell.Location.X + $script:AutoChart08ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsViewResults
$script:AutoChart08ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart08ADUserAccountsManipulationPanel.controls.Add($script:AutoChart08ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart08ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart08ADUserAccountsOpenInShell.Location.Y + $script:AutoChart08ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart08ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08ADUserAccounts -Title $script:AutoChart08ADUserAccountsTitle
})
$script:AutoChart08ADUserAccountsManipulationPanel.controls.Add($script:AutoChart08ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart08ADUserAccountsSaveButton.Location.Y + $script:AutoChart08ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart08ADUserAccountsNoticeTextbox)

$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.Clear()
$script:AutoChart08ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADUserAccounts.Series["Enabled Accounts"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}


















##############################################################################################
# AutoChart09ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07ADUserAccounts.Location.X
                  Y = $script:AutoChart07ADUserAccounts.Location.Y + $script:AutoChart07ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart09ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09ADUserAccounts.Titles.Add($script:AutoChart09ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart09ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart09ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart09ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart09ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart09ADUserAccounts.ChartAreas.Add($script:AutoChart09ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09ADUserAccounts.Series.Add("Locked Accounts")
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].LockedOut           = $True
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].BorderWidth       = 1
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].IsVisibleInLegend = $false
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Chartarea         = 'Chart Area'
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Legend            = 'Legend'
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"]['PieLineColor']   = 'Black'
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].ChartType         = 'Column'
$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Color             = 'Yellow'

        function Generate-AutoChart09ADUserAccounts {
            $script:AutoChart09ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart09ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object LockedOut | Sort-Object LockedOut -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()

            if ($script:AutoChart09ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart09ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart09ADUserAccountsTitle.Text = "Locked Accounts"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart09ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart09ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.LockedOut) -eq $DataField.LockedOut) {
                            $Count += 1
                            if ( $script:AutoChart09ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart09ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart09ADUserAccountsUniqueCount = $script:AutoChart09ADUserAccountsCsvComputers.Count
                    $script:AutoChart09ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart09ADUserAccountsCsvComputers
                    }
                    $script:AutoChart09ADUserAccountsOverallDataResults += $script:AutoChart09ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount) }

                $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ADUserAccountsOverallDataResults.count))
                $script:AutoChart09ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart09ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart09ADUserAccountsTitle.Text = "Locked Accounts`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart09ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart09ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsOptionsButton
$script:AutoChart09ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart09ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart09ADUserAccounts.Controls.Add($script:AutoChart09ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart09ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart09ADUserAccounts.Controls.Remove($script:AutoChart09ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ADUserAccounts)

$script:AutoChart09ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ADUserAccountsOverallDataResults.count))
    $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart09ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
        $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    })
    $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart09ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ADUserAccountsOverallDataResults.count))
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart09ADUserAccountsOverallDataResults.count)
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart09ADUserAccountsOverallDataResults.count) - $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart09ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09ADUserAccountsOverallDataResults.count) - $script:AutoChart09ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
        $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    })
$script:AutoChart09ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart09ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart09ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].ChartType = $script:AutoChart09ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
#    $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
})
$script:AutoChart09ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ADUserAccountsChartTypesAvailable) { $script:AutoChart09ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart09ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccounts3DToggleButton
$script:AutoChart09ADUserAccounts3DInclination = 0
$script:AutoChart09ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart09ADUserAccounts3DInclination += 10
    if ( $script:AutoChart09ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart09ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart09ADUserAccounts3DInclination
        $script:AutoChart09ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart09ADUserAccounts3DInclination)"
#        $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart09ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart09ADUserAccounts3DInclination
        $script:AutoChart09ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart09ADUserAccounts3DInclination)"
#        $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
    else {
        $script:AutoChart09ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart09ADUserAccounts3DInclination = 0
        $script:AutoChart09ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart09ADUserAccounts3DInclination
        $script:AutoChart09ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
#        $script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}
    }
})
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart09ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09ADUserAccounts3DToggleButton.Location.X + $script:AutoChart09ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ADUserAccountsColorsAvailable) { $script:AutoChart09ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Color = $script:AutoChart09ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart09ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'LockedOut' -eq $($script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart09ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ADUserAccountsImportCsvPosResults) { $script:AutoChart09ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart09ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart09ADUserAccountsImportCsvPosResults) { $script:AutoChart09ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ADUserAccountsImportCsvNegResults) { $script:AutoChart09ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart09ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsCheckDiffButton
$script:AutoChart09ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart09ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'LockedOut' -ExpandProperty 'LockedOut' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart09ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ADUserAccounts }})
    $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart09ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart09ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ADUserAccounts }})
    $script:AutoChart09ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart09ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart09ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart09ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart09ADUserAccountsInvestDiffExecuteButton,$script:AutoChart09ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart09ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart09ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart09ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart09ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart09ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09ADUserAccountsManipulationPanel.controls.Add($script:AutoChart09ADUserAccountsCheckDiffButton)


$AutoChart09ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart09ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Locked Accountses" -PropertyX "LockedOut" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart09ADUserAccountsExpandChartButton
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($AutoChart09ADUserAccountsExpandChartButton)


$script:AutoChart09ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart09ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart09ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsOpenInShell
$script:AutoChart09ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart09ADUserAccountsManipulationPanel.controls.Add($script:AutoChart09ADUserAccountsOpenInShell)


$script:AutoChart09ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09ADUserAccountsOpenInShell.Location.X + $script:AutoChart09ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsViewResults
$script:AutoChart09ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart09ADUserAccountsManipulationPanel.controls.Add($script:AutoChart09ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart09ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart09ADUserAccountsOpenInShell.Location.Y + $script:AutoChart09ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart09ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09ADUserAccounts -Title $script:AutoChart09ADUserAccountsTitle
})
$script:AutoChart09ADUserAccountsManipulationPanel.controls.Add($script:AutoChart09ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart09ADUserAccountsSaveButton.Location.Y + $script:AutoChart09ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    LockedOut     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart09ADUserAccountsNoticeTextbox)

$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.Clear()
$script:AutoChart09ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADUserAccounts.Series["Locked Accounts"].Points.AddXY($_.DataField.LockedOut,$_.UniqueCount)}




























##############################################################################################
# AutoChart10ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08ADUserAccounts.Location.X
                  Y = $script:AutoChart08ADUserAccounts.Location.Y + $script:AutoChart08ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart10ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10ADUserAccounts.Titles.Add($script:AutoChart10ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart10ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart10ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart10ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart10ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart10ADUserAccounts.ChartAreas.Add($script:AutoChart10ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10ADUserAccounts.Series.Add("Smartcard Logon Required")
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].SmartcardLogonRequired           = $True
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].BorderWidth       = 1
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].IsVisibleInLegend = $false
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Chartarea         = 'Chart Area'
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Legend            = 'Legend'
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"]['PieLineColor']   = 'Black'
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].ChartType         = 'Column'
$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Color             = 'Red'

        function Generate-AutoChart10ADUserAccounts {
            $script:AutoChart10ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart10ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object SmartcardLogonRequired | Sort-Object SmartcardLogonRequired -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()

            if ($script:AutoChart10ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart10ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart10ADUserAccountsTitle.Text = "Smartcard Logon Required"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart10ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.SmartcardLogonRequired) -eq $DataField.SmartcardLogonRequired) {
                            $Count += 1
                            if ( $script:AutoChart10ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart10ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart10ADUserAccountsUniqueCount = $script:AutoChart10ADUserAccountsCsvComputers.Count
                    $script:AutoChart10ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart10ADUserAccountsCsvComputers
                    }
                    $script:AutoChart10ADUserAccountsOverallDataResults += $script:AutoChart10ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount) }

                $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ADUserAccountsOverallDataResults.count))
                $script:AutoChart10ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart10ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart10ADUserAccountsTitle.Text = "Smartcard Logon Required`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart10ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart10ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsOptionsButton
$script:AutoChart10ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart10ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart10ADUserAccounts.Controls.Add($script:AutoChart10ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart10ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart10ADUserAccounts.Controls.Remove($script:AutoChart10ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ADUserAccounts)

$script:AutoChart10ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ADUserAccountsOverallDataResults.count))
    $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart10ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
        $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
    })
    $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart10ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ADUserAccountsOverallDataResults.count))
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart10ADUserAccountsOverallDataResults.count)
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart10ADUserAccountsOverallDataResults.count) - $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart10ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10ADUserAccountsOverallDataResults.count) - $script:AutoChart10ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
        $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
    })
$script:AutoChart10ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart10ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart10ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].ChartType = $script:AutoChart10ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
#    $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
})
$script:AutoChart10ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10ADUserAccountsChartTypesAvailable) { $script:AutoChart10ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart10ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccounts3DToggleButton
$script:AutoChart10ADUserAccounts3DInclination = 0
$script:AutoChart10ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart10ADUserAccounts3DInclination += 10
    if ( $script:AutoChart10ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart10ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart10ADUserAccounts3DInclination
        $script:AutoChart10ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart10ADUserAccounts3DInclination)"
#        $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
#        $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart10ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart10ADUserAccounts3DInclination
        $script:AutoChart10ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart10ADUserAccounts3DInclination)"
#        $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
#        $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
    }
    else {
        $script:AutoChart10ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart10ADUserAccounts3DInclination = 0
        $script:AutoChart10ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart10ADUserAccounts3DInclination
        $script:AutoChart10ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
#        $script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}
    }
})
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart10ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10ADUserAccounts3DToggleButton.Location.X + $script:AutoChart10ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10ADUserAccountsColorsAvailable) { $script:AutoChart10ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Color = $script:AutoChart10ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart10ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'SmartcardLogonRequired' -eq $($script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart10ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ADUserAccountsImportCsvPosResults) { $script:AutoChart10ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart10ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart10ADUserAccountsImportCsvPosResults) { $script:AutoChart10ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ADUserAccountsImportCsvNegResults) { $script:AutoChart10ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart10ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsCheckDiffButton
$script:AutoChart10ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart10ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'SmartcardLogonRequired' -ExpandProperty 'SmartcardLogonRequired' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart10ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ADUserAccounts }})
    $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart10ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart10ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ADUserAccounts }})
    $script:AutoChart10ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart10ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart10ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart10ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart10ADUserAccountsInvestDiffExecuteButton,$script:AutoChart10ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart10ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart10ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart10ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart10ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart10ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10ADUserAccountsManipulationPanel.controls.Add($script:AutoChart10ADUserAccountsCheckDiffButton)


$AutoChart10ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart10ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Smartcard Logon Requiredes" -PropertyX "SmartcardLogonRequired" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart10ADUserAccountsExpandChartButton
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($AutoChart10ADUserAccountsExpandChartButton)


$script:AutoChart10ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart10ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart10ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsOpenInShell
$script:AutoChart10ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart10ADUserAccountsManipulationPanel.controls.Add($script:AutoChart10ADUserAccountsOpenInShell)


$script:AutoChart10ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10ADUserAccountsOpenInShell.Location.X + $script:AutoChart10ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsViewResults
$script:AutoChart10ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart10ADUserAccountsManipulationPanel.controls.Add($script:AutoChart10ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart10ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart10ADUserAccountsOpenInShell.Location.Y + $script:AutoChart10ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart10ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10ADUserAccounts -Title $script:AutoChart10ADUserAccountsTitle
})
$script:AutoChart10ADUserAccountsManipulationPanel.controls.Add($script:AutoChart10ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart10ADUserAccountsSaveButton.Location.Y + $script:AutoChart10ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    SmartcardLogonRequired     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart10ADUserAccountsNoticeTextbox)

$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.Clear()
$script:AutoChart10ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADUserAccounts.Series["Smartcard Logon Required"].Points.AddXY($_.DataField.SmartcardLogonRequired,$_.UniqueCount)}























##############################################################################################
# AutoChart11ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart11ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart09ADUserAccounts.Location.X
                  Y = $script:AutoChart09ADUserAccounts.Location.Y + $script:AutoChart09ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart11ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart11ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart11ADUserAccounts.Titles.Add($script:AutoChart11ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart11ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart11ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart11ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart11ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart11ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart11ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart11ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart11ADUserAccounts.ChartAreas.Add($script:AutoChart11ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart11ADUserAccounts.Series.Add("Password Never Expires")
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].PasswordNeverExpires           = $True
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].BorderWidth       = 1
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].IsVisibleInLegend = $false
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Chartarea         = 'Chart Area'
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Legend            = 'Legend'
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"]['PieLineColor']   = 'Black'
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"]['PieLabelStyle']  = 'Outside'
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].ChartType         = 'Column'
$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Color             = 'Blue'

        function Generate-AutoChart11ADUserAccounts {
            $script:AutoChart11ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart11ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object PasswordNeverExpires | Sort-Object PasswordNeverExpires -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart11ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()

            if ($script:AutoChart11ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart11ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart11ADUserAccountsTitle.Text = "Password Never Expires"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart11ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart11ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart11ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.PasswordNeverExpires) -eq $DataField.PasswordNeverExpires) {
                            $Count += 1
                            if ( $script:AutoChart11ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart11ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart11ADUserAccountsUniqueCount = $script:AutoChart11ADUserAccountsCsvComputers.Count
                    $script:AutoChart11ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart11ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart11ADUserAccountsCsvComputers
                    }
                    $script:AutoChart11ADUserAccountsOverallDataResults += $script:AutoChart11ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount) }

                $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart11ADUserAccountsOverallDataResults.count))
                $script:AutoChart11ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart11ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart11ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart11ADUserAccountsTitle.Text = "Password Never Expires`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart11ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart11ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart11ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart11ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsOptionsButton
$script:AutoChart11ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart11ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart11ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart11ADUserAccounts.Controls.Add($script:AutoChart11ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart11ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart11ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart11ADUserAccounts.Controls.Remove($script:AutoChart11ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart11ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart11ADUserAccounts)

$script:AutoChart11ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart11ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart11ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart11ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart11ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart11ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart11ADUserAccountsOverallDataResults.count))
    $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart11ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart11ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart11ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
        $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
    })
    $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart11ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart11ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart11ADUserAccountsOverallDataResults.count))
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart11ADUserAccountsOverallDataResults.count)
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart11ADUserAccountsOverallDataResults.count) - $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart11ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart11ADUserAccountsOverallDataResults.count) - $script:AutoChart11ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
        $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
    })
$script:AutoChart11ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart11ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart11ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart11ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart11ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].ChartType = $script:AutoChart11ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
#    $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
})
$script:AutoChart11ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart11ADUserAccountsChartTypesAvailable) { $script:AutoChart11ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart11ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart11ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart11ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart11ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccounts3DToggleButton
$script:AutoChart11ADUserAccounts3DInclination = 0
$script:AutoChart11ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart11ADUserAccounts3DInclination += 10
    if ( $script:AutoChart11ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart11ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart11ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart11ADUserAccounts3DInclination
        $script:AutoChart11ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart11ADUserAccounts3DInclination)"
#        $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
#        $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart11ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart11ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart11ADUserAccounts3DInclination
        $script:AutoChart11ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart11ADUserAccounts3DInclination)"
#        $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
#        $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
    }
    else {
        $script:AutoChart11ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart11ADUserAccounts3DInclination = 0
        $script:AutoChart11ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart11ADUserAccounts3DInclination
        $script:AutoChart11ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
#        $script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}
    }
})
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart11ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart11ADUserAccounts3DToggleButton.Location.X + $script:AutoChart11ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart11ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart11ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart11ADUserAccountsColorsAvailable) { $script:AutoChart11ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart11ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Color = $script:AutoChart11ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart11ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart11ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'PasswordNeverExpires' -eq $($script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart11ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart11ADUserAccountsImportCsvPosResults) { $script:AutoChart11ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart11ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart11ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart11ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart11ADUserAccountsImportCsvPosResults) { $script:AutoChart11ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart11ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart11ADUserAccountsImportCsvNegResults) { $script:AutoChart11ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart11ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart11ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart11ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart11ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart11ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart11ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsCheckDiffButton
$script:AutoChart11ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart11ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'PasswordNeverExpires' -ExpandProperty 'PasswordNeverExpires' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart11ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart11ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart11ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart11ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart11ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart11ADUserAccounts }})
    $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart11ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart11ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart11ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart11ADUserAccounts }})
    $script:AutoChart11ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart11ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart11ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart11ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart11ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart11ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart11ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart11ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart11ADUserAccountsInvestDiffExecuteButton,$script:AutoChart11ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart11ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart11ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart11ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart11ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart11ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart11ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart11ADUserAccountsManipulationPanel.controls.Add($script:AutoChart11ADUserAccountsCheckDiffButton)


$AutoChart11ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart11ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart11ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart11ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Password Never Expireses" -PropertyX "PasswordNeverExpires" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart11ADUserAccountsExpandChartButton
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($AutoChart11ADUserAccountsExpandChartButton)


$script:AutoChart11ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart11ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart11ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart11ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsOpenInShell
$script:AutoChart11ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart11ADUserAccountsManipulationPanel.controls.Add($script:AutoChart11ADUserAccountsOpenInShell)


$script:AutoChart11ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart11ADUserAccountsOpenInShell.Location.X + $script:AutoChart11ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart11ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsViewResults
$script:AutoChart11ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart11ADUserAccountsManipulationPanel.controls.Add($script:AutoChart11ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart11ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart11ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart11ADUserAccountsOpenInShell.Location.Y + $script:AutoChart11ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart11ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart11ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart11ADUserAccounts -Title $script:AutoChart11ADUserAccountsTitle
})
$script:AutoChart11ADUserAccountsManipulationPanel.controls.Add($script:AutoChart11ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart11ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart11ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart11ADUserAccountsSaveButton.Location.Y + $script:AutoChart11ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart11ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    PasswordNeverExpires     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart11ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart11ADUserAccountsNoticeTextbox)

$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.Clear()
$script:AutoChart11ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart11ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart11ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart11ADUserAccounts.Series["Password Never Expires"].Points.AddXY($_.DataField.PasswordNeverExpires,$_.UniqueCount)}





















##############################################################################################
# AutoChart12ADUserAccounts
##############################################################################################

### Auto Create Charts Object
$script:AutoChart12ADUserAccounts = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart10ADUserAccounts.Location.X
                  Y = $script:AutoChart10ADUserAccounts.Location.Y + $script:AutoChart10ADUserAccounts.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart12ADUserAccounts.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart12ADUserAccountsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart12ADUserAccounts.Titles.Add($script:AutoChart12ADUserAccountsTitle)

### Create Charts Area
$script:AutoChart12ADUserAccountsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart12ADUserAccountsArea.Name        = 'Chart Area'
$script:AutoChart12ADUserAccountsArea.AxisX.Title = 'Hosts'
$script:AutoChart12ADUserAccountsArea.AxisX.Interval          = 1
$script:AutoChart12ADUserAccountsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart12ADUserAccountsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart12ADUserAccountsArea.Area3DStyle.Inclination = 75
$script:AutoChart12ADUserAccounts.ChartAreas.Add($script:AutoChart12ADUserAccountsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart12ADUserAccounts.Series.Add("Password Not Required")
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].PasswordNotRequired           = $True
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].BorderWidth       = 1
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].IsVisibleInLegend = $false
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Chartarea         = 'Chart Area'
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Legend            = 'Legend'
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart12ADUserAccounts.Series["Password Not Required"]['PieLineColor']   = 'Black'
$script:AutoChart12ADUserAccounts.Series["Password Not Required"]['PieLabelStyle']  = 'Outside'
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].ChartType         = 'Column'
$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Color             = 'Green'

        function Generate-AutoChart12ADUserAccounts {
            $script:AutoChart12ADUserAccountsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart12ADUserAccountsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object PasswordNotRequired | Sort-Object PasswordNotRequired -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart12ADUserAccountsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()

            if ($script:AutoChart12ADUserAccountsUniqueDataFields.count -gt 0){
                $script:AutoChart12ADUserAccountsTitle.ForeColor = 'Black'
                $script:AutoChart12ADUserAccountsTitle.Text = "Password Not Required"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart12ADUserAccountsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart12ADUserAccountsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart12ADUserAccountsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.PasswordNotRequired) -eq $DataField.PasswordNotRequired) {
                            $Count += 1
                            if ( $script:AutoChart12ADUserAccountsCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart12ADUserAccountsCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart12ADUserAccountsUniqueCount = $script:AutoChart12ADUserAccountsCsvComputers.Count
                    $script:AutoChart12ADUserAccountsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart12ADUserAccountsUniqueCount
                        Computers   = $script:AutoChart12ADUserAccountsCsvComputers
                    }
                    $script:AutoChart12ADUserAccountsOverallDataResults += $script:AutoChart12ADUserAccountsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount) }

                $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart12ADUserAccountsOverallDataResults.count))
                $script:AutoChart12ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart12ADUserAccountsOverallDataResults.count))
            }
            else {
                $script:AutoChart12ADUserAccountsTitle.ForeColor = 'Red'
                $script:AutoChart12ADUserAccountsTitle.Text = "Password Not Required`n
[ No Unique Data Available ]`n"
            }
        }
        Generate-AutoChart12ADUserAccounts

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart12ADUserAccountsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart12ADUserAccounts.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart12ADUserAccounts.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsOptionsButton
$script:AutoChart12ADUserAccountsOptionsButton.Add_Click({
    if ($script:AutoChart12ADUserAccountsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart12ADUserAccountsOptionsButton.Text = 'Options ^'
        $script:AutoChart12ADUserAccounts.Controls.Add($script:AutoChart12ADUserAccountsManipulationPanel)
    }
    elseif ($script:AutoChart12ADUserAccountsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart12ADUserAccountsOptionsButton.Text = 'Options v'
        $script:AutoChart12ADUserAccounts.Controls.Remove($script:AutoChart12ADUserAccountsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart12ADUserAccountsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart12ADUserAccounts)

$script:AutoChart12ADUserAccountsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart12ADUserAccounts.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart12ADUserAccounts.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart12ADUserAccountsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart12ADUserAccountsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart12ADUserAccountsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart12ADUserAccountsOverallDataResults.count))
    $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart12ADUserAccountsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue = $script:AutoChart12ADUserAccountsTrimOffFirstTrackBar.Value
        $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart12ADUserAccountsTrimOffFirstTrackBar.Value)"
        $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
        $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
    })
    $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Controls.Add($script:AutoChart12ADUserAccountsTrimOffFirstTrackBar)
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccountsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart12ADUserAccountsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Location.X + $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart12ADUserAccountsOverallDataResults.count))
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.Value         = $($script:AutoChart12ADUserAccountsOverallDataResults.count)
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue   = 0
    $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue = $($script:AutoChart12ADUserAccountsOverallDataResults.count) - $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.Value
        $script:AutoChart12ADUserAccountsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart12ADUserAccountsOverallDataResults.count) - $script:AutoChart12ADUserAccountsTrimOffLastTrackBar.Value)"
        $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
        $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
    })
$script:AutoChart12ADUserAccountsTrimOffLastGroupBox.Controls.Add($script:AutoChart12ADUserAccountsTrimOffLastTrackBar)
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccountsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart12ADUserAccountsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Location.Y + $script:AutoChart12ADUserAccountsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart12ADUserAccountsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart12ADUserAccounts.Series["Password Not Required"].ChartType = $script:AutoChart12ADUserAccountsChartTypeComboBox.SelectedItem
#    $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
#    $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
})
$script:AutoChart12ADUserAccountsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart12ADUserAccountsChartTypesAvailable) { $script:AutoChart12ADUserAccountsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccountsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart12ADUserAccounts3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart12ADUserAccountsChartTypeComboBox.Location.X + $script:AutoChart12ADUserAccountsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart12ADUserAccountsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccounts3DToggleButton
$script:AutoChart12ADUserAccounts3DInclination = 0
$script:AutoChart12ADUserAccounts3DToggleButton.Add_Click({
    $script:AutoChart12ADUserAccounts3DInclination += 10
    if ( $script:AutoChart12ADUserAccounts3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart12ADUserAccountsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart12ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart12ADUserAccounts3DInclination
        $script:AutoChart12ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart12ADUserAccounts3DInclination)"
#        $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
#        $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart12ADUserAccounts3DInclination -le 90 ) {
        $script:AutoChart12ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart12ADUserAccounts3DInclination
        $script:AutoChart12ADUserAccounts3DToggleButton.Text  = "3D On ($script:AutoChart12ADUserAccounts3DInclination)"
#        $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
#        $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
    }
    else {
        $script:AutoChart12ADUserAccounts3DToggleButton.Text  = "3D Off"
        $script:AutoChart12ADUserAccounts3DInclination = 0
        $script:AutoChart12ADUserAccountsArea.Area3DStyle.Inclination = $script:AutoChart12ADUserAccounts3DInclination
        $script:AutoChart12ADUserAccountsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
#        $script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}
    }
})
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccounts3DToggleButton)

### Change the color of the chart
$script:AutoChart12ADUserAccountsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart12ADUserAccounts3DToggleButton.Location.X + $script:AutoChart12ADUserAccounts3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart12ADUserAccounts3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart12ADUserAccountsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart12ADUserAccountsColorsAvailable) { $script:AutoChart12ADUserAccountsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart12ADUserAccountsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart12ADUserAccounts.Series["Password Not Required"].Color = $script:AutoChart12ADUserAccountsChangeColorComboBox.SelectedItem
})
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccountsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart12ADUserAccounts {
    # List of Positive Endpoints that positively match
    $script:AutoChart12ADUserAccountsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'PasswordNotRequired' -eq $($script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart12ADUserAccountsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart12ADUserAccountsImportCsvPosResults) { $script:AutoChart12ADUserAccountsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart12ADUserAccountsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique

    $script:AutoChart12ADUserAccountsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart12ADUserAccountsImportCsvAll) { if ($Endpoint -notin $script:AutoChart12ADUserAccountsImportCsvPosResults) { $script:AutoChart12ADUserAccountsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart12ADUserAccountsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart12ADUserAccountsImportCsvNegResults) { $script:AutoChart12ADUserAccountsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart12ADUserAccountsImportCsvPosResults.count))"
    $script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart12ADUserAccountsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart12ADUserAccountsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart12ADUserAccountsTrimOffLastGroupBox.Location.X + $script:AutoChart12ADUserAccountsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart12ADUserAccountsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsCheckDiffButton
$script:AutoChart12ADUserAccountsCheckDiffButton.Add_Click({
    $script:AutoChart12ADUserAccountsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'PasswordNotRequired' -ExpandProperty 'PasswordNotRequired' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart12ADUserAccountsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart12ADUserAccountsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart12ADUserAccountsInvestDiffDropDownLabel.Location.y + $script:AutoChart12ADUserAccountsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart12ADUserAccountsInvestDiffDropDownArray) { $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart12ADUserAccounts }})
    $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart12ADUserAccounts })

    ### Investigate Difference Execute Button
    $script:AutoChart12ADUserAccountsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Location.y + $script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsInvestDiffExecuteButton
    $script:AutoChart12ADUserAccountsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart12ADUserAccounts }})
    $script:AutoChart12ADUserAccountsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart12ADUserAccounts })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart12ADUserAccountsInvestDiffExecuteButton.Location.y + $script:AutoChart12ADUserAccountsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12ADUserAccountsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Location.y + $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Location.x + $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart12ADUserAccountsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel.Location.y + $script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart12ADUserAccountsInvestDiffForm.Controls.AddRange(@($script:AutoChart12ADUserAccountsInvestDiffDropDownLabel,$script:AutoChart12ADUserAccountsInvestDiffDropDownComboBox,$script:AutoChart12ADUserAccountsInvestDiffExecuteButton,$script:AutoChart12ADUserAccountsInvestDiffPosResultsLabel,$script:AutoChart12ADUserAccountsInvestDiffPosResultsTextBox,$script:AutoChart12ADUserAccountsInvestDiffNegResultsLabel,$script:AutoChart12ADUserAccountsInvestDiffNegResultsTextBox))
    $script:AutoChart12ADUserAccountsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart12ADUserAccountsInvestDiffForm.ShowDialog()
})
$script:AutoChart12ADUserAccountsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart12ADUserAccountsManipulationPanel.controls.Add($script:AutoChart12ADUserAccountsCheckDiffButton)


$AutoChart12ADUserAccountsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart12ADUserAccountsCheckDiffButton.Location.X + $script:AutoChart12ADUserAccountsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart12ADUserAccountsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Password Not Requiredes" -PropertyX "PasswordNotRequired" -PropertyY "Name" }
}
Apply-CommonButtonSettings -Button $AutoChart12ADUserAccountsExpandChartButton
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($AutoChart12ADUserAccountsExpandChartButton)


$script:AutoChart12ADUserAccountsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart12ADUserAccountsCheckDiffButton.Location.X
                   Y = $script:AutoChart12ADUserAccountsCheckDiffButton.Location.Y + $script:AutoChart12ADUserAccountsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsOpenInShell
$script:AutoChart12ADUserAccountsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart12ADUserAccountsManipulationPanel.controls.Add($script:AutoChart12ADUserAccountsOpenInShell)


$script:AutoChart12ADUserAccountsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart12ADUserAccountsOpenInShell.Location.X + $script:AutoChart12ADUserAccountsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart12ADUserAccountsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsViewResults
$script:AutoChart12ADUserAccountsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart12ADUserAccountsManipulationPanel.controls.Add($script:AutoChart12ADUserAccountsViewResults)


### Save the chart to file
$script:AutoChart12ADUserAccountsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart12ADUserAccountsOpenInShell.Location.X
                  Y = $script:AutoChart12ADUserAccountsOpenInShell.Location.Y + $script:AutoChart12ADUserAccountsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
Apply-CommonButtonSettings -Button $script:AutoChart12ADUserAccountsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart12ADUserAccountsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart12ADUserAccounts -Title $script:AutoChart12ADUserAccountsTitle
})
$script:AutoChart12ADUserAccountsManipulationPanel.controls.Add($script:AutoChart12ADUserAccountsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart12ADUserAccountsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart12ADUserAccountsSaveButton.Location.X
                        Y = $script:AutoChart12ADUserAccountsSaveButton.Location.Y + $script:AutoChart12ADUserAccountsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart12ADUserAccountsCsvFileHosts.Count)"
    Multiline   = $false
    PasswordNotRequired     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart12ADUserAccountsManipulationPanel.Controls.Add($script:AutoChart12ADUserAccountsNoticeTextbox)

$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.Clear()
$script:AutoChart12ADUserAccountsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart12ADUserAccountsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart12ADUserAccountsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart12ADUserAccounts.Series["Password Not Required"].Points.AddXY($_.DataField.PasswordNotRequired,$_.UniqueCount)}


























# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5Z+JKwLN2YoT1yEar/caN0Lh
# DIigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUt2AuSGVLVui6Srrfqs9Jzl18wekwDQYJKoZI
# hvcNAQEBBQAEggEAxbqhD5/knTXtrKBeaTivEn/283Ft7WeKSRtcveEIUmUm1J6I
# 4mzecypBsmNJXnTakcPatG8Rcs27k+6XWdC5uKLKQ1RmK6oUaPkglvPMJGVZzypA
# Ikkx6/zYKaqA8qQp98Z4dVPyd2+jP5EXOtmUMXbHyTLTGO9rCniuKsHAWhf+wrEG
# aTPq6JyMG8iQDM2w8xZwdnJL3ImfcI9p49KJCcawHEsvciOA6Z554N7DtFor0XMM
# 7EeNqDsaBVsDB78NmoBOkRkpCW2s+jvpDhz42K9nL5izx51K0NlbBZFgn/KlOxDr
# VajdAqO1YRdjZ5FGH+7zmJoySBpym0YmHE9BFg==
# SIG # End signature block
