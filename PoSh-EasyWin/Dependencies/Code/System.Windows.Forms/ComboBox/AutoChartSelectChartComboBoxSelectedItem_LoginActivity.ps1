$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Login Activity'
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

$script:AutoChart01LoginActivityCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Current Login Activity') { $script:AutoChart01LoginActivityCSVFileMatch += $CSVFile } }
} 

$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01LoginActivityCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart01LoginActivity.Controls.Remove($script:AutoChart01LoginActivityManipulationPanel)
    $script:AutoChart02LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart02LoginActivity.Controls.Remove($script:AutoChart02LoginActivityManipulationPanel)
    $script:AutoChart03LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart03LoginActivity.Controls.Remove($script:AutoChart03LoginActivityManipulationPanel)
    $script:AutoChart04LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart04LoginActivity.Controls.Remove($script:AutoChart04LoginActivityManipulationPanel)
    $script:AutoChart05LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart05LoginActivity.Controls.Remove($script:AutoChart05LoginActivityManipulationPanel)
    $script:AutoChart06LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart06LoginActivity.Controls.Remove($script:AutoChart06LoginActivityManipulationPanel)
    $script:AutoChart07LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart07LoginActivity.Controls.Remove($script:AutoChart07LoginActivityManipulationPanel)
    $script:AutoChart08LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart08LoginActivity.Controls.Remove($script:AutoChart08LoginActivityManipulationPanel)
    $script:AutoChart09LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart09LoginActivity.Controls.Remove($script:AutoChart09LoginActivityManipulationPanel)
    $script:AutoChart10LoginActivityOptionsButton.Text = 'Options v'
    $script:AutoChart10LoginActivity.Controls.Remove($script:AutoChart10LoginActivityManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Login Activity'
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
        $ChartComputerList = $script:AutoChartDataSourceCsv.PSComputerName | Sort-Object -Unique

        if ($ChartComputerList.count -eq 0) {
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-ACME')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsLoginActivity -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsLoginActivity -ComputerNameList $script:ComputerList }
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
        $AutoChartOpenResultsOpenFileDialog.InitialDirectory = "$(if (Test-ProfileLoaded $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
        $AutoChartOpenResultsOpenFileDialog.filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
        $AutoChartOpenResultsOpenFileDialog.ShowDialog() | Out-Null
        $AutoChartOpenResultsOpenFileDialog.ShowHelp = $true
        $script:AutoChartOpenResultsOpenFileDialogfilename = $AutoChartOpenResultsOpenFileDialog.filename
        $script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartOpenResultsOpenFileDialogfilename
    
        $script:AutoChartDataSourceCsvFileName = $AutoChartOpenResultsOpenFileDialog.filename
    }

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
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartsMainLabel01)

<#
$AutoChartPullNewDataEnrichedCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Enriched (Slower)'
    Left    = $AutoChartPullNewDataButton.Left
    Top     = $AutoChartPullNewDataButton.Top + $AutoChartPullNewDataButton.Height
    Width   = $FormScale * 125
    Height  = $FormScale * 22
    Checked = $true
}
$script:AutoChartsIndividualTab01.Controls.Add($AutoChartPullNewDataEnrichedCheckBox)
#>



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
$script:AutoChart01LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart01LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01LoginActivity.Titles.Add($script:AutoChart01LoginActivityTitle)

### Create Charts Area
$script:AutoChart01LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart01LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart01LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart01LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart01LoginActivity.ChartAreas.Add($script:AutoChart01LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01LoginActivity.Series.Add("Owner")
$script:AutoChart01LoginActivity.Series["Owner"].Enabled           = $True
$script:AutoChart01LoginActivity.Series["Owner"].BorderWidth       = 1
$script:AutoChart01LoginActivity.Series["Owner"].IsVisibleInLegend = $false
$script:AutoChart01LoginActivity.Series["Owner"].Chartarea         = 'Chart Area'
$script:AutoChart01LoginActivity.Series["Owner"].Legend            = 'Legend'
$script:AutoChart01LoginActivity.Series["Owner"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01LoginActivity.Series["Owner"]['PieLineColor']   = 'Black'
$script:AutoChart01LoginActivity.Series["Owner"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01LoginActivity.Series["Owner"].ChartType         = 'Column'
$script:AutoChart01LoginActivity.Series["Owner"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Owner' | Sort-Object -Property 'Owner' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()

            if ($script:AutoChart01LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart01LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart01LoginActivityTitle.Text = "Owner"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Owner) -eq $DataField.Owner) {
                            $Count += 1
                            if ( $script:AutoChart01LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01LoginActivityCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01LoginActivityUniqueCount = $script:AutoChart01LoginActivityCsvComputers.Count
                    $script:AutoChart01LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01LoginActivityUniqueCount
                        Computers   = $script:AutoChart01LoginActivityCsvComputers 
                    }
                    $script:AutoChart01LoginActivityOverallDataResults += $script:AutoChart01LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01LoginActivityOverallDataResults.count))
                $script:AutoChart01LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart01LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart01LoginActivityTitle.Text = "Owner`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart01LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01LoginActivityOptionsButton
$script:AutoChart01LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart01LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart01LoginActivity.Controls.Add($script:AutoChart01LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart01LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart01LoginActivity.Controls.Remove($script:AutoChart01LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01LoginActivity)

$script:AutoChart01LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01LoginActivityOverallDataResults.count))                
    $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart01LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
        $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    })
    $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart01LoginActivityTrimOffFirstTrackBar)
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01LoginActivityOverallDataResults.count))
    $script:AutoChart01LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart01LoginActivityOverallDataResults.count)
    $script:AutoChart01LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart01LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart01LoginActivityOverallDataResults.count) - $script:AutoChart01LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart01LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01LoginActivityOverallDataResults.count) - $script:AutoChart01LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
        $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    })
$script:AutoChart01LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart01LoginActivityTrimOffLastTrackBar)
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart01LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01LoginActivity.Series["Owner"].ChartType = $script:AutoChart01LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
#    $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
})
$script:AutoChart01LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01LoginActivityChartTypesAvailable) { $script:AutoChart01LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivityChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01LoginActivityChartTypeComboBox.Location.X + $script:AutoChart01LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01LoginActivity3DToggleButton
$script:AutoChart01LoginActivity3DInclination = 0
$script:AutoChart01LoginActivity3DToggleButton.Add_Click({
    
    $script:AutoChart01LoginActivity3DInclination += 10
    if ( $script:AutoChart01LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart01LoginActivity3DInclination
        $script:AutoChart01LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart01LoginActivity3DInclination)"
#        $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01LoginActivity3DInclination -le 90 ) {
        $script:AutoChart01LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart01LoginActivity3DInclination
        $script:AutoChart01LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart01LoginActivity3DInclination)" 
#        $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart01LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart01LoginActivity3DInclination = 0
        $script:AutoChart01LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart01LoginActivity3DInclination
        $script:AutoChart01LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
#        $script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}
    }
})
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart01LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01LoginActivity3DToggleButton.Location.X + $script:AutoChart01LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01LoginActivityColorsAvailable) { $script:AutoChart01LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01LoginActivity.Series["Owner"].Color = $script:AutoChart01LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Owner' -eq $($script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01LoginActivityImportCsvPosResults) { $script:AutoChart01LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart01LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart01LoginActivityImportCsvPosResults) { $script:AutoChart01LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01LoginActivityImportCsvNegResults) { $script:AutoChart01LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01LoginActivityImportCsvPosResults.count))"
    $script:AutoChart01LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart01LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01LoginActivityCheckDiffButton
$script:AutoChart01LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart01LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Owner' -ExpandProperty 'Owner' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart01LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01LoginActivityInvestDiffDropDownArray) { $script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart01LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01LoginActivityInvestDiffExecuteButton
    $script:AutoChart01LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart01LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart01LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart01LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart01LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart01LoginActivityInvestDiffDropDownLabel,$script:AutoChart01LoginActivityInvestDiffDropDownComboBox,$script:AutoChart01LoginActivityInvestDiffExecuteButton,$script:AutoChart01LoginActivityInvestDiffPosResultsLabel,$script:AutoChart01LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart01LoginActivityInvestDiffNegResultsLabel,$script:AutoChart01LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart01LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart01LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01LoginActivityManipulationPanel.controls.Add($script:AutoChart01LoginActivityCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01LoginActivityCheckDiffButton.Location.X + $script:AutoChart01LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Owner" -PropertyX "Owner" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart01LoginActivityCheckDiffButton.Location.Y + $script:AutoChart01LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01LoginActivityOpenInShell
$script:AutoChart01LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01LoginActivityManipulationPanel.controls.Add($script:AutoChart01LoginActivityOpenInShell)


$script:AutoChart01LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01LoginActivityOpenInShell.Location.X + $script:AutoChart01LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01LoginActivityViewResults
$script:AutoChart01LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart01LoginActivityManipulationPanel.controls.Add($script:AutoChart01LoginActivityViewResults)


### Save the chart to file
$script:AutoChart01LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart01LoginActivityOpenInShell.Location.Y + $script:AutoChart01LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01LoginActivity -Title $script:AutoChart01LoginActivityTitle
})
$script:AutoChart01LoginActivityManipulationPanel.controls.Add($script:AutoChart01LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart01LoginActivitySaveButton.Location.Y + $script:AutoChart01LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01LoginActivityManipulationPanel.Controls.Add($script:AutoChart01LoginActivityNoticeTextbox)

$script:AutoChart01LoginActivity.Series["Owner"].Points.Clear()
$script:AutoChart01LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01LoginActivity.Series["Owner"].Points.AddXY($_.DataField.Owner,$_.UniqueCount)}























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01LoginActivity.Location.X + $script:AutoChart01LoginActivity.Size.Width + $($FormScale *  20)
                  Y = $script:AutoChart01LoginActivity.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart02LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02LoginActivity.Titles.Add($script:AutoChart02LoginActivityTitle)

### Create Charts Area
$script:AutoChart02LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart02LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart02LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart02LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart02LoginActivity.ChartAreas.Add($script:AutoChart02LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02LoginActivity.Series.Add("Connections Per Host")  
$script:AutoChart02LoginActivity.Series["Connections Per Host"].Enabled           = $True
$script:AutoChart02LoginActivity.Series["Connections Per Host"].BorderWidth       = 1
$script:AutoChart02LoginActivity.Series["Connections Per Host"].IsVisibleInLegend = $false
$script:AutoChart02LoginActivity.Series["Connections Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02LoginActivity.Series["Connections Per Host"].Legend            = 'Legend'
$script:AutoChart02LoginActivity.Series["Connections Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02LoginActivity.Series["Connections Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02LoginActivity.Series["Connections Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02LoginActivity.Series["Connections Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02LoginActivity.Series["Connections Per Host"].Color             = 'Blue'
        
        function Generate-AutoChart02 {
            $script:AutoChart02LoginActivityCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart02LoginActivityUniqueDataFields = ($script:AutoChartDataSourceCsv).ProcessID | Sort-Object -Property 'ProcessID'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart02LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart02LoginActivityTitle.Text = "Connections Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02LoginActivityOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object PSComputerName) ) {
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
                            $script:AutoChart02LoginActivityOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02LoginActivityOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02LoginActivityOverallDataResults | ForEach-Object { $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
                $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02LoginActivityOverallDataResults.count))
                $script:AutoChart02LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
                $script:AutoChart02LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart02LoginActivityTitle.Text = "Connections Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart02LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02LoginActivityOptionsButton
$script:AutoChart02LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart02LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart02LoginActivity.Controls.Add($script:AutoChart02LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart02LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart02LoginActivity.Controls.Remove($script:AutoChart02LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02LoginActivity)

$script:AutoChart02LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02LoginActivityOverallDataResults.count))                
    $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart02LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
        $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart02LoginActivityTrimOffFirstTrackBar)
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02LoginActivityOverallDataResults.count))
    $script:AutoChart02LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart02LoginActivityOverallDataResults.count)
    $script:AutoChart02LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart02LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart02LoginActivityOverallDataResults.count) - $script:AutoChart02LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart02LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02LoginActivityOverallDataResults.count) - $script:AutoChart02LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
        $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart02LoginActivityTrimOffLastTrackBar)
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart02LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02LoginActivity.Series["Connections Per Host"].ChartType = $script:AutoChart02LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
#    $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02LoginActivityChartTypesAvailable) { $script:AutoChart02LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02LoginActivityChartTypeComboBox.Location.X + $script:AutoChart02LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02LoginActivity3DToggleButton
$script:AutoChart02LoginActivity3DInclination = 0
$script:AutoChart02LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart02LoginActivity3DInclination += 10
    if ( $script:AutoChart02LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart02LoginActivity3DInclination
        $script:AutoChart02LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart02LoginActivity3DInclination)"
#        $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02LoginActivity3DInclination -le 90 ) {
        $script:AutoChart02LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart02LoginActivity3DInclination
        $script:AutoChart02LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart02LoginActivity3DInclination)" 
#        $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart02LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart02LoginActivity3DInclination = 0
        $script:AutoChart02LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart02LoginActivity3DInclination
        $script:AutoChart02LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
#        $script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart02LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02LoginActivity3DToggleButton.Location.X + $script:AutoChart02LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02LoginActivityColorsAvailable) { $script:AutoChart02LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02LoginActivity.Series["Connections Per Host"].Color = $script:AutoChart02LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02LoginActivityImportCsvPosResults) { $script:AutoChart02LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart02LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart02LoginActivityImportCsvPosResults) { $script:AutoChart02LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02LoginActivityImportCsvNegResults) { $script:AutoChart02LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02LoginActivityImportCsvPosResults.count))"
    $script:AutoChart02LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart02LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02LoginActivityCheckDiffButton
$script:AutoChart02LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart02LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart02LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02LoginActivityInvestDiffDropDownArray) { $script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart02LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02LoginActivityInvestDiffExecuteButton
    $script:AutoChart02LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart02LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart02LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart02LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart02LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart02LoginActivityInvestDiffDropDownLabel,$script:AutoChart02LoginActivityInvestDiffDropDownComboBox,$script:AutoChart02LoginActivityInvestDiffExecuteButton,$script:AutoChart02LoginActivityInvestDiffPosResultsLabel,$script:AutoChart02LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart02LoginActivityInvestDiffNegResultsLabel,$script:AutoChart02LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart02LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart02LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02LoginActivityManipulationPanel.controls.Add($script:AutoChart02LoginActivityCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02LoginActivityCheckDiffButton.Location.X + $script:AutoChart02LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Logins per Endpoint" -PropertyX "PSComputerName" -PropertyY "ProcessID" }
}
CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart02LoginActivityCheckDiffButton.Location.Y + $script:AutoChart02LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02LoginActivityOpenInShell
$script:AutoChart02LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02LoginActivityManipulationPanel.controls.Add($script:AutoChart02LoginActivityOpenInShell)


$script:AutoChart02LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02LoginActivityOpenInShell.Location.X + $script:AutoChart02LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02LoginActivityViewResults
$script:AutoChart02LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart02LoginActivityManipulationPanel.controls.Add($script:AutoChart02LoginActivityViewResults)


### Save the chart to file
$script:AutoChart02LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart02LoginActivityOpenInShell.Location.Y + $script:AutoChart02LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02LoginActivity -Title $script:AutoChart02LoginActivityTitle
})
$script:AutoChart02LoginActivityManipulationPanel.controls.Add($script:AutoChart02LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart02LoginActivitySaveButton.Location.Y + $script:AutoChart02LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02LoginActivityManipulationPanel.Controls.Add($script:AutoChart02LoginActivityNoticeTextbox)

$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.Clear()
$script:AutoChart02LoginActivityOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02LoginActivity.Series["Connections Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01LoginActivity.Location.X
                  Y = $script:AutoChart01LoginActivity.Location.Y + $script:AutoChart01LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart03LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03LoginActivity.Titles.Add($script:AutoChart03LoginActivityTitle)

### Create Charts Area
$script:AutoChart03LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart03LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart03LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart03LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart03LoginActivity.ChartAreas.Add($script:AutoChart03LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03LoginActivity.Series.Add("Client IP")  
$script:AutoChart03LoginActivity.Series["Client IP"].Enabled           = $True
$script:AutoChart03LoginActivity.Series["Client IP"].BorderWidth       = 1
$script:AutoChart03LoginActivity.Series["Client IP"].IsVisibleInLegend = $false
$script:AutoChart03LoginActivity.Series["Client IP"].Chartarea         = 'Chart Area'
$script:AutoChart03LoginActivity.Series["Client IP"].Legend            = 'Legend'
$script:AutoChart03LoginActivity.Series["Client IP"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03LoginActivity.Series["Client IP"]['PieLineColor']   = 'Black'
$script:AutoChart03LoginActivity.Series["Client IP"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03LoginActivity.Series["Client IP"].ChartType         = 'Column'
$script:AutoChart03LoginActivity.Series["Client IP"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ClientIP' | Sort-Object -Property 'ClientIP' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()

            if ($script:AutoChart03LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart03LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart03LoginActivityTitle.Text = "Client IP"
                
                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.ClientIP -eq $DataField.ClientIP) {
                            $Count += 1
                            if ( $script:AutoChart03LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart03LoginActivityUniqueCount = $script:AutoChart03LoginActivityCsvComputers.Count
                    $script:AutoChart03LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03LoginActivityUniqueCount
                        Computers   = $script:AutoChart03LoginActivityCsvComputers 
                    }
                    $script:AutoChart03LoginActivityOverallDataResults += $script:AutoChart03LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount) }

                $script:AutoChart03LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03LoginActivityOverallDataResults.count))
                $script:AutoChart03LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart03LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart03LoginActivityTitle.Text = "Client IP`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03LoginActivityOptionsButton
$script:AutoChart03LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart03LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart03LoginActivity.Controls.Add($script:AutoChart03LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart03LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart03LoginActivity.Controls.Remove($script:AutoChart03LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03LoginActivity)

$script:AutoChart03LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03LoginActivityOverallDataResults.count))                
    $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart03LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
        $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}    
    })
    $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart03LoginActivityTrimOffFirstTrackBar)
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03LoginActivityOverallDataResults.count))
    $script:AutoChart03LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart03LoginActivityOverallDataResults.count)
    $script:AutoChart03LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart03LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart03LoginActivityOverallDataResults.count) - $script:AutoChart03LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart03LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03LoginActivityOverallDataResults.count) - $script:AutoChart03LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
        $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    })
$script:AutoChart03LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart03LoginActivityTrimOffLastTrackBar)
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart03LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03LoginActivity.Series["Client IP"].ChartType = $script:AutoChart03LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
#    $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
})
$script:AutoChart03LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03LoginActivityChartTypesAvailable) { $script:AutoChart03LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03LoginActivityChartTypeComboBox.Location.X + $script:AutoChart03LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03LoginActivity3DToggleButton
$script:AutoChart03LoginActivity3DInclination = 0
$script:AutoChart03LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart03LoginActivity3DInclination += 10
    if ( $script:AutoChart03LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart03LoginActivity3DInclination
        $script:AutoChart03LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart03LoginActivity3DInclination)"
#        $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03LoginActivity3DInclination -le 90 ) {
        $script:AutoChart03LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart03LoginActivity3DInclination
        $script:AutoChart03LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart03LoginActivity3DInclination)" 
#        $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart03LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart03LoginActivity3DInclination = 0
        $script:AutoChart03LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart03LoginActivity3DInclination
        $script:AutoChart03LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
#        $script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}
    }
})
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart03LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03LoginActivity3DToggleButton.Location.X + $script:AutoChart03LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03LoginActivityColorsAvailable) { $script:AutoChart03LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03LoginActivity.Series["Client IP"].Color = $script:AutoChart03LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ClientIP' -eq $($script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03LoginActivityImportCsvPosResults) { $script:AutoChart03LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart03LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart03LoginActivityImportCsvPosResults) { $script:AutoChart03LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03LoginActivityImportCsvNegResults) { $script:AutoChart03LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03LoginActivityImportCsvPosResults.count))"
    $script:AutoChart03LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart03LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03LoginActivityCheckDiffButton
$script:AutoChart03LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart03LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ClientIP' -ExpandProperty 'ClientIP' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart03LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03LoginActivityInvestDiffDropDownArray) { $script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart03LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03LoginActivityInvestDiffExecuteButton
    $script:AutoChart03LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart03LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart03LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart03LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart03LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart03LoginActivityInvestDiffDropDownLabel,$script:AutoChart03LoginActivityInvestDiffDropDownComboBox,$script:AutoChart03LoginActivityInvestDiffExecuteButton,$script:AutoChart03LoginActivityInvestDiffPosResultsLabel,$script:AutoChart03LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart03LoginActivityInvestDiffNegResultsLabel,$script:AutoChart03LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart03LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart03LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03LoginActivityManipulationPanel.controls.Add($script:AutoChart03LoginActivityCheckDiffButton)
    

$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03LoginActivityCheckDiffButton.Location.X + $script:AutoChart03LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Client IP" -PropertyX "ClientIP" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart03LoginActivityCheckDiffButton.Location.Y + $script:AutoChart03LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03LoginActivityOpenInShell
$script:AutoChart03LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03LoginActivityManipulationPanel.controls.Add($script:AutoChart03LoginActivityOpenInShell)


$script:AutoChart03LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03LoginActivityOpenInShell.Location.X + $script:AutoChart03LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03LoginActivityViewResults
$script:AutoChart03LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart03LoginActivityManipulationPanel.controls.Add($script:AutoChart03LoginActivityViewResults)


### Save the chart to file
$script:AutoChart03LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart03LoginActivityOpenInShell.Location.Y + $script:AutoChart03LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03LoginActivity -Title $script:AutoChart03LoginActivityTitle
})
$script:AutoChart03LoginActivityManipulationPanel.controls.Add($script:AutoChart03LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart03LoginActivitySaveButton.Location.Y + $script:AutoChart03LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03LoginActivityManipulationPanel.Controls.Add($script:AutoChart03LoginActivityNoticeTextbox)

$script:AutoChart03LoginActivity.Series["Client IP"].Points.Clear()
$script:AutoChart03LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03LoginActivity.Series["Client IP"].Points.AddXY($_.DataField.ClientIP,$_.UniqueCount)}    





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02LoginActivity.Location.X
                  Y = $script:AutoChart02LoginActivity.Location.Y + $script:AutoChart02LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart04LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04LoginActivity.Titles.Add($script:AutoChart04LoginActivityTitle)

### Create Charts Area
$script:AutoChart04LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart04LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart04LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart04LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart04LoginActivity.ChartAreas.Add($script:AutoChart04LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04LoginActivity.Series.Add("Connection State")  
$script:AutoChart04LoginActivity.Series["Connection State"].Enabled           = $True
$script:AutoChart04LoginActivity.Series["Connection State"].BorderWidth       = 1
$script:AutoChart04LoginActivity.Series["Connection State"].IsVisibleInLegend = $false
$script:AutoChart04LoginActivity.Series["Connection State"].Chartarea         = 'Chart Area'
$script:AutoChart04LoginActivity.Series["Connection State"].Legend            = 'Legend'
$script:AutoChart04LoginActivity.Series["Connection State"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04LoginActivity.Series["Connection State"]['PieLineColor']   = 'Black'
$script:AutoChart04LoginActivity.Series["Connection State"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04LoginActivity.Series["Connection State"].ChartType         = 'Column'
$script:AutoChart04LoginActivity.Series["Connection State"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'State' | Sort-Object -Property 'State' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()

            if ($script:AutoChart04LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart04LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart04LoginActivityTitle.Text = "Connection State"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.State) -eq $DataField.State) {
                            $Count += 1
                            if ( $script:AutoChart04LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart04LoginActivityUniqueCount = $script:AutoChart04LoginActivityCsvComputers.Count
                    $script:AutoChart04LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04LoginActivityUniqueCount
                        Computers   = $script:AutoChart04LoginActivityCsvComputers 
                    }
                    $script:AutoChart04LoginActivityOverallDataResults += $script:AutoChart04LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount) }

                $script:AutoChart04LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04LoginActivityOverallDataResults.count))
                $script:AutoChart04LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart04LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart04LoginActivityTitle.Text = "Connection State`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04LoginActivityOptionsButton
$script:AutoChart04LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart04LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart04LoginActivity.Controls.Add($script:AutoChart04LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart04LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart04LoginActivity.Controls.Remove($script:AutoChart04LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04LoginActivity)

$script:AutoChart04LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04LoginActivityOverallDataResults.count))                
    $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart04LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
        $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}    
    })
    $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart04LoginActivityTrimOffFirstTrackBar)
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04LoginActivityOverallDataResults.count))
    $script:AutoChart04LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart04LoginActivityOverallDataResults.count)
    $script:AutoChart04LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart04LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart04LoginActivityOverallDataResults.count) - $script:AutoChart04LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart04LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04LoginActivityOverallDataResults.count) - $script:AutoChart04LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
        $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    })
$script:AutoChart04LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart04LoginActivityTrimOffLastTrackBar)
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart04LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04LoginActivity.Series["Connection State"].ChartType = $script:AutoChart04LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
#    $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
})
$script:AutoChart04LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04LoginActivityChartTypesAvailable) { $script:AutoChart04LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04LoginActivityChartTypeComboBox.Location.X + $script:AutoChart04LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04LoginActivity3DToggleButton
$script:AutoChart04LoginActivity3DInclination = 0
$script:AutoChart04LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart04LoginActivity3DInclination += 10
    if ( $script:AutoChart04LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart04LoginActivity3DInclination
        $script:AutoChart04LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart04LoginActivity3DInclination)"
#        $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04LoginActivity3DInclination -le 90 ) {
        $script:AutoChart04LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart04LoginActivity3DInclination
        $script:AutoChart04LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart04LoginActivity3DInclination)" 
#        $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart04LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart04LoginActivity3DInclination = 0
        $script:AutoChart04LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart04LoginActivity3DInclination
        $script:AutoChart04LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
#        $script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}
    }
})
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart04LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04LoginActivity3DToggleButton.Location.X + $script:AutoChart04LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04LoginActivityColorsAvailable) { $script:AutoChart04LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04LoginActivity.Series["Connection State"].Color = $script:AutoChart04LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'State' -eq $($script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04LoginActivityImportCsvPosResults) { $script:AutoChart04LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart04LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart04LoginActivityImportCsvPosResults) { $script:AutoChart04LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04LoginActivityImportCsvNegResults) { $script:AutoChart04LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04LoginActivityImportCsvPosResults.count))"
    $script:AutoChart04LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart04LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04LoginActivityCheckDiffButton
$script:AutoChart04LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart04LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'State' -ExpandProperty 'State' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart04LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04LoginActivityInvestDiffDropDownArray) { $script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart04LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04LoginActivityInvestDiffExecuteButton 
    $script:AutoChart04LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart04LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart04LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart04LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart04LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart04LoginActivityInvestDiffDropDownLabel,$script:AutoChart04LoginActivityInvestDiffDropDownComboBox,$script:AutoChart04LoginActivityInvestDiffExecuteButton,$script:AutoChart04LoginActivityInvestDiffPosResultsLabel,$script:AutoChart04LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart04LoginActivityInvestDiffNegResultsLabel,$script:AutoChart04LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart04LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart04LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04LoginActivityManipulationPanel.controls.Add($script:AutoChart04LoginActivityCheckDiffButton)
    

$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04LoginActivityCheckDiffButton.Location.X + $script:AutoChart04LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Connection State" -PropertyX "State" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart04LoginActivityCheckDiffButton.Location.Y + $script:AutoChart04LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04LoginActivityOpenInShell
$script:AutoChart04LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04LoginActivityManipulationPanel.controls.Add($script:AutoChart04LoginActivityOpenInShell)


$script:AutoChart04LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04LoginActivityOpenInShell.Location.X + $script:AutoChart04LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04LoginActivityViewResults
$script:AutoChart04LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart04LoginActivityManipulationPanel.controls.Add($script:AutoChart04LoginActivityViewResults)


### Save the chart to file
$script:AutoChart04LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart04LoginActivityOpenInShell.Location.Y + $script:AutoChart04LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04LoginActivity -Title $script:AutoChart04LoginActivityTitle
})
$script:AutoChart04LoginActivityManipulationPanel.controls.Add($script:AutoChart04LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart04LoginActivitySaveButton.Location.Y + $script:AutoChart04LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04LoginActivityManipulationPanel.Controls.Add($script:AutoChart04LoginActivityNoticeTextbox)

$script:AutoChart04LoginActivity.Series["Connection State"].Points.Clear()
$script:AutoChart04LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04LoginActivity.Series["Connection State"].Points.AddXY($_.DataField.State,$_.UniqueCount)}    




















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03LoginActivity.Location.X
                  Y = $script:AutoChart03LoginActivity.Location.Y + $script:AutoChart03LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart05LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05LoginActivity.Titles.Add($script:AutoChart05LoginActivityTitle)

### Create Charts Area
$script:AutoChart05LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart05LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart05LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart05LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart05LoginActivity.ChartAreas.Add($script:AutoChart05LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05LoginActivity.Series.Add("Shell Run Time")  
$script:AutoChart05LoginActivity.Series["Shell Run Time"].Enabled           = $True
$script:AutoChart05LoginActivity.Series["Shell Run Time"].BorderWidth       = 1
$script:AutoChart05LoginActivity.Series["Shell Run Time"].IsVisibleInLegend = $false
$script:AutoChart05LoginActivity.Series["Shell Run Time"].Chartarea         = 'Chart Area'
$script:AutoChart05LoginActivity.Series["Shell Run Time"].Legend            = 'Legend'
$script:AutoChart05LoginActivity.Series["Shell Run Time"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05LoginActivity.Series["Shell Run Time"]['PieLineColor']   = 'Black'
$script:AutoChart05LoginActivity.Series["Shell Run Time"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05LoginActivity.Series["Shell Run Time"].ChartType         = 'Bar'
$script:AutoChart05LoginActivity.Series["Shell Run Time"].Color             = 'Orange'

        function Generate-AutoChart05 {
            $script:AutoChart05LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart05LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ShellRunTime' | Sort-Object -Property 'ShellRunTime' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()

            if ($script:AutoChart05LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart05LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart05LoginActivityTitle.Text = "Shell Run Time"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart05LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart05LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.ShellRunTime) -eq $DataField.ShellRunTime) {
                            $Count += 1
                            if ( $script:AutoChart05LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart05LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart05LoginActivityUniqueCount = $script:AutoChart05LoginActivityCsvComputers.Count
                    $script:AutoChart05LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05LoginActivityUniqueCount
                        Computers   = $script:AutoChart05LoginActivityCsvComputers 
                    }
                    $script:AutoChart05LoginActivityOverallDataResults += $script:AutoChart05LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount) }

                $script:AutoChart05LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05LoginActivityOverallDataResults.count))
                $script:AutoChart05LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart05LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart05LoginActivityTitle.Text = "Shell Run Time`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05LoginActivityOptionsButton
$script:AutoChart05LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart05LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart05LoginActivity.Controls.Add($script:AutoChart05LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart05LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart05LoginActivity.Controls.Remove($script:AutoChart05LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05LoginActivity)

$script:AutoChart05LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05LoginActivityOverallDataResults.count))                
    $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart05LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
        $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}    
    })
    $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart05LoginActivityTrimOffFirstTrackBar)
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05LoginActivityOverallDataResults.count))
    $script:AutoChart05LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart05LoginActivityOverallDataResults.count)
    $script:AutoChart05LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart05LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart05LoginActivityOverallDataResults.count) - $script:AutoChart05LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart05LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05LoginActivityOverallDataResults.count) - $script:AutoChart05LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
        $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    })
$script:AutoChart05LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart05LoginActivityTrimOffLastTrackBar)
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart05LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05LoginActivity.Series["Shell Run Time"].ChartType = $script:AutoChart05LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
#    $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
})
$script:AutoChart05LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05LoginActivityChartTypesAvailable) { $script:AutoChart05LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05LoginActivityChartTypeComboBox.Location.X + $script:AutoChart05LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05LoginActivity3DToggleButton
$script:AutoChart05LoginActivity3DInclination = 0
$script:AutoChart05LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart05LoginActivity3DInclination += 10
    if ( $script:AutoChart05LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart05LoginActivity3DInclination
        $script:AutoChart05LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart05LoginActivity3DInclination)"
#        $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05LoginActivity3DInclination -le 90 ) {
        $script:AutoChart05LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart05LoginActivity3DInclination
        $script:AutoChart05LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart05LoginActivity3DInclination)" 
#        $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart05LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart05LoginActivity3DInclination = 0
        $script:AutoChart05LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart05LoginActivity3DInclination
        $script:AutoChart05LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
#        $script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}
    }
})
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart05LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05LoginActivity3DToggleButton.Location.X + $script:AutoChart05LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05LoginActivityColorsAvailable) { $script:AutoChart05LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05LoginActivity.Series["Shell Run Time"].Color = $script:AutoChart05LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ShellRunTime' -eq $($script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05LoginActivityImportCsvPosResults) { $script:AutoChart05LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart05LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart05LoginActivityImportCsvPosResults) { $script:AutoChart05LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05LoginActivityImportCsvNegResults) { $script:AutoChart05LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05LoginActivityImportCsvPosResults.count))"
    $script:AutoChart05LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart05LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05LoginActivityCheckDiffButton
$script:AutoChart05LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart05LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ShellRunTime' -ExpandProperty 'ShellRunTime' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart05LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05LoginActivityInvestDiffDropDownArray) { $script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart05LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05LoginActivityInvestDiffExecuteButton 
    $script:AutoChart05LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart05LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart05LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart05LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart05LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart05LoginActivityInvestDiffDropDownLabel,$script:AutoChart05LoginActivityInvestDiffDropDownComboBox,$script:AutoChart05LoginActivityInvestDiffExecuteButton,$script:AutoChart05LoginActivityInvestDiffPosResultsLabel,$script:AutoChart05LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart05LoginActivityInvestDiffNegResultsLabel,$script:AutoChart05LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart05LoginActivityInvestDiffForm.add_Load($OnLoadForm_ShellRunTimeCorrection)
    $script:AutoChart05LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart05LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05LoginActivityManipulationPanel.controls.Add($script:AutoChart05LoginActivityCheckDiffButton)
    

$AutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05LoginActivityCheckDiffButton.Location.X + $script:AutoChart05LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Shell Run Time" -PropertyX "ShellRunTime" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart05LoginActivityCheckDiffButton.Location.Y + $script:AutoChart05LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05LoginActivityOpenInShell
$script:AutoChart05LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart05LoginActivityManipulationPanel.controls.Add($script:AutoChart05LoginActivityOpenInShell)


$script:AutoChart05LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05LoginActivityOpenInShell.Location.X + $script:AutoChart05LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05LoginActivityViewResults
$script:AutoChart05LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart05LoginActivityManipulationPanel.controls.Add($script:AutoChart05LoginActivityViewResults)


### Save the chart to file
$script:AutoChart05LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart05LoginActivityOpenInShell.Location.Y + $script:AutoChart05LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05LoginActivity -Title $script:AutoChart05LoginActivityTitle
})
$script:AutoChart05LoginActivityManipulationPanel.controls.Add($script:AutoChart05LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart05LoginActivitySaveButton.Location.Y + $script:AutoChart05LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05LoginActivityManipulationPanel.Controls.Add($script:AutoChart05LoginActivityNoticeTextbox)

$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.Clear()
$script:AutoChart05LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05LoginActivity.Series["Shell Run Time"].Points.AddXY($_.DataField.ShellRunTime,$_.UniqueCount)}    




















##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04LoginActivity.Location.X
                  Y = $script:AutoChart04LoginActivity.Location.Y + $script:AutoChart04LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart06LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06LoginActivity.Titles.Add($script:AutoChart06LoginActivityTitle)

### Create Charts Area
$script:AutoChart06LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart06LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart06LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart06LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart06LoginActivity.ChartAreas.Add($script:AutoChart06LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06LoginActivity.Series.Add("Shell Inactivity Time")  
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Enabled           = $True
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].BorderWidth       = 1
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].IsVisibleInLegend = $false
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Chartarea         = 'Chart Area'
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Legend            = 'Legend'
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"]['PieLineColor']   = 'Black'
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].ChartType         = 'Bar'
$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Color             = 'Gray'

        function Generate-AutoChart06 {
            $script:AutoChart06LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart06LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ShellInactivity' | Sort-Object -Property 'ShellInactivity' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()

            if ($script:AutoChart06LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart06LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart06LoginActivityTitle.Text = "Shell Inactivity Time"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart06LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06LoginActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.ShellInactivity) -eq $DataField.ShellInactivity) {
                            $Count += 1
                            if ( $script:AutoChart06LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart06LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart06LoginActivityUniqueCount = $script:AutoChart06LoginActivityCsvComputers.Count
                    $script:AutoChart06LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06LoginActivityUniqueCount
                        Computers   = $script:AutoChart06LoginActivityCsvComputers 
                    }
                    $script:AutoChart06LoginActivityOverallDataResults += $script:AutoChart06LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount) }

                $script:AutoChart06LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06LoginActivityOverallDataResults.count))
                $script:AutoChart06LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart06LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart06LoginActivityTitle.Text = "Shell Inactivity Time`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06LoginActivityOptionsButton
$script:AutoChart06LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart06LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart06LoginActivity.Controls.Add($script:AutoChart06LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart06LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart06LoginActivity.Controls.Remove($script:AutoChart06LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06LoginActivity)

$script:AutoChart06LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06LoginActivityOverallDataResults.count))                
    $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart06LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
        $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}    
    })
    $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart06LoginActivityTrimOffFirstTrackBar)
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06LoginActivityOverallDataResults.count))
    $script:AutoChart06LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart06LoginActivityOverallDataResults.count)
    $script:AutoChart06LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart06LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart06LoginActivityOverallDataResults.count) - $script:AutoChart06LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart06LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06LoginActivityOverallDataResults.count) - $script:AutoChart06LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
        $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    })
$script:AutoChart06LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart06LoginActivityTrimOffLastTrackBar)
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart06LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].ChartType = $script:AutoChart06LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
#    $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
})
$script:AutoChart06LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06LoginActivityChartTypesAvailable) { $script:AutoChart06LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06LoginActivityChartTypeComboBox.Location.X + $script:AutoChart06LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06LoginActivity3DToggleButton
$script:AutoChart06LoginActivity3DInclination = 0
$script:AutoChart06LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart06LoginActivity3DInclination += 10
    if ( $script:AutoChart06LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart06LoginActivity3DInclination
        $script:AutoChart06LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart06LoginActivity3DInclination)"
#        $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06LoginActivity3DInclination -le 90 ) {
        $script:AutoChart06LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart06LoginActivity3DInclination
        $script:AutoChart06LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart06LoginActivity3DInclination)" 
#        $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart06LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart06LoginActivity3DInclination = 0
        $script:AutoChart06LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart06LoginActivity3DInclination
        $script:AutoChart06LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
#        $script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}
    }
})
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart06LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06LoginActivity3DToggleButton.Location.X + $script:AutoChart06LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06LoginActivityColorsAvailable) { $script:AutoChart06LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Color = $script:AutoChart06LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ShellInactivity' -eq $($script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06LoginActivityImportCsvPosResults) { $script:AutoChart06LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart06LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart06LoginActivityImportCsvPosResults) { $script:AutoChart06LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06LoginActivityImportCsvNegResults) { $script:AutoChart06LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06LoginActivityImportCsvPosResults.count))"
    $script:AutoChart06LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart06LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06LoginActivityCheckDiffButton
$script:AutoChart06LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart06LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ShellInactivity' -ExpandProperty 'ShellInactivity' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart06LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06LoginActivityInvestDiffDropDownArray) { $script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart06LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06LoginActivityInvestDiffExecuteButton
    $script:AutoChart06LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart06LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart06LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart06LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart06LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart06LoginActivityInvestDiffDropDownLabel,$script:AutoChart06LoginActivityInvestDiffDropDownComboBox,$script:AutoChart06LoginActivityInvestDiffExecuteButton,$script:AutoChart06LoginActivityInvestDiffPosResultsLabel,$script:AutoChart06LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart06LoginActivityInvestDiffNegResultsLabel,$script:AutoChart06LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart06LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart06LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06LoginActivityManipulationPanel.controls.Add($script:AutoChart06LoginActivityCheckDiffButton)
    

$AutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06LoginActivityCheckDiffButton.Location.X + $script:AutoChart06LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Shell Inactivity Timees" -PropertyX "ShellInactivity" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart06LoginActivityCheckDiffButton.Location.Y + $script:AutoChart06LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06LoginActivityOpenInShell
$script:AutoChart06LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart06LoginActivityManipulationPanel.controls.Add($script:AutoChart06LoginActivityOpenInShell)


$script:AutoChart06LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06LoginActivityOpenInShell.Location.X + $script:AutoChart06LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06LoginActivityViewResults
$script:AutoChart06LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart06LoginActivityManipulationPanel.controls.Add($script:AutoChart06LoginActivityViewResults)


### Save the chart to file
$script:AutoChart06LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart06LoginActivityOpenInShell.Location.Y + $script:AutoChart06LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06LoginActivity -Title $script:AutoChart06LoginActivityTitle
})
$script:AutoChart06LoginActivityManipulationPanel.controls.Add($script:AutoChart06LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart06LoginActivitySaveButton.Location.Y + $script:AutoChart06LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06LoginActivityManipulationPanel.Controls.Add($script:AutoChart06LoginActivityNoticeTextbox)

$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.Clear()
$script:AutoChart06LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06LoginActivity.Series["Shell Inactivity Time"].Points.AddXY($_.DataField.ShellInactivity,$_.UniqueCount)}    





















##############################################################################################
# AutoChart07
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05LoginActivity.Location.X
                  Y = $script:AutoChart05LoginActivity.Location.Y + $script:AutoChart05LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart07LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07LoginActivity.Titles.Add($script:AutoChart07LoginActivityTitle)

### Create Charts Area
$script:AutoChart07LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart07LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart07LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart07LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart07LoginActivity.ChartAreas.Add($script:AutoChart07LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07LoginActivity.Series.Add("Child Processes")  
$script:AutoChart07LoginActivity.Series["Child Processes"].Enabled           = $True
$script:AutoChart07LoginActivity.Series["Child Processes"].BorderWidth       = 1
$script:AutoChart07LoginActivity.Series["Child Processes"].IsVisibleInLegend = $false
$script:AutoChart07LoginActivity.Series["Child Processes"].Chartarea         = 'Chart Area'
$script:AutoChart07LoginActivity.Series["Child Processes"].Legend            = 'Legend'
$script:AutoChart07LoginActivity.Series["Child Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07LoginActivity.Series["Child Processes"]['PieLineColor']   = 'Black'
$script:AutoChart07LoginActivity.Series["Child Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07LoginActivity.Series["Child Processes"].ChartType         = 'Column'
$script:AutoChart07LoginActivity.Series["Child Processes"].Color             = 'SlateBLue'

        function Generate-AutoChart07 {
            $script:AutoChart07LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart07LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ChildProcesses' | Sort-Object -Property 'ChildProcesses' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()

            if ($script:AutoChart07LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart07LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart07LoginActivityTitle.Text = "Child Processes"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart07LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07LoginActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.ChildProcesses) -eq $DataField.ChildProcesses) {
                            $Count += 1
                            if ( $script:AutoChart07LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart07LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart07LoginActivityUniqueCount = $script:AutoChart07LoginActivityCsvComputers.Count
                    $script:AutoChart07LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07LoginActivityUniqueCount
                        Computers   = $script:AutoChart07LoginActivityCsvComputers 
                    }
                    $script:AutoChart07LoginActivityOverallDataResults += $script:AutoChart07LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount) }

                $script:AutoChart07LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07LoginActivityOverallDataResults.count))
                $script:AutoChart07LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart07LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart07LoginActivityTitle.Text = "Child Processes`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart07LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07LoginActivityOptionsButton
$script:AutoChart07LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart07LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart07LoginActivity.Controls.Add($script:AutoChart07LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart07LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart07LoginActivity.Controls.Remove($script:AutoChart07LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07LoginActivity)

$script:AutoChart07LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07LoginActivityOverallDataResults.count))                
    $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart07LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
        $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}    
    })
    $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart07LoginActivityTrimOffFirstTrackBar)
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07LoginActivityOverallDataResults.count))
    $script:AutoChart07LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart07LoginActivityOverallDataResults.count)
    $script:AutoChart07LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart07LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart07LoginActivityOverallDataResults.count) - $script:AutoChart07LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart07LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07LoginActivityOverallDataResults.count) - $script:AutoChart07LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
        $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    })
$script:AutoChart07LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart07LoginActivityTrimOffLastTrackBar)
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart07LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07LoginActivity.Series["Child Processes"].ChartType = $script:AutoChart07LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
#    $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
})
$script:AutoChart07LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07LoginActivityChartTypesAvailable) { $script:AutoChart07LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07LoginActivityChartTypeComboBox.Location.X + $script:AutoChart07LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07LoginActivity3DToggleButton
$script:AutoChart07LoginActivity3DInclination = 0
$script:AutoChart07LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart07LoginActivity3DInclination += 10
    if ( $script:AutoChart07LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart07LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart07LoginActivity3DInclination
        $script:AutoChart07LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart07LoginActivity3DInclination)"
#        $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart07LoginActivity3DInclination -le 90 ) {
        $script:AutoChart07LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart07LoginActivity3DInclination
        $script:AutoChart07LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart07LoginActivity3DInclination)" 
#        $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart07LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart07LoginActivity3DInclination = 0
        $script:AutoChart07LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart07LoginActivity3DInclination
        $script:AutoChart07LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
#        $script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}
    }
})
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart07LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07LoginActivity3DToggleButton.Location.X + $script:AutoChart07LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07LoginActivityColorsAvailable) { $script:AutoChart07LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07LoginActivity.Series["Child Processes"].Color = $script:AutoChart07LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivityChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart07LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ChildProcesses' -eq $($script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart07LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07LoginActivityImportCsvPosResults) { $script:AutoChart07LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart07LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart07LoginActivityImportCsvPosResults) { $script:AutoChart07LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07LoginActivityImportCsvNegResults) { $script:AutoChart07LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07LoginActivityImportCsvPosResults.count))"
    $script:AutoChart07LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart07LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07LoginActivityCheckDiffButton
$script:AutoChart07LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart07LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ChildProcesses' -ExpandProperty 'ChildProcesses' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart07LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07LoginActivityInvestDiffDropDownArray) { $script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:AutoChart07LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart07LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07LoginActivityInvestDiffExecuteButton
    $script:AutoChart07LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart07LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart07LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart07LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart07LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart07LoginActivityInvestDiffDropDownLabel,$script:AutoChart07LoginActivityInvestDiffDropDownComboBox,$script:AutoChart07LoginActivityInvestDiffExecuteButton,$script:AutoChart07LoginActivityInvestDiffPosResultsLabel,$script:AutoChart07LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart07LoginActivityInvestDiffNegResultsLabel,$script:AutoChart07LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart07LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart07LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07LoginActivityManipulationPanel.controls.Add($script:AutoChart07LoginActivityCheckDiffButton)
    

$AutoChart07ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07LoginActivityCheckDiffButton.Location.X + $script:AutoChart07LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Child Processes" -PropertyX "ChildProcesses" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart07ExpandChartButton
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($AutoChart07ExpandChartButton)


$script:AutoChart07LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart07LoginActivityCheckDiffButton.Location.Y + $script:AutoChart07LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07LoginActivityOpenInShell
$script:AutoChart07LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart07LoginActivityManipulationPanel.controls.Add($script:AutoChart07LoginActivityOpenInShell)


$script:AutoChart07LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07LoginActivityOpenInShell.Location.X + $script:AutoChart07LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07LoginActivityViewResults
$script:AutoChart07LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart07LoginActivityManipulationPanel.controls.Add($script:AutoChart07LoginActivityViewResults)


### Save the chart to file
$script:AutoChart07LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart07LoginActivityOpenInShell.Location.Y + $script:AutoChart07LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07LoginActivity -Title $script:AutoChart07LoginActivityTitle
})
$script:AutoChart07LoginActivityManipulationPanel.controls.Add($script:AutoChart07LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart07LoginActivitySaveButton.Location.Y + $script:AutoChart07LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07LoginActivityManipulationPanel.Controls.Add($script:AutoChart07LoginActivityNoticeTextbox)

$script:AutoChart07LoginActivity.Series["Child Processes"].Points.Clear()
$script:AutoChart07LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07LoginActivity.Series["Child Processes"].Points.AddXY($_.DataField.ChildProcesses,$_.UniqueCount)}    






















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06LoginActivity.Location.X
                  Y = $script:AutoChart06LoginActivity.Location.Y + $script:AutoChart06LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart08LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart08LoginActivity.Titles.Add($script:AutoChart08LoginActivityTitle)

### Create Charts Area
$script:AutoChart08LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart08LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart08LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart08LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart08LoginActivity.ChartAreas.Add($script:AutoChart08LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08LoginActivity.Series.Add("Memory Used")  
$script:AutoChart08LoginActivity.Series["Memory Used"].Enabled           = $True
$script:AutoChart08LoginActivity.Series["Memory Used"].BorderWidth       = 1
$script:AutoChart08LoginActivity.Series["Memory Used"].IsVisibleInLegend = $false
$script:AutoChart08LoginActivity.Series["Memory Used"].Chartarea         = 'Chart Area'
$script:AutoChart08LoginActivity.Series["Memory Used"].Legend            = 'Legend'
$script:AutoChart08LoginActivity.Series["Memory Used"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08LoginActivity.Series["Memory Used"]['PieLineColor']   = 'Black'
$script:AutoChart08LoginActivity.Series["Memory Used"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08LoginActivity.Series["Memory Used"].ChartType         = 'Column'
$script:AutoChart08LoginActivity.Series["Memory Used"].Color             = 'Purple'

        function Generate-AutoChart08 {
            $script:AutoChart08LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart08LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'MemoryUsed' | Sort-Object -Property 'MemoryUsed' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()

            if ($script:AutoChart08LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart08LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart08LoginActivityTitle.Text = "Memory Used"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart08LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart08LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.MemoryUsed) -eq $DataField.MemoryUsed) {
                            $Count += 1
                            if ( $script:AutoChart08LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart08LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart08LoginActivityUniqueCount = $script:AutoChart08LoginActivityCsvComputers.Count
                    $script:AutoChart08LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08LoginActivityUniqueCount
                        Computers   = $script:AutoChart08LoginActivityCsvComputers 
                    }
                    $script:AutoChart08LoginActivityOverallDataResults += $script:AutoChart08LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount) }

                $script:AutoChart08LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08LoginActivityOverallDataResults.count))
                $script:AutoChart08LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart08LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart08LoginActivityTitle.Text = "Memory Used`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart08LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08LoginActivityOptionsButton
$script:AutoChart08LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart08LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart08LoginActivity.Controls.Add($script:AutoChart08LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart08LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart08LoginActivity.Controls.Remove($script:AutoChart08LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08LoginActivity)

$script:AutoChart08LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08LoginActivityOverallDataResults.count))                
    $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart08LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
        $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}    
    })
    $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart08LoginActivityTrimOffFirstTrackBar)
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08LoginActivityOverallDataResults.count))
    $script:AutoChart08LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart08LoginActivityOverallDataResults.count)
    $script:AutoChart08LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart08LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart08LoginActivityOverallDataResults.count) - $script:AutoChart08LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart08LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08LoginActivityOverallDataResults.count) - $script:AutoChart08LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
        $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    })
$script:AutoChart08LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart08LoginActivityTrimOffLastTrackBar)
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart08LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08LoginActivity.Series["Memory Used"].ChartType = $script:AutoChart08LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
#    $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
})
$script:AutoChart08LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08LoginActivityChartTypesAvailable) { $script:AutoChart08LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08LoginActivityChartTypeComboBox.Location.X + $script:AutoChart08LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08LoginActivity3DToggleButton
$script:AutoChart08LoginActivity3DInclination = 0
$script:AutoChart08LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart08LoginActivity3DInclination += 10
    if ( $script:AutoChart08LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart08LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart08LoginActivity3DInclination
        $script:AutoChart08LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart08LoginActivity3DInclination)"
#        $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart08LoginActivity3DInclination -le 90 ) {
        $script:AutoChart08LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart08LoginActivity3DInclination
        $script:AutoChart08LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart08LoginActivity3DInclination)" 
#        $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart08LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart08LoginActivity3DInclination = 0
        $script:AutoChart08LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart08LoginActivity3DInclination
        $script:AutoChart08LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
#        $script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}
    }
})
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart08LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08LoginActivity3DToggleButton.Location.X + $script:AutoChart08LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08LoginActivityColorsAvailable) { $script:AutoChart08LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08LoginActivity.Series["Memory Used"].Color = $script:AutoChart08LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart08LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'MemoryUsed' -eq $($script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart08LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08LoginActivityImportCsvPosResults) { $script:AutoChart08LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart08LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart08LoginActivityImportCsvPosResults) { $script:AutoChart08LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08LoginActivityImportCsvNegResults) { $script:AutoChart08LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08LoginActivityImportCsvPosResults.count))"
    $script:AutoChart08LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart08LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08LoginActivityCheckDiffButton
$script:AutoChart08LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart08LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'MemoryUsed' -ExpandProperty 'MemoryUsed' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart08LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08LoginActivityInvestDiffDropDownArray) { $script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:AutoChart08LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart08LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08LoginActivityInvestDiffExecuteButton 
    $script:AutoChart08LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart08LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart08LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart08LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart08LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart08LoginActivityInvestDiffDropDownLabel,$script:AutoChart08LoginActivityInvestDiffDropDownComboBox,$script:AutoChart08LoginActivityInvestDiffExecuteButton,$script:AutoChart08LoginActivityInvestDiffPosResultsLabel,$script:AutoChart08LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart08LoginActivityInvestDiffNegResultsLabel,$script:AutoChart08LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart08LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart08LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08LoginActivityManipulationPanel.controls.Add($script:AutoChart08LoginActivityCheckDiffButton)
    

$AutoChart08ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08LoginActivityCheckDiffButton.Location.X + $script:AutoChart08LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Memory Used" -PropertyX "MemoryUsed" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart08ExpandChartButton
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($AutoChart08ExpandChartButton)


$script:AutoChart08LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart08LoginActivityCheckDiffButton.Location.Y + $script:AutoChart08LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08LoginActivityOpenInShell
$script:AutoChart08LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart08LoginActivityManipulationPanel.controls.Add($script:AutoChart08LoginActivityOpenInShell)


$script:AutoChart08LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08LoginActivityOpenInShell.Location.X + $script:AutoChart08LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08LoginActivityViewResults
$script:AutoChart08LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart08LoginActivityManipulationPanel.controls.Add($script:AutoChart08LoginActivityViewResults)


### Save the chart to file
$script:AutoChart08LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart08LoginActivityOpenInShell.Location.Y + $script:AutoChart08LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08LoginActivity -Title $script:AutoChart08LoginActivityTitle
})
$script:AutoChart08LoginActivityManipulationPanel.controls.Add($script:AutoChart08LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart08LoginActivitySaveButton.Location.Y + $script:AutoChart08LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08LoginActivityManipulationPanel.Controls.Add($script:AutoChart08LoginActivityNoticeTextbox)

$script:AutoChart08LoginActivity.Series["Memory Used"].Points.Clear()
$script:AutoChart08LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08LoginActivity.Series["Memory Used"].Points.AddXY($_.DataField.MemoryUsed,$_.UniqueCount)}






















##############################################################################################
# AutoChart09
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07LoginActivity.Location.X
                  Y = $script:AutoChart07LoginActivity.Location.Y + $script:AutoChart07LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart09LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09LoginActivity.Titles.Add($script:AutoChart09LoginActivityTitle)

### Create Charts Area
$script:AutoChart09LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart09LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart09LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart09LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart09LoginActivity.ChartAreas.Add($script:AutoChart09LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09LoginActivity.Series.Add("Profile Loaded")  
$script:AutoChart09LoginActivity.Series["Profile Loaded"].Enabled           = $True
$script:AutoChart09LoginActivity.Series["Profile Loaded"].BorderWidth       = 1
$script:AutoChart09LoginActivity.Series["Profile Loaded"].IsVisibleInLegend = $false
$script:AutoChart09LoginActivity.Series["Profile Loaded"].Chartarea         = 'Chart Area'
$script:AutoChart09LoginActivity.Series["Profile Loaded"].Legend            = 'Legend'
$script:AutoChart09LoginActivity.Series["Profile Loaded"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09LoginActivity.Series["Profile Loaded"]['PieLineColor']   = 'Black'
$script:AutoChart09LoginActivity.Series["Profile Loaded"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09LoginActivity.Series["Profile Loaded"].ChartType         = 'Column'
$script:AutoChart09LoginActivity.Series["Profile Loaded"].Color             = 'Yellow'

        function Generate-AutoChart09 {
            $script:AutoChart09LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart09LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ProfileLoaded' | Sort-Object -Property 'ProfileLoaded' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()

            if ($script:AutoChart09LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart09LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart09LoginActivityTitle.Text = "Profile Loaded"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart09LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09LoginActivityUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.ProfileLoaded) -eq $DataField.ProfileLoaded) {
                            $Count += 1
                            if ( $script:AutoChart09LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart09LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart09LoginActivityUniqueCount = $script:AutoChart09LoginActivityCsvComputers.Count
                    $script:AutoChart09LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09LoginActivityUniqueCount
                        Computers   = $script:AutoChart09LoginActivityCsvComputers 
                    }
                    $script:AutoChart09LoginActivityOverallDataResults += $script:AutoChart09LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount) }

                $script:AutoChart09LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09LoginActivityOverallDataResults.count))
                $script:AutoChart09LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart09LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart09LoginActivityTitle.Text = "Profile Loaded`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart09LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09LoginActivityOptionsButton
$script:AutoChart09LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart09LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart09LoginActivity.Controls.Add($script:AutoChart09LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart09LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart09LoginActivity.Controls.Remove($script:AutoChart09LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09LoginActivity)

$script:AutoChart09LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09LoginActivityOverallDataResults.count))                
    $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart09LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
        $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}    
    })
    $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart09LoginActivityTrimOffFirstTrackBar)
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09LoginActivityOverallDataResults.count))
    $script:AutoChart09LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart09LoginActivityOverallDataResults.count)
    $script:AutoChart09LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart09LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart09LoginActivityOverallDataResults.count) - $script:AutoChart09LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart09LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09LoginActivityOverallDataResults.count) - $script:AutoChart09LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
        $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    })
$script:AutoChart09LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart09LoginActivityTrimOffLastTrackBar)
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart09LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09LoginActivity.Series["Profile Loaded"].ChartType = $script:AutoChart09LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
#    $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
})
$script:AutoChart09LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09LoginActivityChartTypesAvailable) { $script:AutoChart09LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09LoginActivityChartTypeComboBox.Location.X + $script:AutoChart09LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09LoginActivity3DToggleButton
$script:AutoChart09LoginActivity3DInclination = 0
$script:AutoChart09LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart09LoginActivity3DInclination += 10
    if ( $script:AutoChart09LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart09LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart09LoginActivity3DInclination
        $script:AutoChart09LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart09LoginActivity3DInclination)"
#        $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09LoginActivity3DInclination -le 90 ) {
        $script:AutoChart09LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart09LoginActivity3DInclination
        $script:AutoChart09LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart09LoginActivity3DInclination)" 
#        $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart09LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart09LoginActivity3DInclination = 0
        $script:AutoChart09LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart09LoginActivity3DInclination
        $script:AutoChart09LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
#        $script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}
    }
})
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart09LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09LoginActivity3DToggleButton.Location.X + $script:AutoChart09LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09LoginActivityColorsAvailable) { $script:AutoChart09LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09LoginActivity.Series["Profile Loaded"].Color = $script:AutoChart09LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart09LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ProfileLoaded' -eq $($script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart09LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09LoginActivityImportCsvPosResults) { $script:AutoChart09LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart09LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart09LoginActivityImportCsvPosResults) { $script:AutoChart09LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09LoginActivityImportCsvNegResults) { $script:AutoChart09LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09LoginActivityImportCsvPosResults.count))"
    $script:AutoChart09LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart09LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09LoginActivityCheckDiffButton
$script:AutoChart09LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart09LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ProfileLoaded' -ExpandProperty 'ProfileLoaded' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart09LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09LoginActivityInvestDiffDropDownArray) { $script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:AutoChart09LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart09LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09LoginActivityInvestDiffExecuteButton
    $script:AutoChart09LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart09LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart09LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart09LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart09LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart09LoginActivityInvestDiffDropDownLabel,$script:AutoChart09LoginActivityInvestDiffDropDownComboBox,$script:AutoChart09LoginActivityInvestDiffExecuteButton,$script:AutoChart09LoginActivityInvestDiffPosResultsLabel,$script:AutoChart09LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart09LoginActivityInvestDiffNegResultsLabel,$script:AutoChart09LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart09LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart09LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09LoginActivityManipulationPanel.controls.Add($script:AutoChart09LoginActivityCheckDiffButton)
    

$AutoChart09ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09LoginActivityCheckDiffButton.Location.X + $script:AutoChart09LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Profile Loadeds" -PropertyX "ProfileLoaded" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart09ExpandChartButton
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($AutoChart09ExpandChartButton)


$script:AutoChart09LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart09LoginActivityCheckDiffButton.Location.Y + $script:AutoChart09LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09LoginActivityOpenInShell
$script:AutoChart09LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart09LoginActivityManipulationPanel.controls.Add($script:AutoChart09LoginActivityOpenInShell)


$script:AutoChart09LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09LoginActivityOpenInShell.Location.X + $script:AutoChart09LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09LoginActivityViewResults
$script:AutoChart09LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart09LoginActivityManipulationPanel.controls.Add($script:AutoChart09LoginActivityViewResults)


### Save the chart to file
$script:AutoChart09LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart09LoginActivityOpenInShell.Location.Y + $script:AutoChart09LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09LoginActivity -Title $script:AutoChart09LoginActivityTitle
})
$script:AutoChart09LoginActivityManipulationPanel.controls.Add($script:AutoChart09LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart09LoginActivitySaveButton.Location.Y + $script:AutoChart09LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09LoginActivityManipulationPanel.Controls.Add($script:AutoChart09LoginActivityNoticeTextbox)

$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.Clear()
$script:AutoChart09LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09LoginActivity.Series["Profile Loaded"].Points.AddXY($_.DataField.ProfileLoaded,$_.UniqueCount)}    






















##############################################################################################
# AutoChart10
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10LoginActivity = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08LoginActivity.Location.X
                  Y = $script:AutoChart08LoginActivity.Location.Y + $script:AutoChart08LoginActivity.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10LoginActivity.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart10LoginActivityTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10LoginActivity.Titles.Add($script:AutoChart10LoginActivityTitle)

### Create Charts Area
$script:AutoChart10LoginActivityArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10LoginActivityArea.Name        = 'Chart Area'
#$script:AutoChart10LoginActivityArea.AxisX.Title = 'Hosts'
$script:AutoChart10LoginActivityArea.AxisX.Interval          = 1
$script:AutoChart10LoginActivityArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10LoginActivityArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10LoginActivityArea.Area3DStyle.Inclination = 75
$script:AutoChart10LoginActivity.ChartAreas.Add($script:AutoChart10LoginActivityArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10LoginActivity.Series.Add("Compression Mode")  
$script:AutoChart10LoginActivity.Series["Compression Mode"].Enabled           = $True
$script:AutoChart10LoginActivity.Series["Compression Mode"].BorderWidth       = 1
$script:AutoChart10LoginActivity.Series["Compression Mode"].IsVisibleInLegend = $false
$script:AutoChart10LoginActivity.Series["Compression Mode"].Chartarea         = 'Chart Area'
$script:AutoChart10LoginActivity.Series["Compression Mode"].Legend            = 'Legend'
$script:AutoChart10LoginActivity.Series["Compression Mode"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10LoginActivity.Series["Compression Mode"]['PieLineColor']   = 'Black'
$script:AutoChart10LoginActivity.Series["Compression Mode"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10LoginActivity.Series["Compression Mode"].ChartType         = 'Column'
$script:AutoChart10LoginActivity.Series["Compression Mode"].Color             = 'Red'

        function Generate-AutoChart10 {
            $script:AutoChart10LoginActivityCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart10LoginActivityUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'CompressionMode' | Sort-Object -Property 'CompressionMode' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10LoginActivityUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()

            if ($script:AutoChart10LoginActivityUniqueDataFields.count -gt 0){
                $script:AutoChart10LoginActivityTitle.ForeColor = 'Black'
                $script:AutoChart10LoginActivityTitle.Text = "Compression Mode"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart10LoginActivityOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10LoginActivityUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10LoginActivityCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.CompressionMode) -eq $DataField.CompressionMode) {
                            $Count += 1
                            if ( $script:AutoChart10LoginActivityCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart10LoginActivityCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart10LoginActivityUniqueCount = $script:AutoChart10LoginActivityCsvComputers.Count
                    $script:AutoChart10LoginActivityDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10LoginActivityUniqueCount
                        Computers   = $script:AutoChart10LoginActivityCsvComputers 
                    }
                    $script:AutoChart10LoginActivityOverallDataResults += $script:AutoChart10LoginActivityDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount) }

                $script:AutoChart10LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10LoginActivityOverallDataResults.count))
                $script:AutoChart10LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10LoginActivityOverallDataResults.count))
            }
            else {
                $script:AutoChart10LoginActivityTitle.ForeColor = 'Red'
                $script:AutoChart10LoginActivityTitle.Text = "Compression Mode`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart10

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart10LoginActivityOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10LoginActivity.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10LoginActivity.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10LoginActivityOptionsButton
$script:AutoChart10LoginActivityOptionsButton.Add_Click({  
    if ($script:AutoChart10LoginActivityOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10LoginActivityOptionsButton.Text = 'Options ^'
        $script:AutoChart10LoginActivity.Controls.Add($script:AutoChart10LoginActivityManipulationPanel)
    }
    elseif ($script:AutoChart10LoginActivityOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10LoginActivityOptionsButton.Text = 'Options v'
        $script:AutoChart10LoginActivity.Controls.Remove($script:AutoChart10LoginActivityManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10LoginActivityOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10LoginActivity)

$script:AutoChart10LoginActivityManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10LoginActivity.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10LoginActivity.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10LoginActivityTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10LoginActivityTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10LoginActivityTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10LoginActivityOverallDataResults.count))                
    $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10LoginActivityTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue = $script:AutoChart10LoginActivityTrimOffFirstTrackBar.Value
        $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10LoginActivityTrimOffFirstTrackBar.Value)"
        $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
        $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}    
    })
    $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Controls.Add($script:AutoChart10LoginActivityTrimOffFirstTrackBar)
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivityTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10LoginActivityTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Location.X + $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10LoginActivityTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10LoginActivityTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10LoginActivityTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10LoginActivityOverallDataResults.count))
    $script:AutoChart10LoginActivityTrimOffLastTrackBar.Value         = $($script:AutoChart10LoginActivityOverallDataResults.count)
    $script:AutoChart10LoginActivityTrimOffLastTrackBarValue   = 0
    $script:AutoChart10LoginActivityTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10LoginActivityTrimOffLastTrackBarValue = $($script:AutoChart10LoginActivityOverallDataResults.count) - $script:AutoChart10LoginActivityTrimOffLastTrackBar.Value
        $script:AutoChart10LoginActivityTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10LoginActivityOverallDataResults.count) - $script:AutoChart10LoginActivityTrimOffLastTrackBar.Value)"
        $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
        $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    })
$script:AutoChart10LoginActivityTrimOffLastGroupBox.Controls.Add($script:AutoChart10LoginActivityTrimOffLastTrackBar)
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivityTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10LoginActivityChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Location.Y + $script:AutoChart10LoginActivityTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10LoginActivityChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10LoginActivity.Series["Compression Mode"].ChartType = $script:AutoChart10LoginActivityChartTypeComboBox.SelectedItem
#    $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
#    $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
})
$script:AutoChart10LoginActivityChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10LoginActivityChartTypesAvailable) { $script:AutoChart10LoginActivityChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivityChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10LoginActivity3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10LoginActivityChartTypeComboBox.Location.X + $script:AutoChart10LoginActivityChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10LoginActivityChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10LoginActivity3DToggleButton
$script:AutoChart10LoginActivity3DInclination = 0
$script:AutoChart10LoginActivity3DToggleButton.Add_Click({
    $script:AutoChart10LoginActivity3DInclination += 10
    if ( $script:AutoChart10LoginActivity3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart10LoginActivityArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart10LoginActivity3DInclination
        $script:AutoChart10LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart10LoginActivity3DInclination)"
#        $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10LoginActivity3DInclination -le 90 ) {
        $script:AutoChart10LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart10LoginActivity3DInclination
        $script:AutoChart10LoginActivity3DToggleButton.Text  = "3D On ($script:AutoChart10LoginActivity3DInclination)" 
#        $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart10LoginActivity3DToggleButton.Text  = "3D Off" 
        $script:AutoChart10LoginActivity3DInclination = 0
        $script:AutoChart10LoginActivityArea.Area3DStyle.Inclination = $script:AutoChart10LoginActivity3DInclination
        $script:AutoChart10LoginActivityArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
#        $script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}
    }
})
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivity3DToggleButton)

### Change the color of the chart
$script:AutoChart10LoginActivityChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10LoginActivity3DToggleButton.Location.X + $script:AutoChart10LoginActivity3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LoginActivity3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10LoginActivityColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10LoginActivityColorsAvailable) { $script:AutoChart10LoginActivityChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10LoginActivityChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10LoginActivity.Series["Compression Mode"].Color = $script:AutoChart10LoginActivityChangeColorComboBox.SelectedItem
})
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivityChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart10LoginActivityImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'CompressionMode' -eq $($script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart10LoginActivityInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10LoginActivityImportCsvPosResults) { $script:AutoChart10LoginActivityInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10LoginActivityImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart10LoginActivityImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10LoginActivityImportCsvAll) { if ($Endpoint -notin $script:AutoChart10LoginActivityImportCsvPosResults) { $script:AutoChart10LoginActivityImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10LoginActivityInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10LoginActivityImportCsvNegResults) { $script:AutoChart10LoginActivityInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10LoginActivityImportCsvPosResults.count))"
    $script:AutoChart10LoginActivityInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10LoginActivityImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10LoginActivityCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10LoginActivityTrimOffLastGroupBox.Location.X + $script:AutoChart10LoginActivityTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LoginActivityTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10LoginActivityCheckDiffButton
$script:AutoChart10LoginActivityCheckDiffButton.Add_Click({
    $script:AutoChart10LoginActivityInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'CompressionMode' -ExpandProperty 'CompressionMode' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10LoginActivityInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10LoginActivityInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10LoginActivityInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LoginActivityInvestDiffDropDownLabel.Location.y + $script:AutoChart10LoginActivityInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10LoginActivityInvestDiffDropDownArray) { $script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Execute Button
    $script:AutoChart10LoginActivityInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Location.y + $script:AutoChart10LoginActivityInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100 
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10LoginActivityInvestDiffExecuteButton
    $script:AutoChart10LoginActivityInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10LoginActivityInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10LoginActivityInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LoginActivityInvestDiffExecuteButton.Location.y + $script:AutoChart10LoginActivityInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart10LoginActivityInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Location.y + $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10LoginActivityInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Location.x + $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart10LoginActivityInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10LoginActivityInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10LoginActivityInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10LoginActivityInvestDiffNegResultsLabel.Location.y + $script:AutoChart10LoginActivityInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10LoginActivityInvestDiffForm.Controls.AddRange(@($script:AutoChart10LoginActivityInvestDiffDropDownLabel,$script:AutoChart10LoginActivityInvestDiffDropDownComboBox,$script:AutoChart10LoginActivityInvestDiffExecuteButton,$script:AutoChart10LoginActivityInvestDiffPosResultsLabel,$script:AutoChart10LoginActivityInvestDiffPosResultsTextBox,$script:AutoChart10LoginActivityInvestDiffNegResultsLabel,$script:AutoChart10LoginActivityInvestDiffNegResultsTextBox))
    $script:AutoChart10LoginActivityInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10LoginActivityInvestDiffForm.ShowDialog()
})
$script:AutoChart10LoginActivityCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10LoginActivityManipulationPanel.controls.Add($script:AutoChart10LoginActivityCheckDiffButton)
    

$AutoChart10ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10LoginActivityCheckDiffButton.Location.X + $script:AutoChart10LoginActivityCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10LoginActivityCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FileProfileLoaded $script:AutoChartDataSourceCsvFileName -QueryName "Current Login Activity" -QueryTabName "Compression Mode" -PropertyX "CompressionMode" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart10ExpandChartButton
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($AutoChart10ExpandChartButton)


$script:AutoChart10LoginActivityOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10LoginActivityCheckDiffButton.Location.X
                   Y = $script:AutoChart10LoginActivityCheckDiffButton.Location.Y + $script:AutoChart10LoginActivityCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10LoginActivityOpenInShell
$script:AutoChart10LoginActivityOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart10LoginActivityManipulationPanel.controls.Add($script:AutoChart10LoginActivityOpenInShell)


$script:AutoChart10LoginActivityViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10LoginActivityOpenInShell.Location.X + $script:AutoChart10LoginActivityOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10LoginActivityOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10LoginActivityViewResults
$script:AutoChart10LoginActivityViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart10LoginActivityManipulationPanel.controls.Add($script:AutoChart10LoginActivityViewResults)


### Save the chart to file
$script:AutoChart10LoginActivitySaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10LoginActivityOpenInShell.Location.X
                  Y = $script:AutoChart10LoginActivityOpenInShell.Location.Y + $script:AutoChart10LoginActivityOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10LoginActivitySaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10LoginActivitySaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10LoginActivity -Title $script:AutoChart10LoginActivityTitle
})
$script:AutoChart10LoginActivityManipulationPanel.controls.Add($script:AutoChart10LoginActivitySaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10LoginActivityNoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10LoginActivitySaveButton.Location.X 
                        Y = $script:AutoChart10LoginActivitySaveButton.Location.Y + $script:AutoChart10LoginActivitySaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10LoginActivityCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10LoginActivityManipulationPanel.Controls.Add($script:AutoChart10LoginActivityNoticeTextbox)

$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.Clear()
$script:AutoChart10LoginActivityOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10LoginActivityTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10LoginActivityTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10LoginActivity.Series["Compression Mode"].Points.AddXY($_.DataField.CompressionMode,$_.UniqueCount)}    



