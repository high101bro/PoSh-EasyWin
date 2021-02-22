$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Startup Info'
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

$script:AutoChart01StartupsCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Startup') { $script:AutoChart01StartupsCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01StartupsCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart01Startups.Controls.Remove($script:AutoChart01StartupsManipulationPanel)
    $script:AutoChart02StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart02Startups.Controls.Remove($script:AutoChart02StartupsManipulationPanel)
    $script:AutoChart03StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart03Startups.Controls.Remove($script:AutoChart03StartupsManipulationPanel)
    $script:AutoChart04StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart04Startups.Controls.Remove($script:AutoChart04StartupsManipulationPanel)
    $script:AutoChart05StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart05Startups.Controls.Remove($script:AutoChart05StartupsManipulationPanel)
    $script:AutoChart06StartupsOptionsButton.Text = 'Options v'
    $script:AutoChart06Startups.Controls.Remove($script:AutoChart06StartupsManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Startup Info'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter'
}











$script:AutoChartOpenResultsOpenFileDialogfilename = $null

$AutoChartsUpdateChartsOptionsPanel = New-Object System.Windows.Forms.Panel -Property @{
    text   = 0
    Left   = $FormScale * 5
    Top    = 0
    Autosize = $true
}
            $AutoChartPullNewDataFromChartsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Update From Existing Charts' Endpoints"
                Left   = $FormScale * 5
                Top    = 0
                Width  = $FormScale * 225
                Height = $FormScale * 15
                Checked = $true
            }
            $AutoChartsUpdateChartsOptionsPanel.Controls.Add($AutoChartPullNewDataFromChartsRadioButton)


            $AutoChartPullNewDataCheckBoxedRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text    = 'Update From CheckBoxed Endpoints'
                Left    = $FormScale * 5
                Top     = $AutoChartPullNewDataFromChartsRadioButton.Top + $AutoChartPullNewDataFromChartsRadioButton.Height
                Width   = $FormScale * 225
                Height  = $FormScale * 15
            }
            $AutoChartsUpdateChartsOptionsPanel.Controls.Add($AutoChartPullNewDataCheckBoxedRadioButton)


            $AutoChartSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = 'Update From An Existing Selected File'
                Left   = $FormScale * 5
                Top    = $AutoChartPullNewDataCheckBoxedRadioButton.Top + $AutoChartPullNewDataCheckBoxedRadioButton.Height
                Width  = $FormScale * 225
                Height = $FormScale * 15
            }
            $AutoChartsUpdateChartsOptionsPanel.Controls.Add($AutoChartSelectFileRadioButton)

$script:AutoChartsIndividualTab01.Controls.Add($AutoChartsUpdateChartsOptionsPanel)


$AutoChartsUpdateChartsProtocolPanel = New-Object System.Windows.Forms.Panel -Property @{
    text   = 0
    Left   = $AutoChartsUpdateChartsOptionsPanel.Left + $AutoChartsUpdateChartsOptionsPanel.Width
    Top    = $AutoChartsUpdateChartsOptionsPanel.Top
    Width  = $FormScale * 65
    Height = $AutoChartsUpdateChartsOptionsPanel.Height
}
            $AutoChartProtocolWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = 0
                Top    = 0
                Width  = $FormScale * 65
                Height = $FormScale * 15
                Checked = $true
                Add_Click = {
                    $AutoChartPullNewDataEnrichedCheckBox.enabled = $true
                }

            }
            $AutoChartsUpdateChartsProtocolPanel.Controls.Add($AutoChartProtocolWinRMRadioButton)


            $AutoChartProtocolRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text    = 'RPC'
                Left    = $AutoChartProtocolWinRMRadioButton.Left
                Top     = $AutoChartProtocolWinRMRadioButton.Top + $AutoChartProtocolWinRMRadioButton.Height
                Width   = $FormScale * 65
                Height  = $FormScale * 15
                Add_Click = {
                    $AutoChartPullNewDataEnrichedCheckBox.checked = $false
                    $AutoChartPullNewDataEnrichedCheckBox.enabled = $false
                }
            }
            $AutoChartsUpdateChartsProtocolPanel.Controls.Add($AutoChartProtocolRPCRadioButton)


            $AutoChartProtocolSMBRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = 'SMB'
                Left   = $AutoChartProtocolWinRMRadioButton.Left
                Top    = $AutoChartProtocolRPCRadioButton.Top + $AutoChartProtocolRPCRadioButton.Height
                Width  = $FormScale * 65
                Height = $FormScale * 15
                Add_Click = {
                    $AutoChartPullNewDataEnrichedCheckBox.checked = $false
                    $AutoChartPullNewDataEnrichedCheckBox.enabled = $false
                }
            }
            $AutoChartsUpdateChartsProtocolPanel.Controls.Add($AutoChartProtocolSMBRadioButton)
$script:AutoChartsIndividualTab01.Controls.Add($AutoChartsUpdateChartsProtocolPanel)




$AutoChartPullNewDataButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Update Charts'
    Left   = $AutoChartsUpdateChartsProtocolPanel.Left + $AutoChartsUpdateChartsProtocolPanel.Width
    Top    = $FormScale * 5
    Width  = $FormScale * 100
    Height = $FormScale * 22
}
 $script:AutoChartsIndividualTab01.Controls.Add($AutoChartPullNewDataButton)
CommonButtonSettings -Button $AutoChartPullNewDataButton
$AutoChartPullNewDataButton.Add_Click({

    #====================
    # First Radio Button
    #====================
    if ($AutoChartPullNewDataFromChartsRadioButton.checked){
        $ChartComputerList = $script:AutoChartDataSourceCsv.ComputerName | Sort-Object -Unique

        if ($ChartComputerList.count -eq 0) {
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-EasyWin')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsStartupCommands -ComputerNameList $ChartComputerList }
            Launch-ProgressBarForm -FormTitle 'Progress Bar' -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
        }
    }

    #=====================
    # Second Radio Button
    #=====================
    if ($AutoChartPullNewDataCheckBoxedRadioButton.checked) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0) {
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints','PoSh-EasyWin')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsStartupCommands -ComputerNameList $script:ComputerList }
            Launch-ProgressBarForm -FormTitle 'Progress Bar' -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
        }
    }

    #====================
    # Thrid Radio Button
    #====================
    if ($AutoChartSelectFileRadioButton.checked) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AutoChartOpenResultsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
        $AutoChartOpenResultsOpenFileDialog.Title            = "Open XML Data"
        $AutoChartOpenResultsOpenFileDialog.InitialDirectory = "$(if (Test-Path $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
        $AutoChartOpenResultsOpenFileDialog.filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
        $AutoChartOpenResultsOpenFileDialog.ShowDialog() | Out-Null
        $AutoChartOpenResultsOpenFileDialog.ShowHelp = $true
        $script:AutoChartOpenResultsOpenFileDialogfilename = $AutoChartOpenResultsOpenFileDialog.filename
        $script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartOpenResultsOpenFileDialogfilename

        $script:AutoChartDataSourceCsvFileName = $AutoChartOpenResultsOpenFileDialog.filename
    }

    Generate-AutoChart01Startups
    Generate-AutoChart02Startups
    Generate-AutoChart03Startups
    Generate-AutoChart04Startups
    Generate-AutoChart05Startups
    Generate-AutoChart06Startups
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartsMainLabel01)


$AutoChartPullNewDataEnrichedCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Enriched (Slower)'
    Left    = $AutoChartPullNewDataButton.Left
    Top     = $AutoChartPullNewDataButton.Top + $AutoChartPullNewDataButton.Height
    Width   = $FormScale * 125
    Height  = $FormScale * 22
    Checked = $true
}
$script:AutoChartsIndividualTab01.Controls.Add($AutoChartPullNewDataEnrichedCheckBox)






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
# AutoChart01Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01Startups.Titles.Add($script:AutoChart01StartupsTitle)

### Create Charts Area
$script:AutoChart01StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01StartupsArea.Name        = 'Chart Area'
$script:AutoChart01StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart01StartupsArea.AxisX.Interval          = 1
$script:AutoChart01StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart01Startups.ChartAreas.Add($script:AutoChart01StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01Startups.Series.Add("Startup Names")
$script:AutoChart01Startups.Series["Startup Names"].Enabled           = $True
$script:AutoChart01Startups.Series["Startup Names"].BorderWidth       = 1
$script:AutoChart01Startups.Series["Startup Names"].IsVisibleInLegend = $false
$script:AutoChart01Startups.Series["Startup Names"].Chartarea         = 'Chart Area'
$script:AutoChart01Startups.Series["Startup Names"].Legend            = 'Legend'
$script:AutoChart01Startups.Series["Startup Names"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01Startups.Series["Startup Names"]['PieLineColor']   = 'Black'
$script:AutoChart01Startups.Series["Startup Names"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01Startups.Series["Startup Names"].ChartType         = 'Column'
$script:AutoChart01Startups.Series["Startup Names"].Color             = 'Red'

        function Generate-AutoChart01Startups {
            $script:AutoChart01StartupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart01StartupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01StartupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()

            if ($script:AutoChart01StartupsUniqueDataFields.count -gt 0){
                $script:AutoChart01StartupsTitle.ForeColor = 'Black'
                $script:AutoChart01StartupsTitle.Text = "Startup Names"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart01StartupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01StartupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01StartupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01StartupsCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart01StartupsCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart01StartupsUniqueCount = $script:AutoChart01StartupsCsvComputers.Count
                    $script:AutoChart01StartupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01StartupsUniqueCount
                        Computers   = $script:AutoChart01StartupsCsvComputers
                    }
                    $script:AutoChart01StartupsOverallDataResults += $script:AutoChart01StartupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01StartupsOverallDataResults.count))
                $script:AutoChart01StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01StartupsOverallDataResults.count))
            }
            else {
                $script:AutoChart01StartupsTitle.ForeColor = 'Red'
                $script:AutoChart01StartupsTitle.Text = "Startups`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01Startups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01StartupsOptionsButton
$script:AutoChart01StartupsOptionsButton.Add_Click({
    if ($script:AutoChart01StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart01Startups.Controls.Add($script:AutoChart01StartupsManipulationPanel)
    }
    elseif ($script:AutoChart01StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart01Startups.Controls.Remove($script:AutoChart01StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01Startups)


$script:AutoChart01StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01StartupsOverallDataResults.count))
    $script:AutoChart01StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01StartupsTrimOffFirstTrackBarValue = $script:AutoChart01StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart01StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
        $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart01StartupsTrimOffFirstTrackBar)
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart01StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01StartupsOverallDataResults.count))
    $script:AutoChart01StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart01StartupsOverallDataResults.count)
    $script:AutoChart01StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart01StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01StartupsTrimOffLastTrackBarValue = $($script:AutoChart01StartupsOverallDataResults.count) - $script:AutoChart01StartupsTrimOffLastTrackBar.Value
        $script:AutoChart01StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01StartupsOverallDataResults.count) - $script:AutoChart01StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
        $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart01StartupsTrimOffLastTrackBar)
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart01StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Startups.Series["Startup Names"].ChartType = $script:AutoChart01StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
#    $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01StartupsChartTypesAvailable) { $script:AutoChart01StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01StartupsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01StartupsChartTypeComboBox.Location.X + $script:AutoChart01StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01Startups3DToggleButton
$script:AutoChart01Startups3DInclination = 0
$script:AutoChart01Startups3DToggleButton.Add_Click({

    $script:AutoChart01Startups3DInclination += 10
    if ( $script:AutoChart01Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01StartupsArea.Area3DStyle.Inclination = $script:AutoChart01Startups3DInclination
        $script:AutoChart01Startups3DToggleButton.Text  = "3D On ($script:AutoChart01Startups3DInclination)"
#        $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
#        $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01Startups3DInclination -le 90 ) {
        $script:AutoChart01StartupsArea.Area3DStyle.Inclination = $script:AutoChart01Startups3DInclination
        $script:AutoChart01Startups3DToggleButton.Text  = "3D On ($script:AutoChart01Startups3DInclination)"
#        $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
#        $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart01Startups3DInclination = 0
        $script:AutoChart01StartupsArea.Area3DStyle.Inclination = $script:AutoChart01Startups3DInclination
        $script:AutoChart01StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
#        $script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart01StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01Startups3DToggleButton.Location.X + $script:AutoChart01Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01StartupsColorsAvailable) { $script:AutoChart01StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Startups.Series["Startup Names"].Color = $script:AutoChart01StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01StartupsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart01StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart01StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart01StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01StartupsImportCsvPosResults) { $script:AutoChart01StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart01StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart01StartupsImportCsvPosResults) { $script:AutoChart01StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01StartupsImportCsvNegResults) { $script:AutoChart01StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01StartupsImportCsvPosResults.count))"
    $script:AutoChart01StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart01StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01StartupsCheckDiffButton
$script:AutoChart01StartupsCheckDiffButton.Add_Click({
    $script:AutoChart01StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart01StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01StartupsInvestDiffDropDownArray) { $script:AutoChart01StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01Startups }})
    $script:AutoChart01StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart01StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart01StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01StartupsInvestDiffExecuteButton
    $script:AutoChart01StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01Startups }})
    $script:AutoChart01StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart01StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart01StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart01StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart01StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart01StartupsInvestDiffDropDownLabel,$script:AutoChart01StartupsInvestDiffDropDownComboBox,$script:AutoChart01StartupsInvestDiffExecuteButton,$script:AutoChart01StartupsInvestDiffPosResultsLabel,$script:AutoChart01StartupsInvestDiffPosResultsTextBox,$script:AutoChart01StartupsInvestDiffNegResultsLabel,$script:AutoChart01StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart01StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart01StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01StartupsManipulationPanel.controls.Add($script:AutoChart01StartupsCheckDiffButton)


$AutoChart01StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01StartupsCheckDiffButton.Location.X + $script:AutoChart01StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "Startup Names" -PropertyX "Name" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart01StartupsExpandChartButton
$script:AutoChart01StartupsManipulationPanel.Controls.Add($AutoChart01StartupsExpandChartButton)


$script:AutoChart01StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart01StartupsCheckDiffButton.Location.Y + $script:AutoChart01StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01StartupsOpenInShell
$script:AutoChart01StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01StartupsManipulationPanel.controls.Add($script:AutoChart01StartupsOpenInShell)


$script:AutoChart01StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01StartupsOpenInShell.Location.X + $script:AutoChart01StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01StartupsViewResults
$script:AutoChart01StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01StartupsManipulationPanel.controls.Add($script:AutoChart01StartupsViewResults)


### Save the chart to file
$script:AutoChart01StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01StartupsOpenInShell.Location.X
                  Y = $script:AutoChart01StartupsOpenInShell.Location.Y + $script:AutoChart01StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01Startups -Title $script:AutoChart01StartupsTitle
})
$script:AutoChart01StartupsManipulationPanel.controls.Add($script:AutoChart01StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01StartupsSaveButton.Location.X
                        Y = $script:AutoChart01StartupsSaveButton.Location.Y + $script:AutoChart01StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01StartupsManipulationPanel.Controls.Add($script:AutoChart01StartupsNoticeTextbox)

$script:AutoChart01Startups.Series["Startup Names"].Points.Clear()
$script:AutoChart01StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Startups.Series["Startup Names"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart02Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Startups.Location.X + $script:AutoChart01Startups.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01Startups.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02Startups.Titles.Add($script:AutoChart02StartupsTitle)

### Create Charts Area
$script:AutoChart02StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02StartupsArea.Name        = 'Chart Area'
$script:AutoChart02StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart02StartupsArea.AxisX.Interval          = 1
$script:AutoChart02StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart02Startups.ChartAreas.Add($script:AutoChart02StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02Startups.Series.Add("Startups Per Host")
$script:AutoChart02Startups.Series["Startups Per Host"].Enabled           = $True
$script:AutoChart02Startups.Series["Startups Per Host"].BorderWidth       = 1
$script:AutoChart02Startups.Series["Startups Per Host"].IsVisibleInLegend = $false
$script:AutoChart02Startups.Series["Startups Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02Startups.Series["Startups Per Host"].Legend            = 'Legend'
$script:AutoChart02Startups.Series["Startups Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02Startups.Series["Startups Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02Startups.Series["Startups Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02Startups.Series["Startups Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02Startups.Series["Startups Per Host"].Color             = 'Blue'

        function Generate-AutoChart02Startups {
            $script:AutoChart02StartupsCsvFileHosts     = ($script:AutoChartDataSourceCsv).ComputerName | Sort-Object -Unique
            $script:AutoChart02StartupsUniqueDataFields = ($script:AutoChartDataSourceCsv).Name | Sort-Object -Property 'Name'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02StartupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02StartupsUniqueDataFields.count -gt 0){
                $script:AutoChart02StartupsTitle.ForeColor = 'Black'
                $script:AutoChart02StartupsTitle.Text = "Startups Per Host"

                $AutoChart02StartupsCurrentComputer  = ''
                $AutoChart02StartupsCheckIfFirstLine = $false
                $AutoChart02StartupsResultsCount     = 0
                $AutoChart02StartupsComputer         = @()
                $AutoChart02StartupsYResults         = @()
                $script:AutoChart02StartupsOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object ComputerName) ) {
                    if ( $AutoChart02StartupsCheckIfFirstLine -eq $false ) { $AutoChart02StartupsCurrentComputer  = $Line.ComputerName ; $AutoChart02StartupsCheckIfFirstLine = $true }
                    if ( $AutoChart02StartupsCheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart02StartupsCurrentComputer ) {
                            if ( $AutoChart02StartupsYResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart02StartupsYResults += $Line.Name ; $AutoChart02StartupsResultsCount += 1 }
                                if ( $AutoChart02StartupsComputer -notcontains $Line.ComputerName ) { $AutoChart02StartupsComputer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart02StartupsCurrentComputer ) {
                            $AutoChart02StartupsCurrentComputer = $Line.ComputerName
                            $AutoChart02StartupsYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02StartupsResultsCount
                                Computer     = $AutoChart02StartupsComputer
                            }
                            $script:AutoChart02StartupsOverallDataResults += $AutoChart02StartupsYDataResults
                            $AutoChart02StartupsYResults     = @()
                            $AutoChart02StartupsResultsCount = 0
                            $AutoChart02StartupsComputer     = @()
                            if ( $AutoChart02StartupsYResults -notcontains $Line.Name ) {
                                if ( $Line.Name -ne "" ) { $AutoChart02StartupsYResults += $Line.Name ; $AutoChart02StartupsResultsCount += 1 }
                                if ( $AutoChart02StartupsComputer -notcontains $Line.ComputerName ) { $AutoChart02StartupsComputer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02StartupsYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02StartupsResultsCount ; Computer = $AutoChart02StartupsComputer }
                $script:AutoChart02StartupsOverallDataResults += $AutoChart02StartupsYDataResults
                $script:AutoChart02StartupsOverallDataResults | ForEach-Object { $script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
                $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02StartupsOverallDataResults.count))
                $script:AutoChart02StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02StartupsOverallDataResults.count))
            }
            else {
                $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
                $script:AutoChart02StartupsTitle.ForeColor = 'Red'
                $script:AutoChart02StartupsTitle.Text = "Startups Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02Startups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02StartupsOptionsButton
$script:AutoChart02StartupsOptionsButton.Add_Click({
    if ($script:AutoChart02StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart02Startups.Controls.Add($script:AutoChart02StartupsManipulationPanel)
    }
    elseif ($script:AutoChart02StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart02Startups.Controls.Remove($script:AutoChart02StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02Startups)

$script:AutoChart02StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02StartupsOverallDataResults.count))
    $script:AutoChart02StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02StartupsTrimOffFirstTrackBarValue = $script:AutoChart02StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart02StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
        $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart02StartupsTrimOffFirstTrackBar)
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart02StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02StartupsOverallDataResults.count))
    $script:AutoChart02StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart02StartupsOverallDataResults.count)
    $script:AutoChart02StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart02StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02StartupsTrimOffLastTrackBarValue = $($script:AutoChart02StartupsOverallDataResults.count) - $script:AutoChart02StartupsTrimOffLastTrackBar.Value
        $script:AutoChart02StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02StartupsOverallDataResults.count) - $script:AutoChart02StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
        $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart02StartupsTrimOffLastTrackBar)
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart02StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Startups.Series["Startups Per Host"].ChartType = $script:AutoChart02StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
#    $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02StartupsChartTypesAvailable) { $script:AutoChart02StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02StartupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02StartupsChartTypeComboBox.Location.X + $script:AutoChart02StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02Startups3DToggleButton
$script:AutoChart02Startups3DInclination = 0
$script:AutoChart02Startups3DToggleButton.Add_Click({
    $script:AutoChart02Startups3DInclination += 10
    if ( $script:AutoChart02Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02StartupsArea.Area3DStyle.Inclination = $script:AutoChart02Startups3DInclination
        $script:AutoChart02Startups3DToggleButton.Text  = "3D On ($script:AutoChart02Startups3DInclination)"
#        $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02Startups3DInclination -le 90 ) {
        $script:AutoChart02StartupsArea.Area3DStyle.Inclination = $script:AutoChart02Startups3DInclination
        $script:AutoChart02Startups3DToggleButton.Text  = "3D On ($script:AutoChart02Startups3DInclination)"
#        $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart02Startups3DInclination = 0
        $script:AutoChart02StartupsArea.Area3DStyle.Inclination = $script:AutoChart02Startups3DInclination
        $script:AutoChart02StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
#        $script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart02StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02Startups3DToggleButton.Location.X + $script:AutoChart02Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02StartupsColorsAvailable) { $script:AutoChart02StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Startups.Series["Startups Per Host"].Color = $script:AutoChart02StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02StartupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart02StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart02StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart02StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02StartupsImportCsvPosResults) { $script:AutoChart02StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart02StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart02StartupsImportCsvPosResults) { $script:AutoChart02StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02StartupsImportCsvNegResults) { $script:AutoChart02StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02StartupsImportCsvPosResults.count))"
    $script:AutoChart02StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart02StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02StartupsCheckDiffButton
$script:AutoChart02StartupsCheckDiffButton.Add_Click({
    $script:AutoChart02StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart02StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02StartupsInvestDiffDropDownArray) { $script:AutoChart02StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02Startups }})
    $script:AutoChart02StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart02StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart02StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02StartupsInvestDiffExecuteButton
    $script:AutoChart02StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02Startups }})
    $script:AutoChart02StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart02StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart02StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart02StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart02StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart02StartupsInvestDiffDropDownLabel,$script:AutoChart02StartupsInvestDiffDropDownComboBox,$script:AutoChart02StartupsInvestDiffExecuteButton,$script:AutoChart02StartupsInvestDiffPosResultsLabel,$script:AutoChart02StartupsInvestDiffPosResultsTextBox,$script:AutoChart02StartupsInvestDiffNegResultsLabel,$script:AutoChart02StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart02StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart02StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02StartupsManipulationPanel.controls.Add($script:AutoChart02StartupsCheckDiffButton)


$AutoChart02StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02StartupsCheckDiffButton.Location.X + $script:AutoChart02StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "Startups per Endpoint" -PropertyX "ComputerName" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart02StartupsExpandChartButton
$script:AutoChart02StartupsManipulationPanel.Controls.Add($AutoChart02StartupsExpandChartButton)


$script:AutoChart02StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart02StartupsCheckDiffButton.Location.Y + $script:AutoChart02StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02StartupsOpenInShell
$script:AutoChart02StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02StartupsManipulationPanel.controls.Add($script:AutoChart02StartupsOpenInShell)


$script:AutoChart02StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02StartupsOpenInShell.Location.X + $script:AutoChart02StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02StartupsViewResults
$script:AutoChart02StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02StartupsManipulationPanel.controls.Add($script:AutoChart02StartupsViewResults)


### Save the chart to file
$script:AutoChart02StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02StartupsOpenInShell.Location.X
                  Y = $script:AutoChart02StartupsOpenInShell.Location.Y + $script:AutoChart02StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02Startups -Title $script:AutoChart02StartupsTitle
})
$script:AutoChart02StartupsManipulationPanel.controls.Add($script:AutoChart02StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02StartupsSaveButton.Location.X
                        Y = $script:AutoChart02StartupsSaveButton.Location.Y + $script:AutoChart02StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02StartupsManipulationPanel.Controls.Add($script:AutoChart02StartupsNoticeTextbox)

$script:AutoChart02Startups.Series["Startups Per Host"].Points.Clear()
$script:AutoChart02StartupsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Startups.Series["Startups Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Startups.Location.X
                  Y = $script:AutoChart01Startups.Location.Y + $script:AutoChart01Startups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03Startups.Titles.Add($script:AutoChart03StartupsTitle)

### Create Charts Area
$script:AutoChart03StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03StartupsArea.Name        = 'Chart Area'
$script:AutoChart03StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart03StartupsArea.AxisX.Interval          = 1
$script:AutoChart03StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart03Startups.ChartAreas.Add($script:AutoChart03StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03Startups.Series.Add("Paths")
$script:AutoChart03Startups.Series["Paths"].Enabled           = $True
$script:AutoChart03Startups.Series["Paths"].BorderWidth       = 1
$script:AutoChart03Startups.Series["Paths"].IsVisibleInLegend = $false
$script:AutoChart03Startups.Series["Paths"].Chartarea         = 'Chart Area'
$script:AutoChart03Startups.Series["Paths"].Legend            = 'Legend'
$script:AutoChart03Startups.Series["Paths"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03Startups.Series["Paths"]['PieLineColor']   = 'Black'
$script:AutoChart03Startups.Series["Paths"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03Startups.Series["Paths"].ChartType         = 'Column'
$script:AutoChart03Startups.Series["Paths"].Color             = 'Green'

        function Generate-AutoChart03Startups {
            $script:AutoChart03StartupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart03StartupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Path' | Sort-Object -Property 'Path' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03StartupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03Startups.Series["Paths"].Points.Clear()

            if ($script:AutoChart03StartupsUniqueDataFields.count -gt 0){
                $script:AutoChart03StartupsTitle.ForeColor = 'Black'
                $script:AutoChart03StartupsTitle.Text = "Paths"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart03StartupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03StartupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03StartupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Path -eq $DataField.Path) {
                            $Count += 1
                            if ( $script:AutoChart03StartupsCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart03StartupsCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart03StartupsUniqueCount = $script:AutoChart03StartupsCsvComputers.Count
                    $script:AutoChart03StartupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03StartupsUniqueCount
                        Computers   = $script:AutoChart03StartupsCsvComputers
                    }
                    $script:AutoChart03StartupsOverallDataResults += $script:AutoChart03StartupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount) }

                $script:AutoChart03StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03StartupsOverallDataResults.count))
                $script:AutoChart03StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03StartupsOverallDataResults.count))
            }
            else {
                $script:AutoChart03StartupsTitle.ForeColor = 'Red'
                $script:AutoChart03StartupsTitle.Text = "Paths`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03Startups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03StartupsOptionsButton
$script:AutoChart03StartupsOptionsButton.Add_Click({
    if ($script:AutoChart03StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart03Startups.Controls.Add($script:AutoChart03StartupsManipulationPanel)
    }
    elseif ($script:AutoChart03StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart03Startups.Controls.Remove($script:AutoChart03StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03Startups)

$script:AutoChart03StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03StartupsOverallDataResults.count))
    $script:AutoChart03StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03StartupsTrimOffFirstTrackBarValue = $script:AutoChart03StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart03StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart03Startups.Series["Paths"].Points.Clear()
        $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
    $script:AutoChart03StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart03StartupsTrimOffFirstTrackBar)
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart03StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03StartupsOverallDataResults.count))
    $script:AutoChart03StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart03StartupsOverallDataResults.count)
    $script:AutoChart03StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart03StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03StartupsTrimOffLastTrackBarValue = $($script:AutoChart03StartupsOverallDataResults.count) - $script:AutoChart03StartupsTrimOffLastTrackBar.Value
        $script:AutoChart03StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03StartupsOverallDataResults.count) - $script:AutoChart03StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart03Startups.Series["Paths"].Points.Clear()
        $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
$script:AutoChart03StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart03StartupsTrimOffLastTrackBar)
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart03StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Startups.Series["Paths"].ChartType = $script:AutoChart03StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart03Startups.Series["Paths"].Points.Clear()
#    $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
})
$script:AutoChart03StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03StartupsChartTypesAvailable) { $script:AutoChart03StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03StartupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03StartupsChartTypeComboBox.Location.X + $script:AutoChart03StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03Startups3DToggleButton
$script:AutoChart03Startups3DInclination = 0
$script:AutoChart03Startups3DToggleButton.Add_Click({
    $script:AutoChart03Startups3DInclination += 10
    if ( $script:AutoChart03Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03StartupsArea.Area3DStyle.Inclination = $script:AutoChart03Startups3DInclination
        $script:AutoChart03Startups3DToggleButton.Text  = "3D On ($script:AutoChart03Startups3DInclination)"
#        $script:AutoChart03Startups.Series["Paths"].Points.Clear()
#        $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03Startups3DInclination -le 90 ) {
        $script:AutoChart03StartupsArea.Area3DStyle.Inclination = $script:AutoChart03Startups3DInclination
        $script:AutoChart03Startups3DToggleButton.Text  = "3D On ($script:AutoChart03Startups3DInclination)"
#        $script:AutoChart03Startups.Series["Paths"].Points.Clear()
#        $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart03Startups3DInclination = 0
        $script:AutoChart03StartupsArea.Area3DStyle.Inclination = $script:AutoChart03Startups3DInclination
        $script:AutoChart03StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03Startups.Series["Paths"].Points.Clear()
#        $script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
})
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart03StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03Startups3DToggleButton.Location.X + $script:AutoChart03Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03StartupsColorsAvailable) { $script:AutoChart03StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Startups.Series["Paths"].Color = $script:AutoChart03StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03StartupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart03StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Path' -eq $($script:AutoChart03StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart03StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03StartupsImportCsvPosResults) { $script:AutoChart03StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart03StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart03StartupsImportCsvPosResults) { $script:AutoChart03StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03StartupsImportCsvNegResults) { $script:AutoChart03StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03StartupsImportCsvPosResults.count))"
    $script:AutoChart03StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart03StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03StartupsCheckDiffButton
$script:AutoChart03StartupsCheckDiffButton.Add_Click({
    $script:AutoChart03StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Path' -ExpandProperty 'Path' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart03StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03StartupsInvestDiffDropDownArray) { $script:AutoChart03StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03Startups }})
    $script:AutoChart03StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart03StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart03StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03StartupsInvestDiffExecuteButton
    $script:AutoChart03StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03Startups }})
    $script:AutoChart03StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart03StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart03StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart03StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart03StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart03StartupsInvestDiffDropDownLabel,$script:AutoChart03StartupsInvestDiffDropDownComboBox,$script:AutoChart03StartupsInvestDiffExecuteButton,$script:AutoChart03StartupsInvestDiffPosResultsLabel,$script:AutoChart03StartupsInvestDiffPosResultsTextBox,$script:AutoChart03StartupsInvestDiffNegResultsLabel,$script:AutoChart03StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart03StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart03StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03StartupsManipulationPanel.controls.Add($script:AutoChart03StartupsCheckDiffButton)


$AutoChart03StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03StartupsCheckDiffButton.Location.X + $script:AutoChart03StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "Paths" -PropertyX "Path" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart03StartupsExpandChartButton
$script:AutoChart03StartupsManipulationPanel.Controls.Add($AutoChart03StartupsExpandChartButton)


$script:AutoChart03StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart03StartupsCheckDiffButton.Location.Y + $script:AutoChart03StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03StartupsOpenInShell
$script:AutoChart03StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03StartupsManipulationPanel.controls.Add($script:AutoChart03StartupsOpenInShell)


$script:AutoChart03StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03StartupsOpenInShell.Location.X + $script:AutoChart03StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03StartupsViewResults
$script:AutoChart03StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03StartupsManipulationPanel.controls.Add($script:AutoChart03StartupsViewResults)


### Save the chart to file
$script:AutoChart03StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03StartupsOpenInShell.Location.X
                  Y = $script:AutoChart03StartupsOpenInShell.Location.Y + $script:AutoChart03StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03Startups -Title $script:AutoChart03StartupsTitle
})
$script:AutoChart03StartupsManipulationPanel.controls.Add($script:AutoChart03StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03StartupsSaveButton.Location.X
                        Y = $script:AutoChart03StartupsSaveButton.Location.Y + $script:AutoChart03StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03StartupsManipulationPanel.Controls.Add($script:AutoChart03StartupsNoticeTextbox)

$script:AutoChart03Startups.Series["Paths"].Points.Clear()
$script:AutoChart03StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Startups.Series["Paths"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}





















##############################################################################################
# AutoChart04Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02Startups.Location.X
                  Y = $script:AutoChart02Startups.Location.Y + $script:AutoChart02Startups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04Startups.Titles.Add($script:AutoChart04StartupsTitle)

### Create Charts Area
$script:AutoChart04StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04StartupsArea.Name        = 'Chart Area'
$script:AutoChart04StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart04StartupsArea.AxisX.Interval          = 1
$script:AutoChart04StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart04Startups.ChartAreas.Add($script:AutoChart04StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04Startups.Series.Add("Location")
$script:AutoChart04Startups.Series["Location"].Enabled           = $True
$script:AutoChart04Startups.Series["Location"].BorderWidth       = 1
$script:AutoChart04Startups.Series["Location"].IsVisibleInLegend = $false
$script:AutoChart04Startups.Series["Location"].Chartarea         = 'Chart Area'
$script:AutoChart04Startups.Series["Location"].Legend            = 'Legend'
$script:AutoChart04Startups.Series["Location"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04Startups.Series["Location"]['PieLineColor']   = 'Black'
$script:AutoChart04Startups.Series["Location"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04Startups.Series["Location"].ChartType         = 'Column'
$script:AutoChart04Startups.Series["Location"].Color             = 'Orange'

        function Generate-AutoChart04Startups {
            $script:AutoChart04StartupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart04StartupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Location' | Sort-Object -Property 'Location' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04StartupsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04Startups.Series["Location"].Points.Clear()

            if ($script:AutoChart04StartupsUniqueDataFields.count -gt 0){
                $script:AutoChart04StartupsTitle.ForeColor = 'Black'
                $script:AutoChart04StartupsTitle.Text = "Location"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart04StartupsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04StartupsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04StartupsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Location) -eq $DataField.Location) {
                            $Count += 1
                            if ( $script:AutoChart04StartupsCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart04StartupsCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart04StartupsUniqueCount = $script:AutoChart04StartupsCsvComputers.Count
                    $script:AutoChart04StartupsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04StartupsUniqueCount
                        Computers   = $script:AutoChart04StartupsCsvComputers
                    }
                    $script:AutoChart04StartupsOverallDataResults += $script:AutoChart04StartupsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount) }

                $script:AutoChart04StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04StartupsOverallDataResults.count))
                $script:AutoChart04StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04StartupsOverallDataResults.count))
            }
            else {
                $script:AutoChart04StartupsTitle.ForeColor = 'Red'
                $script:AutoChart04StartupsTitle.Text = "Location`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04Startups

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04StartupsOptionsButton
$script:AutoChart04StartupsOptionsButton.Add_Click({
    if ($script:AutoChart04StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart04Startups.Controls.Add($script:AutoChart04StartupsManipulationPanel)
    }
    elseif ($script:AutoChart04StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart04Startups.Controls.Remove($script:AutoChart04StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04Startups)

$script:AutoChart04StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04StartupsOverallDataResults.count))
    $script:AutoChart04StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04StartupsTrimOffFirstTrackBarValue = $script:AutoChart04StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart04StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart04Startups.Series["Location"].Points.Clear()
        $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
    })
    $script:AutoChart04StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart04StartupsTrimOffFirstTrackBar)
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart04StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04StartupsOverallDataResults.count))
    $script:AutoChart04StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart04StartupsOverallDataResults.count)
    $script:AutoChart04StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart04StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04StartupsTrimOffLastTrackBarValue = $($script:AutoChart04StartupsOverallDataResults.count) - $script:AutoChart04StartupsTrimOffLastTrackBar.Value
        $script:AutoChart04StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04StartupsOverallDataResults.count) - $script:AutoChart04StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart04Startups.Series["Location"].Points.Clear()
        $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
    })
$script:AutoChart04StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart04StartupsTrimOffLastTrackBar)
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart04StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Startups.Series["Location"].ChartType = $script:AutoChart04StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart04Startups.Series["Location"].Points.Clear()
#    $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
})
$script:AutoChart04StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04StartupsChartTypesAvailable) { $script:AutoChart04StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04StartupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04StartupsChartTypeComboBox.Location.X + $script:AutoChart04StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04Startups3DToggleButton
$script:AutoChart04Startups3DInclination = 0
$script:AutoChart04Startups3DToggleButton.Add_Click({
    $script:AutoChart04Startups3DInclination += 10
    if ( $script:AutoChart04Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04StartupsArea.Area3DStyle.Inclination = $script:AutoChart04Startups3DInclination
        $script:AutoChart04Startups3DToggleButton.Text  = "3D On ($script:AutoChart04Startups3DInclination)"
#        $script:AutoChart04Startups.Series["Location"].Points.Clear()
#        $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04Startups3DInclination -le 90 ) {
        $script:AutoChart04StartupsArea.Area3DStyle.Inclination = $script:AutoChart04Startups3DInclination
        $script:AutoChart04Startups3DToggleButton.Text  = "3D On ($script:AutoChart04Startups3DInclination)"
#        $script:AutoChart04Startups.Series["Location"].Points.Clear()
#        $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart04Startups3DInclination = 0
        $script:AutoChart04StartupsArea.Area3DStyle.Inclination = $script:AutoChart04Startups3DInclination
        $script:AutoChart04StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04Startups.Series["Location"].Points.Clear()
#        $script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
    }
})
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart04StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04Startups3DToggleButton.Location.X + $script:AutoChart04Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04StartupsColorsAvailable) { $script:AutoChart04StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Startups.Series["Location"].Color = $script:AutoChart04StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04StartupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart04StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Location' -eq $($script:AutoChart04StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart04StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04StartupsImportCsvPosResults) { $script:AutoChart04StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart04StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart04StartupsImportCsvPosResults) { $script:AutoChart04StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04StartupsImportCsvNegResults) { $script:AutoChart04StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04StartupsImportCsvPosResults.count))"
    $script:AutoChart04StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart04StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04StartupsCheckDiffButton
$script:AutoChart04StartupsCheckDiffButton.Add_Click({
    $script:AutoChart04StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Location' -ExpandProperty 'Location' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart04StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04StartupsInvestDiffDropDownArray) { $script:AutoChart04StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04Startups }})
    $script:AutoChart04StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart04StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart04StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04StartupsInvestDiffExecuteButton
    $script:AutoChart04StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04Startups }})
    $script:AutoChart04StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart04StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart04StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart04StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart04StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart04StartupsInvestDiffDropDownLabel,$script:AutoChart04StartupsInvestDiffDropDownComboBox,$script:AutoChart04StartupsInvestDiffExecuteButton,$script:AutoChart04StartupsInvestDiffPosResultsLabel,$script:AutoChart04StartupsInvestDiffPosResultsTextBox,$script:AutoChart04StartupsInvestDiffNegResultsLabel,$script:AutoChart04StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart04StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart04StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04StartupsManipulationPanel.controls.Add($script:AutoChart04StartupsCheckDiffButton)


$AutoChart04StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04StartupsCheckDiffButton.Location.X + $script:AutoChart04StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "Location" -PropertyX "Location" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart04StartupsExpandChartButton
$script:AutoChart04StartupsManipulationPanel.Controls.Add($AutoChart04StartupsExpandChartButton)


$script:AutoChart04StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart04StartupsCheckDiffButton.Location.Y + $script:AutoChart04StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04StartupsOpenInShell
$script:AutoChart04StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04StartupsManipulationPanel.controls.Add($script:AutoChart04StartupsOpenInShell)


$script:AutoChart04StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04StartupsOpenInShell.Location.X + $script:AutoChart04StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04StartupsViewResults
$script:AutoChart04StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04StartupsManipulationPanel.controls.Add($script:AutoChart04StartupsViewResults)


### Save the chart to file
$script:AutoChart04StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04StartupsOpenInShell.Location.X
                  Y = $script:AutoChart04StartupsOpenInShell.Location.Y + $script:AutoChart04StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04Startups -Title $script:AutoChart04StartupsTitle
})
$script:AutoChart04StartupsManipulationPanel.controls.Add($script:AutoChart04StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04StartupsSaveButton.Location.X
                        Y = $script:AutoChart04StartupsSaveButton.Location.Y + $script:AutoChart04StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04StartupsManipulationPanel.Controls.Add($script:AutoChart04StartupsNoticeTextbox)

$script:AutoChart04Startups.Series["Location"].Points.Clear()
$script:AutoChart04StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Startups.Series["Location"].Points.AddXY($_.DataField.Location,$_.UniqueCount)}
























##############################################################################################
# AutoChart05Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03Startups.Location.X
                  Y = $script:AutoChart03Startups.Location.Y + $script:AutoChart03Startups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05Startups.Titles.Add($script:AutoChart05StartupsTitle)

### Create Charts Area
$script:AutoChart05StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05StartupsArea.Name        = 'Chart Area'
$script:AutoChart05StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart05StartupsArea.AxisX.Interval          = 1
$script:AutoChart05StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart05Startups.ChartAreas.Add($script:AutoChart05StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05Startups.Series.Add("Command")
$script:AutoChart05Startups.Series["Command"].Enabled           = $True
$script:AutoChart05Startups.Series["Command"].BorderWidth       = 1
$script:AutoChart05Startups.Series["Command"].IsVisibleInLegend = $false
$script:AutoChart05Startups.Series["Command"].Chartarea         = 'Chart Area'
$script:AutoChart05Startups.Series["Command"].Legend            = 'Legend'
$script:AutoChart05Startups.Series["Command"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05Startups.Series["Command"]['PieLineColor']   = 'Black'
$script:AutoChart05Startups.Series["Command"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05Startups.Series["Command"].ChartType         = 'Column'
$script:AutoChart05Startups.Series["Command"].Color             = 'Brown'



function Generate-AutoChart05Startups {
    $script:AutoChart05StartupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart05StartupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Command' | Sort-Object -Property 'Command' -Unique

    $script:AutoChartsProgressBar.ForeColor = 'Orange'
    $script:AutoChartsProgressBar.Minimum = 0
    $script:AutoChartsProgressBar.Maximum = $script:AutoChart05StartupsUniqueDataFields.count
    $script:AutoChartsProgressBar.Value   = 0
    $script:AutoChartsProgressBar.Update()

    $script:AutoChart05Startups.Series["Command"].Points.Clear()

    if ($script:AutoChart05StartupsUniqueDataFields.count -gt 0){
        $script:AutoChart05StartupsTitle.ForeColor = 'Black'
        $script:AutoChart05StartupsTitle.Text = "Command"

        # If the Second field/Y Axis equals ComputerName, it counts it
        $script:AutoChart05StartupsOverallDataResults = @()

        # Generates and Counts the data - Counts the number of times that any given property possess a given value
        foreach ($DataField in $script:AutoChart05StartupsUniqueDataFields) {
            $Count        = 0
            $script:AutoChart05StartupsCsvComputers = @()
            foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                if ($($Line.Command) -eq $DataField.Command) {
                    $Count += 1
                    if ( $script:AutoChart05StartupsCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart05StartupsCsvComputers += $($Line.ComputerName) }
                }
            }
            $script:AutoChart05StartupsUniqueCount = $script:AutoChart05StartupsCsvComputers.Count
            $script:AutoChart05StartupsDataResults = New-Object PSObject -Property @{
                DataField   = $DataField
                TotalCount  = $Count
                UniqueCount = $script:AutoChart05StartupsUniqueCount
                Computers   = $script:AutoChart05StartupsCsvComputers
            }
            $script:AutoChart05StartupsOverallDataResults += $script:AutoChart05StartupsDataResults
            $script:AutoChartsProgressBar.Value += 1
            $script:AutoChartsProgressBar.Update()
        }
        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Command,$_.UniqueCount) }

        $script:AutoChart05StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05StartupsOverallDataResults.count))
        $script:AutoChart05StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05StartupsOverallDataResults.count))
    }
    else {
        $script:AutoChart05StartupsTitle.ForeColor = 'Red'
        $script:AutoChart05StartupsTitle.Text = "Command`n
[ No Data Available ]`n"
    }
}
Generate-AutoChart05Startups



### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05StartupsOptionsButton
$script:AutoChart05StartupsOptionsButton.Add_Click({
    if ($script:AutoChart05StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart05Startups.Controls.Add($script:AutoChart05StartupsManipulationPanel)
    }
    elseif ($script:AutoChart05StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart05Startups.Controls.Remove($script:AutoChart05StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05Startups)

$script:AutoChart05StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05StartupsOverallDataResults.count))
    $script:AutoChart05StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05StartupsTrimOffFirstTrackBarValue = $script:AutoChart05StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart05StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart05Startups.Series["Command"].Points.Clear()
        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart05StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart05StartupsTrimOffFirstTrackBar)
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart05StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05StartupsOverallDataResults.count))
    $script:AutoChart05StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart05StartupsOverallDataResults.count)
    $script:AutoChart05StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart05StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05StartupsTrimOffLastTrackBarValue = $($script:AutoChart05StartupsOverallDataResults.count) - $script:AutoChart05StartupsTrimOffLastTrackBar.Value
        $script:AutoChart05StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05StartupsOverallDataResults.count) - $script:AutoChart05StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart05Startups.Series["Command"].Points.Clear()
        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart05StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart05StartupsTrimOffLastTrackBar)
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart05StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Startups.Series["Command"].ChartType = $script:AutoChart05StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart05Startups.Series["Command"].Points.Clear()
#    $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart05StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05StartupsChartTypesAvailable) { $script:AutoChart05StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05StartupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05StartupsChartTypeComboBox.Location.X + $script:AutoChart05StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05Startups3DToggleButton
$script:AutoChart05Startups3DInclination = 0
$script:AutoChart05Startups3DToggleButton.Add_Click({
    $script:AutoChart05Startups3DInclination += 10
    if ( $script:AutoChart05Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05StartupsArea.Area3DStyle.Inclination = $script:AutoChart05Startups3DInclination
        $script:AutoChart05Startups3DToggleButton.Text  = "3D On ($script:AutoChart05Startups3DInclination)"
#        $script:AutoChart05Startups.Series["Command"].Points.Clear()
#        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05Startups3DInclination -le 90 ) {
        $script:AutoChart05StartupsArea.Area3DStyle.Inclination = $script:AutoChart05Startups3DInclination
        $script:AutoChart05Startups3DToggleButton.Text  = "3D On ($script:AutoChart05Startups3DInclination)"
#        $script:AutoChart05Startups.Series["Command"].Points.Clear()
#        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart05Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart05Startups3DInclination = 0
        $script:AutoChart05StartupsArea.Area3DStyle.Inclination = $script:AutoChart05Startups3DInclination
        $script:AutoChart05StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05Startups.Series["Command"].Points.Clear()
#        $script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart05StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05Startups3DToggleButton.Location.X + $script:AutoChart05Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05StartupsColorsAvailable) { $script:AutoChart05StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Startups.Series["Command"].Color = $script:AutoChart05StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05StartupsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart05StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart05StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart05StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05StartupsImportCsvPosResults) { $script:AutoChart05StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart05StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart05StartupsImportCsvPosResults) { $script:AutoChart05StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05StartupsImportCsvNegResults) { $script:AutoChart05StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05StartupsImportCsvPosResults.count))"
    $script:AutoChart05StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart05StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05StartupsCheckDiffButton
$script:AutoChart05StartupsCheckDiffButton.Add_Click({
    $script:AutoChart05StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart05StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05StartupsInvestDiffDropDownArray) { $script:AutoChart05StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05Startups }})
    $script:AutoChart05StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart05StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart05StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05StartupsInvestDiffExecuteButton
    $script:AutoChart05StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05Startups }})
    $script:AutoChart05StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart05StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart05StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart05StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart05StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart05StartupsInvestDiffDropDownLabel,$script:AutoChart05StartupsInvestDiffDropDownComboBox,$script:AutoChart05StartupsInvestDiffExecuteButton,$script:AutoChart05StartupsInvestDiffPosResultsLabel,$script:AutoChart05StartupsInvestDiffPosResultsTextBox,$script:AutoChart05StartupsInvestDiffNegResultsLabel,$script:AutoChart05StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart05StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart05StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05StartupsManipulationPanel.controls.Add($script:AutoChart05StartupsCheckDiffButton)


$AutoChart05StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05StartupsCheckDiffButton.Location.X + $script:AutoChart05StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "Command" -PropertyX "Command" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart05StartupsExpandChartButton
$script:AutoChart05StartupsManipulationPanel.Controls.Add($AutoChart05StartupsExpandChartButton)


$script:AutoChart05StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart05StartupsCheckDiffButton.Location.Y + $script:AutoChart05StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05StartupsOpenInShell
$script:AutoChart05StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05StartupsManipulationPanel.controls.Add($script:AutoChart05StartupsOpenInShell)


$script:AutoChart05StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05StartupsOpenInShell.Location.X + $script:AutoChart05StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05StartupsViewResults
$script:AutoChart05StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05StartupsManipulationPanel.controls.Add($script:AutoChart05StartupsViewResults)


### Save the chart to file
$script:AutoChart05StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05StartupsOpenInShell.Location.X
                  Y = $script:AutoChart05StartupsOpenInShell.Location.Y + $script:AutoChart05StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05Startups -Title $script:AutoChart05StartupsTitle
})
$script:AutoChart05StartupsManipulationPanel.controls.Add($script:AutoChart05StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05StartupsSaveButton.Location.X
                        Y = $script:AutoChart05StartupsSaveButton.Location.Y + $script:AutoChart05StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05StartupsManipulationPanel.Controls.Add($script:AutoChart05StartupsNoticeTextbox)

$script:AutoChart05Startups.Series["Command"].Points.Clear()
$script:AutoChart05StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Startups.Series["Command"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}























##############################################################################################
# AutoChart06Startups
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06Startups = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04Startups.Location.X
                  Y = $script:AutoChart04Startups.Location.Y + $script:AutoChart04Startups.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06Startups.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06StartupsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06Startups.Titles.Add($script:AutoChart06StartupsTitle)

### Create Charts Area
$script:AutoChart06StartupsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06StartupsArea.Name        = 'Chart Area'
$script:AutoChart06StartupsArea.AxisX.Title = 'Hosts'
$script:AutoChart06StartupsArea.AxisX.Interval          = 1
$script:AutoChart06StartupsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06StartupsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06StartupsArea.Area3DStyle.Inclination = 75
$script:AutoChart06Startups.ChartAreas.Add($script:AutoChart06StartupsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06Startups.Series.Add("User")
$script:AutoChart06Startups.Series["User"].Enabled           = $True
$script:AutoChart06Startups.Series["User"].BorderWidth       = 1
$script:AutoChart06Startups.Series["User"].IsVisibleInLegend = $false
$script:AutoChart06Startups.Series["User"].Chartarea         = 'Chart Area'
$script:AutoChart06Startups.Series["User"].Legend            = 'Legend'
$script:AutoChart06Startups.Series["User"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06Startups.Series["User"]['PieLineColor']   = 'Black'
$script:AutoChart06Startups.Series["User"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06Startups.Series["User"].ChartType         = 'Column'
$script:AutoChart06Startups.Series["User"].Color             = 'Gray'




function Generate-AutoChart06Startups {
    $script:AutoChart06StartupsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart06StartupsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'User' | Sort-Object -Property 'User' -Unique

    $script:AutoChartsProgressBar.ForeColor = 'Orange'
    $script:AutoChartsProgressBar.Minimum = 0
    $script:AutoChartsProgressBar.Maximum = $script:AutoChart06StartupsUniqueDataFields.count
    $script:AutoChartsProgressBar.Value   = 0
    $script:AutoChartsProgressBar.Update()

    $script:AutoChart06Startups.Series["User"].Points.Clear()

    if ($script:AutoChart06StartupsUniqueDataFields.count -gt 0){
        $script:AutoChart06StartupsTitle.ForeColor = 'Black'
        $script:AutoChart06StartupsTitle.Text = "User"

        # If the Second field/Y Axis equals ComputerName, it counts it
        $script:AutoChart06StartupsOverallDataResults = @()

        # Generates and Counts the data - Counts the number of times that any given property possess a given value
        foreach ($DataField in $script:AutoChart06StartupsUniqueDataFields) {
            $Count        = 0
            $script:AutoChart06StartupsCsvComputers = @()
            foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                if ($($Line.User) -eq $DataField.User) {
                    $Count += 1
                    if ( $script:AutoChart06StartupsCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart06StartupsCsvComputers += $($Line.ComputerName) }
                }
            }
            $script:AutoChart06StartupsUniqueCount = $script:AutoChart06StartupsCsvComputers.Count
            $script:AutoChart06StartupsDataResults = New-Object PSObject -Property @{
                DataField   = $DataField
                TotalCount  = $Count
                UniqueCount = $script:AutoChart06StartupsUniqueCount
                Computers   = $script:AutoChart06StartupsCsvComputers
            }
            $script:AutoChart06StartupsOverallDataResults += $script:AutoChart06StartupsDataResults
            $script:AutoChartsProgressBar.Value += 1
            $script:AutoChartsProgressBar.Update()
        }
        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount) }

        $script:AutoChart06StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06StartupsOverallDataResults.count))
        $script:AutoChart06StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06StartupsOverallDataResults.count))
    }
    else {
        $script:AutoChart06StartupsTitle.ForeColor = 'Red'
        $script:AutoChart06StartupsTitle.Text = "User`n
[ No Data Available ]`n"
    }
}
Generate-AutoChart06Startups




### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06StartupsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06Startups.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06Startups.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06StartupsOptionsButton
$script:AutoChart06StartupsOptionsButton.Add_Click({
    if ($script:AutoChart06StartupsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06StartupsOptionsButton.Text = 'Options ^'
        $script:AutoChart06Startups.Controls.Add($script:AutoChart06StartupsManipulationPanel)
    }
    elseif ($script:AutoChart06StartupsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06StartupsOptionsButton.Text = 'Options v'
        $script:AutoChart06Startups.Controls.Remove($script:AutoChart06StartupsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06StartupsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06Startups)

$script:AutoChart06StartupsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06Startups.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06Startups.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06StartupsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06StartupsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06StartupsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06StartupsOverallDataResults.count))
    $script:AutoChart06StartupsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06StartupsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06StartupsTrimOffFirstTrackBarValue = $script:AutoChart06StartupsTrimOffFirstTrackBar.Value
        $script:AutoChart06StartupsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06StartupsTrimOffFirstTrackBar.Value)"
        $script:AutoChart06Startups.Series["User"].Points.Clear()
        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
    })
    $script:AutoChart06StartupsTrimOffFirstGroupBox.Controls.Add($script:AutoChart06StartupsTrimOffFirstTrackBar)
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06StartupsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06StartupsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06StartupsTrimOffFirstGroupBox.Location.X + $script:AutoChart06StartupsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06StartupsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06StartupsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06StartupsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06StartupsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06StartupsOverallDataResults.count))
    $script:AutoChart06StartupsTrimOffLastTrackBar.Value         = $($script:AutoChart06StartupsOverallDataResults.count)
    $script:AutoChart06StartupsTrimOffLastTrackBarValue   = 0
    $script:AutoChart06StartupsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06StartupsTrimOffLastTrackBarValue = $($script:AutoChart06StartupsOverallDataResults.count) - $script:AutoChart06StartupsTrimOffLastTrackBar.Value
        $script:AutoChart06StartupsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06StartupsOverallDataResults.count) - $script:AutoChart06StartupsTrimOffLastTrackBar.Value)"
        $script:AutoChart06Startups.Series["User"].Points.Clear()
        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
    })
$script:AutoChart06StartupsTrimOffLastGroupBox.Controls.Add($script:AutoChart06StartupsTrimOffLastTrackBar)
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06StartupsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06StartupsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06StartupsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06StartupsTrimOffFirstGroupBox.Location.Y + $script:AutoChart06StartupsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06StartupsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Startups.Series["User"].ChartType = $script:AutoChart06StartupsChartTypeComboBox.SelectedItem
#    $script:AutoChart06Startups.Series["User"].Points.Clear()
#    $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
})
$script:AutoChart06StartupsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06StartupsChartTypesAvailable) { $script:AutoChart06StartupsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06StartupsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06Startups3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06StartupsChartTypeComboBox.Location.X + $script:AutoChart06StartupsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06StartupsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06Startups3DToggleButton
$script:AutoChart06Startups3DInclination = 0
$script:AutoChart06Startups3DToggleButton.Add_Click({
    $script:AutoChart06Startups3DInclination += 10
    if ( $script:AutoChart06Startups3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06StartupsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06StartupsArea.Area3DStyle.Inclination = $script:AutoChart06Startups3DInclination
        $script:AutoChart06Startups3DToggleButton.Text  = "3D On ($script:AutoChart06Startups3DInclination)"
#        $script:AutoChart06Startups.Series["User"].Points.Clear()
#        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06Startups3DInclination -le 90 ) {
        $script:AutoChart06StartupsArea.Area3DStyle.Inclination = $script:AutoChart06Startups3DInclination
        $script:AutoChart06Startups3DToggleButton.Text  = "3D On ($script:AutoChart06Startups3DInclination)"
#        $script:AutoChart06Startups.Series["User"].Points.Clear()
#        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06Startups3DToggleButton.Text  = "3D Off"
        $script:AutoChart06Startups3DInclination = 0
        $script:AutoChart06StartupsArea.Area3DStyle.Inclination = $script:AutoChart06Startups3DInclination
        $script:AutoChart06StartupsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06Startups.Series["User"].Points.Clear()
#        $script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}
    }
})
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06Startups3DToggleButton)

### Change the color of the chart
$script:AutoChart06StartupsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06Startups3DToggleButton.Location.X + $script:AutoChart06Startups3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06Startups3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06StartupsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06StartupsColorsAvailable) { $script:AutoChart06StartupsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06StartupsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Startups.Series["User"].Color = $script:AutoChart06StartupsChangeColorComboBox.SelectedItem
})
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06StartupsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06Startups {
    # List of Positive Endpoints that positively match
    $script:AutoChart06StartupsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'User' -eq $($script:AutoChart06StartupsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart06StartupsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06StartupsImportCsvPosResults) { $script:AutoChart06StartupsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06StartupsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart06StartupsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06StartupsImportCsvAll) { if ($Endpoint -notin $script:AutoChart06StartupsImportCsvPosResults) { $script:AutoChart06StartupsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06StartupsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06StartupsImportCsvNegResults) { $script:AutoChart06StartupsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06StartupsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06StartupsImportCsvPosResults.count))"
    $script:AutoChart06StartupsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06StartupsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06StartupsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06StartupsTrimOffLastGroupBox.Location.X + $script:AutoChart06StartupsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06StartupsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06StartupsCheckDiffButton
$script:AutoChart06StartupsCheckDiffButton.Add_Click({
    $script:AutoChart06StartupsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'User' -ExpandProperty 'User' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06StartupsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06StartupsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06StartupsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06StartupsInvestDiffDropDownLabel.Location.y + $script:AutoChart06StartupsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06StartupsInvestDiffDropDownArray) { $script:AutoChart06StartupsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06StartupsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06Startups }})
    $script:AutoChart06StartupsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06Startups })

    ### Investigate Difference Execute Button
    $script:AutoChart06StartupsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06StartupsInvestDiffDropDownComboBox.Location.y + $script:AutoChart06StartupsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06StartupsInvestDiffExecuteButton
    $script:AutoChart06StartupsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06Startups }})
    $script:AutoChart06StartupsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06Startups })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06StartupsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06StartupsInvestDiffExecuteButton.Location.y + $script:AutoChart06StartupsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06StartupsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06StartupsInvestDiffPosResultsLabel.Location.y + $script:AutoChart06StartupsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06StartupsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06StartupsInvestDiffPosResultsLabel.Location.x + $script:AutoChart06StartupsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06StartupsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06StartupsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06StartupsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06StartupsInvestDiffNegResultsLabel.Location.y + $script:AutoChart06StartupsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06StartupsInvestDiffForm.Controls.AddRange(@($script:AutoChart06StartupsInvestDiffDropDownLabel,$script:AutoChart06StartupsInvestDiffDropDownComboBox,$script:AutoChart06StartupsInvestDiffExecuteButton,$script:AutoChart06StartupsInvestDiffPosResultsLabel,$script:AutoChart06StartupsInvestDiffPosResultsTextBox,$script:AutoChart06StartupsInvestDiffNegResultsLabel,$script:AutoChart06StartupsInvestDiffNegResultsTextBox))
    $script:AutoChart06StartupsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06StartupsInvestDiffForm.ShowDialog()
})
$script:AutoChart06StartupsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06StartupsManipulationPanel.controls.Add($script:AutoChart06StartupsCheckDiffButton)


$AutoChart06StartupsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06StartupsCheckDiffButton.Location.X + $script:AutoChart06StartupsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06StartupsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "StartupCommand" -QueryTabName "User" -PropertyX "User" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart06StartupsExpandChartButton
$script:AutoChart06StartupsManipulationPanel.Controls.Add($AutoChart06StartupsExpandChartButton)


$script:AutoChart06StartupsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06StartupsCheckDiffButton.Location.X
                   Y = $script:AutoChart06StartupsCheckDiffButton.Location.Y + $script:AutoChart06StartupsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06StartupsOpenInShell
$script:AutoChart06StartupsOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06StartupsManipulationPanel.controls.Add($script:AutoChart06StartupsOpenInShell)


$script:AutoChart06StartupsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06StartupsOpenInShell.Location.X + $script:AutoChart06StartupsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06StartupsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06StartupsViewResults
$script:AutoChart06StartupsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06StartupsManipulationPanel.controls.Add($script:AutoChart06StartupsViewResults)


### Save the chart to file
$script:AutoChart06StartupsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06StartupsOpenInShell.Location.X
                  Y = $script:AutoChart06StartupsOpenInShell.Location.Y + $script:AutoChart06StartupsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06StartupsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06StartupsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06Startups -Title $script:AutoChart06StartupsTitle
})
$script:AutoChart06StartupsManipulationPanel.controls.Add($script:AutoChart06StartupsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06StartupsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06StartupsSaveButton.Location.X
                        Y = $script:AutoChart06StartupsSaveButton.Location.Y + $script:AutoChart06StartupsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06StartupsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06StartupsManipulationPanel.Controls.Add($script:AutoChart06StartupsNoticeTextbox)

$script:AutoChart06Startups.Series["User"].Points.Clear()
$script:AutoChart06StartupsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06StartupsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06StartupsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Startups.Series["User"].Points.AddXY($_.DataField.User,$_.UniqueCount)}











