$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Process Info'
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

$script:AutoChart01ProcessesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Processes') { $script:AutoChart01ProcessesCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ProcessesCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart01Processes.Controls.Remove($script:AutoChart01ProcessesManipulationPanel)
    $script:AutoChart02ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart02Processes.Controls.Remove($script:AutoChart02ProcessesManipulationPanel)
    $script:AutoChart03ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart03Processes.Controls.Remove($script:AutoChart03ProcessesManipulationPanel)
    $script:AutoChart04ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart04Processes.Controls.Remove($script:AutoChart04ProcessesManipulationPanel)
    $script:AutoChart05ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart05Processes.Controls.Remove($script:AutoChart05ProcessesManipulationPanel)
    $script:AutoChart06ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart06Processes.Controls.Remove($script:AutoChart06ProcessesManipulationPanel)
    $script:AutoChart07ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart07Processes.Controls.Remove($script:AutoChart07ProcessesManipulationPanel)
    $script:AutoChart08ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart08Processes.Controls.Remove($script:AutoChart08ProcessesManipulationPanel)
    $script:AutoChart09ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart09Processes.Controls.Remove($script:AutoChart09ProcessesManipulationPanel)
    $script:AutoChart10ProcessesOptionsButton.Text = 'Options v'
    $script:AutoChart10Processes.Controls.Remove($script:AutoChart10ProcessesManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Process Info'
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
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-ACME')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsProcesses -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsProcesses -ComputerNameList $script:ComputerList }
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
# AutoChart01
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01Processes.Titles.Add($script:AutoChart01ProcessesTitle)

### Create Charts Area
$script:AutoChart01ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ProcessesArea.Name        = 'Chart Area'
$script:AutoChart01ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart01ProcessesArea.AxisX.Interval          = 1
$script:AutoChart01ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart01Processes.ChartAreas.Add($script:AutoChart01ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01Processes.Series.Add("Unique Processes")
$script:AutoChart01Processes.Series["Unique Processes"].Enabled           = $True
$script:AutoChart01Processes.Series["Unique Processes"].BorderWidth       = 1
$script:AutoChart01Processes.Series["Unique Processes"].IsVisibleInLegend = $false
$script:AutoChart01Processes.Series["Unique Processes"].Chartarea         = 'Chart Area'
$script:AutoChart01Processes.Series["Unique Processes"].Legend            = 'Legend'
$script:AutoChart01Processes.Series["Unique Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01Processes.Series["Unique Processes"]['PieLineColor']   = 'Black'
$script:AutoChart01Processes.Series["Unique Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01Processes.Series["Unique Processes"].ChartType         = 'Column'
$script:AutoChart01Processes.Series["Unique Processes"].Color             = 'Red'

        function Generate-AutoChart01 {
            $script:AutoChart01ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart01ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()

            if ($script:AutoChart01ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart01ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart01ProcessesTitle.Text = "Unique Processes"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart01ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ProcessesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart01ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart01ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart01ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ProcessesCsvComputers.Count
                        Computers   = $script:AutoChart01ProcessesCsvComputers
                    }
                    $script:AutoChart01ProcessesOverallDataResults += $script:AutoChart01ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart01ProcessesSortButton.text = "View: AlphaNum"
                $script:AutoChart01ProcessesOverallDataResultsSortAlphaNum = $script:AutoChart01ProcessesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField.Name};Descending=$false}
                $script:AutoChart01ProcessesOverallDataResultsSortCount    = $script:AutoChart01ProcessesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField.Name};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart01ProcessesOverallDataResults = $script:AutoChart01ProcessesOverallDataResultsSortCount

                $script:AutoChart01ProcessesOverallDataResults | ForEach-Object { $script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                $script:AutoChart01ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ProcessesOverallDataResults.count))
                $script:AutoChart01ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart01ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart01ProcessesTitle.Text = "Unique Processes`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ProcessesOptionsButton
$script:AutoChart01ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart01ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart01Processes.Controls.Add($script:AutoChart01ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart01ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart01Processes.Controls.Remove($script:AutoChart01ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01Processes)

$script:AutoChart01ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ProcessesOverallDataResults.count))
    $script:AutoChart01ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ProcessesTrimOffFirstTrackBarValue = $script:AutoChart01ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart01ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ProcessesTrimOffFirstTrackBar)
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart01ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ProcessesOverallDataResults.count))
    $script:AutoChart01ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart01ProcessesOverallDataResults.count)
    $script:AutoChart01ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart01ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ProcessesTrimOffLastTrackBarValue = $($script:AutoChart01ProcessesOverallDataResults.count) - $script:AutoChart01ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart01ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ProcessesOverallDataResults.count) - $script:AutoChart01ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart01ProcessesTrimOffLastTrackBar)
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Processes.Series["Unique Processes"].ChartType = $script:AutoChart01ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
#    $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ProcessesChartTypesAvailable) { $script:AutoChart01ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01ProcessesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ProcessesChartTypeComboBox.Location.X + $script:AutoChart01ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01Processes3DToggleButton
$script:AutoChart01Processes3DInclination = 0
$script:AutoChart01Processes3DToggleButton.Add_Click({

    $script:AutoChart01Processes3DInclination += 10
    if ( $script:AutoChart01Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ProcessesArea.Area3DStyle.Inclination = $script:AutoChart01Processes3DInclination
        $script:AutoChart01Processes3DToggleButton.Text  = "3D On ($script:AutoChart01Processes3DInclination)"
#        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01Processes3DInclination -le 90 ) {
        $script:AutoChart01ProcessesArea.Area3DStyle.Inclination = $script:AutoChart01Processes3DInclination
        $script:AutoChart01Processes3DToggleButton.Text  = "3D On ($script:AutoChart01Processes3DInclination)"
#        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart01Processes3DInclination = 0
        $script:AutoChart01ProcessesArea.Area3DStyle.Inclination = $script:AutoChart01Processes3DInclination
        $script:AutoChart01ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
#        $script:AutoChart01ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart01ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01Processes3DToggleButton.Location.X + $script:AutoChart01Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ProcessesColorsAvailable) { $script:AutoChart01ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Processes.Series["Unique Processes"].Color = $script:AutoChart01ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01ProcessesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {
    # List of Positive Endpoints that positively match
    $script:AutoChart01ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart01ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart01ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ProcessesImportCsvPosResults) { $script:AutoChart01ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart01ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ProcessesImportCsvPosResults) { $script:AutoChart01ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ProcessesImportCsvNegResults) { $script:AutoChart01ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ProcessesImportCsvPosResults.count))"
    $script:AutoChart01ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart01ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01ProcessesCheckDiffButton
$script:AutoChart01ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart01ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart01ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ProcessesInvestDiffDropDownArray) { $script:AutoChart01ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01ProcessesInvestDiffExecuteButton
    $script:AutoChart01ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart01ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart01ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart01ProcessesInvestDiffDropDownLabel,$script:AutoChart01ProcessesInvestDiffDropDownComboBox,$script:AutoChart01ProcessesInvestDiffExecuteButton,$script:AutoChart01ProcessesInvestDiffPosResultsLabel,$script:AutoChart01ProcessesInvestDiffPosResultsTextBox,$script:AutoChart01ProcessesInvestDiffNegResultsLabel,$script:AutoChart01ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart01ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart01ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ProcessesManipulationPanel.controls.Add($script:AutoChart01ProcessesCheckDiffButton)


$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ProcessesCheckDiffButton.Location.X + $script:AutoChart01ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Unique Processes" -PropertyX "Name" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart01ExpandChartButton
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($AutoChart01ExpandChartButton)


$script:AutoChart01ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart01ProcessesCheckDiffButton.Location.Y + $script:AutoChart01ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ProcessesOpenInShell
$script:AutoChart01ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01ProcessesManipulationPanel.controls.Add($script:AutoChart01ProcessesOpenInShell)



$script:AutoChart01ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart01ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart01ProcessesOpenInShell.Location.Y + $script:AutoChart01ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ProcessesSortButton
$script:AutoChart01ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart01ProcessesOverallDataResults = $script:AutoChart01ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01ProcessesOverallDataResults | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart01ProcessesOverallDataResults = $script:AutoChart01ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
        $script:AutoChart01Processes.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01ProcessesOverallDataResults | Select-Object -skip $script:AutoChart01ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ProcessesTrimOffLastTrackBarValue | ForEach-Object { $script:AutoChart01Processes.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
    }
})
$script:AutoChart01ProcessesManipulationPanel.controls.Add($script:AutoChart01ProcessesSortButton)


$script:AutoChart01ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ProcessesOpenInShell.Location.X + $script:AutoChart01ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ProcessesViewResults
$script:AutoChart01ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart01ProcessesManipulationPanel.controls.Add($script:AutoChart01ProcessesViewResults)


### Save the chart to file
$script:AutoChart01ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ProcessesViewResults.Location.X
                  Y = $script:AutoChart01ProcessesViewResults.Location.Y + $script:AutoChart01ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01Processes -Title $script:AutoChart01ProcessesTitle
})
$script:AutoChart01ProcessesManipulationPanel.controls.Add($script:AutoChart01ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ProcessesSortButton.Location.X
                        Y = $script:AutoChart01ProcessesSortButton.Location.Y + $script:AutoChart01ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ProcessesManipulationPanel.Controls.Add($script:AutoChart01ProcessesNoticeTextbox)






















##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Processes.Location.X + $script:AutoChart01Processes.Size.Width + $($FormScale *  20)
                  Y = $script:AutoChart01Processes.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02Processes.Titles.Add($script:AutoChart02ProcessesTitle)

### Create Charts Area
$script:AutoChart02ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ProcessesArea.Name        = 'Chart Area'
$script:AutoChart02ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart02ProcessesArea.AxisX.Interval          = 1
$script:AutoChart02ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart02Processes.ChartAreas.Add($script:AutoChart02ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02Processes.Series.Add("Processes Per Host")
$script:AutoChart02Processes.Series["Processes Per Host"].Enabled           = $True
$script:AutoChart02Processes.Series["Processes Per Host"].BorderWidth       = 1
$script:AutoChart02Processes.Series["Processes Per Host"].IsVisibleInLegend = $false
$script:AutoChart02Processes.Series["Processes Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02Processes.Series["Processes Per Host"].Legend            = 'Legend'
$script:AutoChart02Processes.Series["Processes Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02Processes.Series["Processes Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02Processes.Series["Processes Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02Processes.Series["Processes Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02Processes.Series["Processes Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 {
            $script:AutoChart02ProcessesCsvFileHosts     = ($script:AutoChartDataSourceCsv).ComputerName | Sort-Object -Unique
            $script:AutoChart02ProcessesUniqueDataFields = ($script:AutoChartDataSourceCsv).ProcessID | Sort-Object -Property 'ProcessID'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart02ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart02ProcessesTitle.Text = "Processes Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02ProcessesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object ComputerName) ) {
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.ComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) {
                        if ( $Line.ComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.ComputerName ) { $AutoChart02Computer = $Line.ComputerName }
                            }
                        }
                        elseif ( $Line.ComputerName -ne $AutoChart02CurrentComputer ) {
                            $AutoChart02CurrentComputer = $Line.ComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer
                            }
                            $script:AutoChart02ProcessesOverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $Line.ProcessID ) {
                                if ( $Line.ProcessID -ne "" ) { $AutoChart02YResults += $Line.ProcessID ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.ComputerName ) { $AutoChart02Computer = $Line.ComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }
                $script:AutoChart02ProcessesOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02ProcessesOverallDataResults | ForEach-Object { $script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
                $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ProcessesOverallDataResults.count))
                $script:AutoChart02ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
                $script:AutoChart02ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart02ProcessesTitle.Text = "Processes Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ProcessesOptionsButton
$script:AutoChart02ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart02ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart02Processes.Controls.Add($script:AutoChart02ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart02ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart02Processes.Controls.Remove($script:AutoChart02ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02Processes)

$script:AutoChart02ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ProcessesOverallDataResults.count))
    $script:AutoChart02ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ProcessesTrimOffFirstTrackBarValue = $script:AutoChart02ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart02ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
        $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ProcessesTrimOffFirstTrackBar)
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart02ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ProcessesOverallDataResults.count))
    $script:AutoChart02ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart02ProcessesOverallDataResults.count)
    $script:AutoChart02ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ProcessesTrimOffLastTrackBarValue = $($script:AutoChart02ProcessesOverallDataResults.count) - $script:AutoChart02ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart02ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ProcessesOverallDataResults.count) - $script:AutoChart02ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
        $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart02ProcessesTrimOffLastTrackBar)
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Processes.Series["Processes Per Host"].ChartType = $script:AutoChart02ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
#    $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ProcessesChartTypesAvailable) { $script:AutoChart02ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ProcessesChartTypeComboBox.Location.X + $script:AutoChart02ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02Processes3DToggleButton
$script:AutoChart02Processes3DInclination = 0
$script:AutoChart02Processes3DToggleButton.Add_Click({
    $script:AutoChart02Processes3DInclination += 10
    if ( $script:AutoChart02Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ProcessesArea.Area3DStyle.Inclination = $script:AutoChart02Processes3DInclination
        $script:AutoChart02Processes3DToggleButton.Text  = "3D On ($script:AutoChart02Processes3DInclination)"
#        $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02Processes3DInclination -le 90 ) {
        $script:AutoChart02ProcessesArea.Area3DStyle.Inclination = $script:AutoChart02Processes3DInclination
        $script:AutoChart02Processes3DToggleButton.Text  = "3D On ($script:AutoChart02Processes3DInclination)"
#        $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart02Processes3DInclination = 0
        $script:AutoChart02ProcessesArea.Area3DStyle.Inclination = $script:AutoChart02Processes3DInclination
        $script:AutoChart02ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02Processes.Series["Processes Per Host"].Points.Clear()
#        $script:AutoChart02ProcessesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Processes Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart02ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02Processes3DToggleButton.Location.X + $script:AutoChart02Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ProcessesColorsAvailable) { $script:AutoChart02ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Processes.Series["Processes Per Host"].Color = $script:AutoChart02ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02ProcessesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart02ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart02ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ProcessesImportCsvPosResults) { $script:AutoChart02ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart02ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ProcessesImportCsvPosResults) { $script:AutoChart02ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ProcessesImportCsvNegResults) { $script:AutoChart02ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ProcessesImportCsvPosResults.count))"
    $script:AutoChart02ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart02ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02ProcessesCheckDiffButton
$script:AutoChart02ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart02ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart02ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ProcessesInvestDiffDropDownArray) { $script:AutoChart02ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02ProcessesInvestDiffExecuteButton
    $script:AutoChart02ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart02ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart02ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart02ProcessesInvestDiffDropDownLabel,$script:AutoChart02ProcessesInvestDiffDropDownComboBox,$script:AutoChart02ProcessesInvestDiffExecuteButton,$script:AutoChart02ProcessesInvestDiffPosResultsLabel,$script:AutoChart02ProcessesInvestDiffPosResultsTextBox,$script:AutoChart02ProcessesInvestDiffNegResultsLabel,$script:AutoChart02ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart02ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart02ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ProcessesManipulationPanel.controls.Add($script:AutoChart02ProcessesCheckDiffButton)


$AutoChart02ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ProcessesCheckDiffButton.Location.X + $script:AutoChart02ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Processes per Endpoint" -PropertyX "ComputerName" -PropertyY "ProcessID" }
}
CommonButtonSettings -Button $AutoChart02ExpandChartButton
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($AutoChart02ExpandChartButton)


$script:AutoChart02ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart02ProcessesCheckDiffButton.Location.Y + $script:AutoChart02ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ProcessesOpenInShell
$script:AutoChart02ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02ProcessesManipulationPanel.controls.Add($script:AutoChart02ProcessesOpenInShell)



$script:AutoChart02ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart02ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart02ProcessesOpenInShell.Location.Y + $script:AutoChart02ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ProcessesSortButton
$script:AutoChart02ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart02ProcessesOverallDataResults = $script:AutoChart02ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart02ProcessesOverallDataResults = $script:AutoChart02ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart02Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart02ProcessesOverallDataResults | Select-Object -skip $script:AutoChart02ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ProcessesManipulationPanel.controls.Add($script:AutoChart02ProcessesSortButton)


$script:AutoChart02ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ProcessesOpenInShell.Location.X + $script:AutoChart02ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ProcessesViewResults
$script:AutoChart02ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart02ProcessesManipulationPanel.controls.Add($script:AutoChart02ProcessesViewResults)


### Save the chart to file
$script:AutoChart02ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ProcessesViewResults.Location.X
                  Y = $script:AutoChart02ProcessesViewResults.Location.Y + $script:AutoChart02ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02Processes -Title $script:AutoChart02ProcessesTitle
})
$script:AutoChart02ProcessesManipulationPanel.controls.Add($script:AutoChart02ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ProcessesSortButton.Location.X
                        Y = $script:AutoChart02ProcessesSortButton.Location.Y + $script:AutoChart02ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ProcessesManipulationPanel.Controls.Add($script:AutoChart02ProcessesNoticeTextbox)



















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Processes.Location.X
                  Y = $script:AutoChart01Processes.Location.Y + $script:AutoChart01Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03Processes.Titles.Add($script:AutoChart03ProcessesTitle)

### Create Charts Area
$script:AutoChart03ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ProcessesArea.Name        = 'Chart Area'
$script:AutoChart03ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart03ProcessesArea.AxisX.Interval          = 1
$script:AutoChart03ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart03Processes.ChartAreas.Add($script:AutoChart03ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03Processes.Series.Add("Process Company")
$script:AutoChart03Processes.Series["Process Company"].Enabled           = $True
$script:AutoChart03Processes.Series["Process Company"].BorderWidth       = 1
$script:AutoChart03Processes.Series["Process Company"].IsVisibleInLegend = $false
$script:AutoChart03Processes.Series["Process Company"].Chartarea         = 'Chart Area'
$script:AutoChart03Processes.Series["Process Company"].Legend            = 'Legend'
$script:AutoChart03Processes.Series["Process Company"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03Processes.Series["Process Company"]['PieLineColor']   = 'Black'
$script:AutoChart03Processes.Series["Process Company"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03Processes.Series["Process Company"].ChartType         = 'Column'
$script:AutoChart03Processes.Series["Process Company"].Color             = 'Green'

        function Generate-AutoChart03 {
            $script:AutoChart03ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart03ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Company' | Sort-Object -Property 'Company' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03Processes.Series["Process Company"].Points.Clear()

            if ($script:AutoChart03ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart03ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart03ProcessesTitle.Text = "Process Company"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart03ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ProcessesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Company -eq $DataField.Company) {
                            $Count += 1
                            if ( $script:AutoChart03ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart03ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart03ProcessesUniqueCount = $script:AutoChart03ProcessesCsvComputers.Count
                    $script:AutoChart03ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ProcessesUniqueCount
                        Computers   = $script:AutoChart03ProcessesCsvComputers
                    }
                    $script:AutoChart03ProcessesOverallDataResults += $script:AutoChart03ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount) }

                $script:AutoChart03ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ProcessesOverallDataResults.count))
                $script:AutoChart03ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart03ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart03ProcessesTitle.Text = "Process Company`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ProcessesOptionsButton
$script:AutoChart03ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart03ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart03Processes.Controls.Add($script:AutoChart03ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart03ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart03Processes.Controls.Remove($script:AutoChart03ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03Processes)

$script:AutoChart03ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ProcessesOverallDataResults.count))
    $script:AutoChart03ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ProcessesTrimOffFirstTrackBarValue = $script:AutoChart03ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart03ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
        $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
    })
    $script:AutoChart03ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ProcessesTrimOffFirstTrackBar)
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart03ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ProcessesOverallDataResults.count))
    $script:AutoChart03ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart03ProcessesOverallDataResults.count)
    $script:AutoChart03ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ProcessesTrimOffLastTrackBarValue = $($script:AutoChart03ProcessesOverallDataResults.count) - $script:AutoChart03ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart03ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ProcessesOverallDataResults.count) - $script:AutoChart03ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
        $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
    })
$script:AutoChart03ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart03ProcessesTrimOffLastTrackBar)
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Processes.Series["Process Company"].ChartType = $script:AutoChart03ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
#    $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
})
$script:AutoChart03ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ProcessesChartTypesAvailable) { $script:AutoChart03ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ProcessesChartTypeComboBox.Location.X + $script:AutoChart03ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03Processes3DToggleButton
$script:AutoChart03Processes3DInclination = 0
$script:AutoChart03Processes3DToggleButton.Add_Click({
    $script:AutoChart03Processes3DInclination += 10
    if ( $script:AutoChart03Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ProcessesArea.Area3DStyle.Inclination = $script:AutoChart03Processes3DInclination
        $script:AutoChart03Processes3DToggleButton.Text  = "3D On ($script:AutoChart03Processes3DInclination)"
#        $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
#        $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03Processes3DInclination -le 90 ) {
        $script:AutoChart03ProcessesArea.Area3DStyle.Inclination = $script:AutoChart03Processes3DInclination
        $script:AutoChart03Processes3DToggleButton.Text  = "3D On ($script:AutoChart03Processes3DInclination)"
#        $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
#        $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart03Processes3DInclination = 0
        $script:AutoChart03ProcessesArea.Area3DStyle.Inclination = $script:AutoChart03Processes3DInclination
        $script:AutoChart03ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03Processes.Series["Process Company"].Points.Clear()
#        $script:AutoChart03ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Process Company"].Points.AddXY($_.DataField.Company,$_.UniqueCount)}
    }
})
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart03ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03Processes3DToggleButton.Location.X + $script:AutoChart03Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ProcessesColorsAvailable) { $script:AutoChart03ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Processes.Series["Process Company"].Color = $script:AutoChart03ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03ProcessesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Company' -eq $($script:AutoChart03ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart03ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ProcessesImportCsvPosResults) { $script:AutoChart03ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart03ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ProcessesImportCsvPosResults) { $script:AutoChart03ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ProcessesImportCsvNegResults) { $script:AutoChart03ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ProcessesImportCsvPosResults.count))"
    $script:AutoChart03ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart03ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03ProcessesCheckDiffButton
$script:AutoChart03ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart03ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Company' -ExpandProperty 'Company' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart03ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ProcessesInvestDiffDropDownArray) { $script:AutoChart03ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03ProcessesInvestDiffExecuteButton
    $script:AutoChart03ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart03ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart03ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart03ProcessesInvestDiffDropDownLabel,$script:AutoChart03ProcessesInvestDiffDropDownComboBox,$script:AutoChart03ProcessesInvestDiffExecuteButton,$script:AutoChart03ProcessesInvestDiffPosResultsLabel,$script:AutoChart03ProcessesInvestDiffPosResultsTextBox,$script:AutoChart03ProcessesInvestDiffNegResultsLabel,$script:AutoChart03ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart03ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart03ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ProcessesManipulationPanel.controls.Add($script:AutoChart03ProcessesCheckDiffButton)


$AutoChart03ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ProcessesCheckDiffButton.Location.X + $script:AutoChart03ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process Company" -PropertyX "Company" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart03ExpandChartButton
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($AutoChart03ExpandChartButton)


$script:AutoChart03ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart03ProcessesCheckDiffButton.Location.Y + $script:AutoChart03ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ProcessesOpenInShell
$script:AutoChart03ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03ProcessesManipulationPanel.controls.Add($script:AutoChart03ProcessesOpenInShell)



$script:AutoChart03ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart03ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart03ProcessesOpenInShell.Location.Y + $script:AutoChart03ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ProcessesSortButton
$script:AutoChart03ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart03ProcessesOverallDataResults = $script:AutoChart03ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart03ProcessesOverallDataResults = $script:AutoChart03ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart03Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart03ProcessesOverallDataResults | Select-Object -skip $script:AutoChart03ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart03ProcessesManipulationPanel.controls.Add($script:AutoChart03ProcessesSortButton)


$script:AutoChart03ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ProcessesOpenInShell.Location.X + $script:AutoChart03ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ProcessesViewResults
$script:AutoChart03ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart03ProcessesManipulationPanel.controls.Add($script:AutoChart03ProcessesViewResults)


### Save the chart to file
$script:AutoChart03ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ProcessesViewResults.Location.X
                  Y = $script:AutoChart03ProcessesViewResults.Location.Y + $script:AutoChart03ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03Processes -Title $script:AutoChart03ProcessesTitle
})
$script:AutoChart03ProcessesManipulationPanel.controls.Add($script:AutoChart03ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ProcessesSortButton.Location.X
                        Y = $script:AutoChart03ProcessesSortButton.Location.Y + $script:AutoChart03ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ProcessesManipulationPanel.Controls.Add($script:AutoChart03ProcessesNoticeTextbox)




















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02Processes.Location.X
                  Y = $script:AutoChart02Processes.Location.Y + $script:AutoChart02Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04Processes.Titles.Add($script:AutoChart04ProcessesTitle)

### Create Charts Area
$script:AutoChart04ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ProcessesArea.Name        = 'Chart Area'
$script:AutoChart04ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart04ProcessesArea.AxisX.Interval          = 1
$script:AutoChart04ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart04Processes.ChartAreas.Add($script:AutoChart04ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04Processes.Series.Add("Process Product")
$script:AutoChart04Processes.Series["Process Product"].Enabled           = $True
$script:AutoChart04Processes.Series["Process Product"].BorderWidth       = 1
$script:AutoChart04Processes.Series["Process Product"].IsVisibleInLegend = $false
$script:AutoChart04Processes.Series["Process Product"].Chartarea         = 'Chart Area'
$script:AutoChart04Processes.Series["Process Product"].Legend            = 'Legend'
$script:AutoChart04Processes.Series["Process Product"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04Processes.Series["Process Product"]['PieLineColor']   = 'Black'
$script:AutoChart04Processes.Series["Process Product"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04Processes.Series["Process Product"].ChartType         = 'Column'
$script:AutoChart04Processes.Series["Process Product"].Color             = 'Orange'

        function Generate-AutoChart04 {
            $script:AutoChart04ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart04ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Product' | Sort-Object -Property 'Product' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04Processes.Series["Process Product"].Points.Clear()

            if ($script:AutoChart04ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart04ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart04ProcessesTitle.Text = "Process Product"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart04ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ProcessesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Product) -eq $DataField.Product) {
                            $Count += 1
                            if ( $script:AutoChart04ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart04ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart04ProcessesUniqueCount = $script:AutoChart04ProcessesCsvComputers.Count
                    $script:AutoChart04ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ProcessesUniqueCount
                        Computers   = $script:AutoChart04ProcessesCsvComputers
                    }
                    $script:AutoChart04ProcessesOverallDataResults += $script:AutoChart04ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount) }

                $script:AutoChart04ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ProcessesOverallDataResults.count))
                $script:AutoChart04ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart04ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart04ProcessesTitle.Text = "Process Product`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ProcessesOptionsButton
$script:AutoChart04ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart04ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart04Processes.Controls.Add($script:AutoChart04ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart04ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart04Processes.Controls.Remove($script:AutoChart04ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04Processes)

$script:AutoChart04ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ProcessesOverallDataResults.count))
    $script:AutoChart04ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ProcessesTrimOffFirstTrackBarValue = $script:AutoChart04ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart04ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
        $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
    })
    $script:AutoChart04ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ProcessesTrimOffFirstTrackBar)
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart04ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart04ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ProcessesOverallDataResults.count))
    $script:AutoChart04ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart04ProcessesOverallDataResults.count)
    $script:AutoChart04ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ProcessesTrimOffLastTrackBarValue = $($script:AutoChart04ProcessesOverallDataResults.count) - $script:AutoChart04ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart04ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ProcessesOverallDataResults.count) - $script:AutoChart04ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
        $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
    })
$script:AutoChart04ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart04ProcessesTrimOffLastTrackBar)
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Processes.Series["Process Product"].ChartType = $script:AutoChart04ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
#    $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
})
$script:AutoChart04ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ProcessesChartTypesAvailable) { $script:AutoChart04ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ProcessesChartTypeComboBox.Location.X + $script:AutoChart04ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04Processes3DToggleButton
$script:AutoChart04Processes3DInclination = 0
$script:AutoChart04Processes3DToggleButton.Add_Click({
    $script:AutoChart04Processes3DInclination += 10
    if ( $script:AutoChart04Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ProcessesArea.Area3DStyle.Inclination = $script:AutoChart04Processes3DInclination
        $script:AutoChart04Processes3DToggleButton.Text  = "3D On ($script:AutoChart04Processes3DInclination)"
#        $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
#        $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04Processes3DInclination -le 90 ) {
        $script:AutoChart04ProcessesArea.Area3DStyle.Inclination = $script:AutoChart04Processes3DInclination
        $script:AutoChart04Processes3DToggleButton.Text  = "3D On ($script:AutoChart04Processes3DInclination)"
#        $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
#        $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart04Processes3DInclination = 0
        $script:AutoChart04ProcessesArea.Area3DStyle.Inclination = $script:AutoChart04Processes3DInclination
        $script:AutoChart04ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04Processes.Series["Process Product"].Points.Clear()
#        $script:AutoChart04ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Process Product"].Points.AddXY($_.DataField.Product,$_.UniqueCount)}
    }
})
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart04ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04Processes3DToggleButton.Location.X + $script:AutoChart04Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ProcessesColorsAvailable) { $script:AutoChart04ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Processes.Series["Process Product"].Color = $script:AutoChart04ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04ProcessesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Product' -eq $($script:AutoChart04ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart04ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ProcessesImportCsvPosResults) { $script:AutoChart04ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart04ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ProcessesImportCsvPosResults) { $script:AutoChart04ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ProcessesImportCsvNegResults) { $script:AutoChart04ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ProcessesImportCsvPosResults.count))"
    $script:AutoChart04ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart04ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04ProcessesCheckDiffButton
$script:AutoChart04ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart04ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Product' -ExpandProperty 'Product' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart04ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ProcessesInvestDiffDropDownArray) { $script:AutoChart04ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04ProcessesInvestDiffExecuteButton
    $script:AutoChart04ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart04ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart04ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart04ProcessesInvestDiffDropDownLabel,$script:AutoChart04ProcessesInvestDiffDropDownComboBox,$script:AutoChart04ProcessesInvestDiffExecuteButton,$script:AutoChart04ProcessesInvestDiffPosResultsLabel,$script:AutoChart04ProcessesInvestDiffPosResultsTextBox,$script:AutoChart04ProcessesInvestDiffNegResultsLabel,$script:AutoChart04ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart04ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart04ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ProcessesManipulationPanel.controls.Add($script:AutoChart04ProcessesCheckDiffButton)


$AutoChart04ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ProcessesCheckDiffButton.Location.X + $script:AutoChart04ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process Product" -PropertyX "Product" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart04ExpandChartButton
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($AutoChart04ExpandChartButton)


$script:AutoChart04ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart04ProcessesCheckDiffButton.Location.Y + $script:AutoChart04ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ProcessesOpenInShell
$script:AutoChart04ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04ProcessesManipulationPanel.controls.Add($script:AutoChart04ProcessesOpenInShell)



$script:AutoChart04ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart04ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart04ProcessesOpenInShell.Location.Y + $script:AutoChart04ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ProcessesSortButton
$script:AutoChart04ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart04ProcessesOverallDataResults = $script:AutoChart04ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart04ProcessesOverallDataResults = $script:AutoChart04ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart04Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart04ProcessesOverallDataResults | Select-Object -skip $script:AutoChart04ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart04ProcessesManipulationPanel.controls.Add($script:AutoChart04ProcessesSortButton)


$script:AutoChart04ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ProcessesOpenInShell.Location.X + $script:AutoChart04ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ProcessesViewResults
$script:AutoChart04ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart04ProcessesManipulationPanel.controls.Add($script:AutoChart04ProcessesViewResults)


### Save the chart to file
$script:AutoChart04ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ProcessesViewResults.Location.X
                  Y = $script:AutoChart04ProcessesViewResults.Location.Y + $script:AutoChart04ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04Processes -Title $script:AutoChart04ProcessesTitle
})
$script:AutoChart04ProcessesManipulationPanel.controls.Add($script:AutoChart04ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ProcessesSortButton.Location.X
                        Y = $script:AutoChart04ProcessesSortButton.Location.Y + $script:AutoChart04ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ProcessesManipulationPanel.Controls.Add($script:AutoChart04ProcessesNoticeTextbox)


















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03Processes.Location.X
                  Y = $script:AutoChart03Processes.Location.Y + $script:AutoChart03Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05Processes.Titles.Add($script:AutoChart05ProcessesTitle)

### Create Charts Area
$script:AutoChart05ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ProcessesArea.Name        = 'Chart Area'
$script:AutoChart05ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart05ProcessesArea.AxisX.Interval          = 1
$script:AutoChart05ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart05Processes.ChartAreas.Add($script:AutoChart05ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05Processes.Series.Add("Processes with Network Activity")
$script:AutoChart05Processes.Series["Processes with Network Activity"].Enabled           = $True
$script:AutoChart05Processes.Series["Processes with Network Activity"].BorderWidth       = 1
$script:AutoChart05Processes.Series["Processes with Network Activity"].IsVisibleInLegend = $false
$script:AutoChart05Processes.Series["Processes with Network Activity"].Chartarea         = 'Chart Area'
$script:AutoChart05Processes.Series["Processes with Network Activity"].Legend            = 'Legend'
$script:AutoChart05Processes.Series["Processes with Network Activity"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05Processes.Series["Processes with Network Activity"]['PieLineColor']   = 'Black'
$script:AutoChart05Processes.Series["Processes with Network Activity"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05Processes.Series["Processes with Network Activity"].ChartType         = 'Column'
$script:AutoChart05Processes.Series["Processes with Network Activity"].Color             = 'Brown'

        function Generate-AutoChart05 {
            $script:AutoChart05ProcessesCsvFileHosts       = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart05ProcessesUniqueDataFields   = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique
            $script:AutoChart05ProcessesProcesses = $script:AutoChart05ProcessesUniqueDataFields | Select-Object -Property 'Processes'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()

            if ($script:AutoChart05ProcessesProcesses.count -gt 0){
                $script:AutoChart05ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart05ProcessesTitle.Text = "Processes with Network Activity"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart05ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05ProcessesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart05ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Name -eq $DataField.Name -and $Line.NetworkConnectionCount -gt 0) {
                            $Count += 1
                            if ( $script:AutoChart05ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart05ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    if ($Count -gt 0) {
                        $script:AutoChart05ProcessesUniqueCount = $script:AutoChart05ProcessesCsvComputers.Count
                        $script:AutoChart05ProcessesDataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:AutoChart05ProcessesUniqueCount
                            Computers   = $script:AutoChart05ProcessesCsvComputers
                        }
                        $script:AutoChart05ProcessesOverallDataResults += $script:AutoChart05ProcessesDataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()
                    }
                }
                $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}

                $script:AutoChart05ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ProcessesOverallDataResults.count))
                $script:AutoChart05ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
                $script:AutoChart05ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart05ProcessesTitle.Text = "Processes with Network Activity`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ProcessesOptionsButton
$script:AutoChart05ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart05ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart05Processes.Controls.Add($script:AutoChart05ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart05ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart05Processes.Controls.Remove($script:AutoChart05ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05Processes)

$script:AutoChart05ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ProcessesOverallDataResults.count))
    $script:AutoChart05ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ProcessesTrimOffFirstTrackBarValue = $script:AutoChart05ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart05ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
        $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart05ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ProcessesTrimOffFirstTrackBar)
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart05ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ProcessesOverallDataResults.count))
    $script:AutoChart05ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart05ProcessesOverallDataResults.count)
    $script:AutoChart05ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ProcessesTrimOffLastTrackBarValue = $($script:AutoChart05ProcessesOverallDataResults.count) - $script:AutoChart05ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart05ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ProcessesOverallDataResults.count) - $script:AutoChart05ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
        $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart05ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart05ProcessesTrimOffLastTrackBar)
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Processes.Series["Processes with Network Activity"].ChartType = $script:AutoChart05ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
#    $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart05ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ProcessesChartTypesAvailable) { $script:AutoChart05ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ProcessesChartTypeComboBox.Location.X + $script:AutoChart05ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05Processes3DToggleButton
$script:AutoChart05Processes3DInclination = 0
$script:AutoChart05Processes3DToggleButton.Add_Click({
    $script:AutoChart05Processes3DInclination += 10
    if ( $script:AutoChart05Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ProcessesArea.Area3DStyle.Inclination = $script:AutoChart05Processes3DInclination
        $script:AutoChart05Processes3DToggleButton.Text  = "3D On ($script:AutoChart05Processes3DInclination)"
#        $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
#        $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05Processes3DInclination -le 90 ) {
        $script:AutoChart05ProcessesArea.Area3DStyle.Inclination = $script:AutoChart05Processes3DInclination
        $script:AutoChart05Processes3DToggleButton.Text  = "3D On ($script:AutoChart05Processes3DInclination)"
#        $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
#        $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart05Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart05Processes3DInclination = 0
        $script:AutoChart05ProcessesArea.Area3DStyle.Inclination = $script:AutoChart05Processes3DInclination
        $script:AutoChart05ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05Processes.Series["Processes with Network Activity"].Points.Clear()
#        $script:AutoChart05ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Processes with Network Activity"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart05ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05Processes3DToggleButton.Location.X + $script:AutoChart05Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ProcessesColorsAvailable) { $script:AutoChart05ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Processes.Series["Processes with Network Activity"].Color = $script:AutoChart05ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05ProcessesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {
    # List of Positive Endpoints that positively match
    $script:AutoChart05ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart05ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart05ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ProcessesImportCsvPosResults) { $script:AutoChart05ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart05ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ProcessesImportCsvPosResults) { $script:AutoChart05ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ProcessesImportCsvNegResults) { $script:AutoChart05ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ProcessesImportCsvPosResults.count))"
    $script:AutoChart05ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart05ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05ProcessesCheckDiffButton
$script:AutoChart05ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart05ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart05ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ProcessesInvestDiffDropDownArray) { $script:AutoChart05ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05ProcessesInvestDiffExecuteButton
    $script:AutoChart05ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart05ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart05ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart05ProcessesInvestDiffDropDownLabel,$script:AutoChart05ProcessesInvestDiffDropDownComboBox,$script:AutoChart05ProcessesInvestDiffExecuteButton,$script:AutoChart05ProcessesInvestDiffPosResultsLabel,$script:AutoChart05ProcessesInvestDiffPosResultsTextBox,$script:AutoChart05ProcessesInvestDiffNegResultsLabel,$script:AutoChart05ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart05ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart05ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ProcessesManipulationPanel.controls.Add($script:AutoChart05ProcessesCheckDiffButton)


$AutoChart05ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ProcessesCheckDiffButton.Location.X + $script:AutoChart05ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Processes With Network Activity" -PropertyX "Processes" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart05ExpandChartButton
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($AutoChart05ExpandChartButton)


$script:AutoChart05ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart05ProcessesCheckDiffButton.Location.Y + $script:AutoChart05ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ProcessesOpenInShell
$script:AutoChart05ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05ProcessesManipulationPanel.controls.Add($script:AutoChart05ProcessesOpenInShell)



$script:AutoChart05ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart05ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart05ProcessesOpenInShell.Location.Y + $script:AutoChart05ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ProcessesSortButton
$script:AutoChart05ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart05ProcessesOverallDataResults = $script:AutoChart05ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart05ProcessesOverallDataResults = $script:AutoChart05ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart05Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart05ProcessesOverallDataResults | Select-Object -skip $script:AutoChart05ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart05ProcessesManipulationPanel.controls.Add($script:AutoChart05ProcessesSortButton)


$script:AutoChart05ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ProcessesOpenInShell.Location.X + $script:AutoChart05ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ProcessesViewResults
$script:AutoChart05ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart05ProcessesManipulationPanel.controls.Add($script:AutoChart05ProcessesViewResults)


### Save the chart to file
$script:AutoChart05ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ProcessesViewResults.Location.X
                  Y = $script:AutoChart05ProcessesViewResults.Location.Y + $script:AutoChart05ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05Processes -Title $script:AutoChart05ProcessesTitle
})
$script:AutoChart05ProcessesManipulationPanel.controls.Add($script:AutoChart05ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ProcessesSortButton.Location.X
                        Y = $script:AutoChart05ProcessesSortButton.Location.Y + $script:AutoChart05ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ProcessesManipulationPanel.Controls.Add($script:AutoChart05ProcessesNoticeTextbox)


















##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04Processes.Location.X
                  Y = $script:AutoChart04Processes.Location.Y + $script:AutoChart04Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06Processes.Titles.Add($script:AutoChart06ProcessesTitle)

### Create Charts Area
$script:AutoChart06ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ProcessesArea.Name        = 'Chart Area'
$script:AutoChart06ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart06ProcessesArea.AxisX.Interval          = 1
$script:AutoChart06ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart06Processes.ChartAreas.Add($script:AutoChart06ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06Processes.Series.Add("Process MD5 Hash")
$script:AutoChart06Processes.Series["Process MD5 Hash"].Enabled           = $True
$script:AutoChart06Processes.Series["Process MD5 Hash"].BorderWidth       = 1
$script:AutoChart06Processes.Series["Process MD5 Hash"].IsVisibleInLegend = $false
$script:AutoChart06Processes.Series["Process MD5 Hash"].Chartarea         = 'Chart Area'
$script:AutoChart06Processes.Series["Process MD5 Hash"].Legend            = 'Legend'
$script:AutoChart06Processes.Series["Process MD5 Hash"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06Processes.Series["Process MD5 Hash"]['PieLineColor']   = 'Black'
$script:AutoChart06Processes.Series["Process MD5 Hash"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06Processes.Series["Process MD5 Hash"].ChartType         = 'Column'
$script:AutoChart06Processes.Series["Process MD5 Hash"].Color             = 'Gray'

        function Generate-AutoChart06 {
            $script:AutoChart06ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart06ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'MD5Hash' | Sort-Object -Property 'MD5Hash' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()

            if ($script:AutoChart06ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart06ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart06ProcessesTitle.Text = "Process MD5 Hash"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart06ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06ProcessesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.MD5Hash) -eq $DataField.MD5Hash) {
                            $Count += 1
                            if ( $script:AutoChart06ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart06ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart06ProcessesUniqueCount = $script:AutoChart06ProcessesCsvComputers.Count
                    $script:AutoChart06ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06ProcessesUniqueCount
                        Computers   = $script:AutoChart06ProcessesCsvComputers
                    }
                    $script:AutoChart06ProcessesOverallDataResults += $script:AutoChart06ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount) }

                $script:AutoChart06ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ProcessesOverallDataResults.count))
                $script:AutoChart06ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart06ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart06ProcessesTitle.Text = "Process MD5 Hash`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ProcessesOptionsButton
$script:AutoChart06ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart06ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart06Processes.Controls.Add($script:AutoChart06ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart06ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart06Processes.Controls.Remove($script:AutoChart06ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06Processes)

$script:AutoChart06ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ProcessesOverallDataResults.count))
    $script:AutoChart06ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ProcessesTrimOffFirstTrackBarValue = $script:AutoChart06ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart06ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
        $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
    })
    $script:AutoChart06ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ProcessesTrimOffFirstTrackBar)
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart06ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ProcessesOverallDataResults.count))
    $script:AutoChart06ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart06ProcessesOverallDataResults.count)
    $script:AutoChart06ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ProcessesTrimOffLastTrackBarValue = $($script:AutoChart06ProcessesOverallDataResults.count) - $script:AutoChart06ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart06ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ProcessesOverallDataResults.count) - $script:AutoChart06ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
        $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
    })
$script:AutoChart06ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart06ProcessesTrimOffLastTrackBar)
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Processes.Series["Process MD5 Hash"].ChartType = $script:AutoChart06ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
#    $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
})
$script:AutoChart06ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ProcessesChartTypesAvailable) { $script:AutoChart06ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ProcessesChartTypeComboBox.Location.X + $script:AutoChart06ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06Processes3DToggleButton
$script:AutoChart06Processes3DInclination = 0
$script:AutoChart06Processes3DToggleButton.Add_Click({
    $script:AutoChart06Processes3DInclination += 10
    if ( $script:AutoChart06Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ProcessesArea.Area3DStyle.Inclination = $script:AutoChart06Processes3DInclination
        $script:AutoChart06Processes3DToggleButton.Text  = "3D On ($script:AutoChart06Processes3DInclination)"
#        $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
#        $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06Processes3DInclination -le 90 ) {
        $script:AutoChart06ProcessesArea.Area3DStyle.Inclination = $script:AutoChart06Processes3DInclination
        $script:AutoChart06Processes3DToggleButton.Text  = "3D On ($script:AutoChart06Processes3DInclination)"
#        $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
#        $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart06Processes3DInclination = 0
        $script:AutoChart06ProcessesArea.Area3DStyle.Inclination = $script:AutoChart06Processes3DInclination
        $script:AutoChart06ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06Processes.Series["Process MD5 Hash"].Points.Clear()
#        $script:AutoChart06ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Process MD5 Hash"].Points.AddXY($_.DataField.MD5Hash,$_.UniqueCount)}
    }
})
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart06ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06Processes3DToggleButton.Location.X + $script:AutoChart06Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ProcessesColorsAvailable) { $script:AutoChart06ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Processes.Series["Process MD5 Hash"].Color = $script:AutoChart06ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06ProcessesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {
    # List of Positive Endpoints that positively match
    $script:AutoChart06ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'MD5Hash' -eq $($script:AutoChart06ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart06ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ProcessesImportCsvPosResults) { $script:AutoChart06ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart06ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ProcessesImportCsvPosResults) { $script:AutoChart06ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ProcessesImportCsvNegResults) { $script:AutoChart06ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ProcessesImportCsvPosResults.count))"
    $script:AutoChart06ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart06ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06ProcessesCheckDiffButton
$script:AutoChart06ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart06ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'MD5Hash' -ExpandProperty 'MD5Hash' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart06ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ProcessesInvestDiffDropDownArray) { $script:AutoChart06ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06ProcessesInvestDiffExecuteButton
    $script:AutoChart06ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart06ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart06ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart06ProcessesInvestDiffDropDownLabel,$script:AutoChart06ProcessesInvestDiffDropDownComboBox,$script:AutoChart06ProcessesInvestDiffExecuteButton,$script:AutoChart06ProcessesInvestDiffPosResultsLabel,$script:AutoChart06ProcessesInvestDiffPosResultsTextBox,$script:AutoChart06ProcessesInvestDiffNegResultsLabel,$script:AutoChart06ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart06ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart06ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ProcessesManipulationPanel.controls.Add($script:AutoChart06ProcessesCheckDiffButton)


$AutoChart06ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ProcessesCheckDiffButton.Location.X + $script:AutoChart06ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process MD5 Hashes" -PropertyX "MD5Hash" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart06ExpandChartButton
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($AutoChart06ExpandChartButton)


$script:AutoChart06ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart06ProcessesCheckDiffButton.Location.Y + $script:AutoChart06ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ProcessesOpenInShell
$script:AutoChart06ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06ProcessesManipulationPanel.controls.Add($script:AutoChart06ProcessesOpenInShell)



$script:AutoChart06ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart06ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart06ProcessesOpenInShell.Location.Y + $script:AutoChart06ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ProcessesSortButton
$script:AutoChart06ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart06ProcessesOverallDataResults = $script:AutoChart06ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart06ProcessesOverallDataResults = $script:AutoChart06ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart06Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart06ProcessesOverallDataResults | Select-Object -skip $script:AutoChart06ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06ProcessesManipulationPanel.controls.Add($script:AutoChart06ProcessesSortButton)


$script:AutoChart06ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ProcessesOpenInShell.Location.X + $script:AutoChart06ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ProcessesViewResults
$script:AutoChart06ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart06ProcessesManipulationPanel.controls.Add($script:AutoChart06ProcessesViewResults)


### Save the chart to file
$script:AutoChart06ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ProcessesViewResults.Location.X
                  Y = $script:AutoChart06ProcessesViewResults.Location.Y + $script:AutoChart06ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06Processes -Title $script:AutoChart06ProcessesTitle
})
$script:AutoChart06ProcessesManipulationPanel.controls.Add($script:AutoChart06ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ProcessesSortButton.Location.X
                        Y = $script:AutoChart06ProcessesSortButton.Location.Y + $script:AutoChart06ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ProcessesManipulationPanel.Controls.Add($script:AutoChart06ProcessesNoticeTextbox)




















##############################################################################################
# AutoChart07
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05Processes.Location.X
                  Y = $script:AutoChart05Processes.Location.Y + $script:AutoChart05Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart07ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07Processes.Titles.Add($script:AutoChart07ProcessesTitle)

### Create Charts Area
$script:AutoChart07ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07ProcessesArea.Name        = 'Chart Area'
$script:AutoChart07ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart07ProcessesArea.AxisX.Interval          = 1
$script:AutoChart07ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart07Processes.ChartAreas.Add($script:AutoChart07ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07Processes.Series.Add("Signer Certificate")
$script:AutoChart07Processes.Series["Signer Certificate"].Enabled           = $True
$script:AutoChart07Processes.Series["Signer Certificate"].BorderWidth       = 1
$script:AutoChart07Processes.Series["Signer Certificate"].IsVisibleInLegend = $false
$script:AutoChart07Processes.Series["Signer Certificate"].Chartarea         = 'Chart Area'
$script:AutoChart07Processes.Series["Signer Certificate"].Legend            = 'Legend'
$script:AutoChart07Processes.Series["Signer Certificate"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07Processes.Series["Signer Certificate"]['PieLineColor']   = 'Black'
$script:AutoChart07Processes.Series["Signer Certificate"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07Processes.Series["Signer Certificate"].ChartType         = 'Column'
$script:AutoChart07Processes.Series["Signer Certificate"].Color             = 'SlateBLue'

        function Generate-AutoChart07 {
            $script:AutoChart07ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart07ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'SignerCertificate' | Sort-Object -Property 'SignerCertificate' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBlue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()

            if ($script:AutoChart07ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart07ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart07ProcessesTitle.Text = "Signer Certificate"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart07ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07ProcessesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.SignerCertificate) -eq $DataField.SignerCertificate) {
                            $Count += 1
                            if ( $script:AutoChart07ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart07ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart07ProcessesUniqueCount = $script:AutoChart07ProcessesCsvComputers.Count
                    $script:AutoChart07ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07ProcessesUniqueCount
                        Computers   = $script:AutoChart07ProcessesCsvComputers
                    }
                    $script:AutoChart07ProcessesOverallDataResults += $script:AutoChart07ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount) }

                $script:AutoChart07ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ProcessesOverallDataResults.count))
                $script:AutoChart07ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart07ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart07ProcessesTitle.Text = "Signer Certificate`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart07

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart07ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07ProcessesOptionsButton
$script:AutoChart07ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart07ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart07Processes.Controls.Add($script:AutoChart07ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart07ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart07Processes.Controls.Remove($script:AutoChart07ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07Processes)

$script:AutoChart07ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ProcessesOverallDataResults.count))
    $script:AutoChart07ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07ProcessesTrimOffFirstTrackBarValue = $script:AutoChart07ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart07ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
        $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    })
    $script:AutoChart07ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart07ProcessesTrimOffFirstTrackBar)
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart07ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart07ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ProcessesOverallDataResults.count))
    $script:AutoChart07ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart07ProcessesOverallDataResults.count)
    $script:AutoChart07ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart07ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07ProcessesTrimOffLastTrackBarValue = $($script:AutoChart07ProcessesOverallDataResults.count) - $script:AutoChart07ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart07ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07ProcessesOverallDataResults.count) - $script:AutoChart07ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
        $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    })
$script:AutoChart07ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart07ProcessesTrimOffLastTrackBar)
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart07ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart07ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07Processes.Series["Signer Certificate"].ChartType = $script:AutoChart07ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
#    $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
})
$script:AutoChart07ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ProcessesChartTypesAvailable) { $script:AutoChart07ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ProcessesChartTypeComboBox.Location.X + $script:AutoChart07ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07Processes3DToggleButton
$script:AutoChart07Processes3DInclination = 0
$script:AutoChart07Processes3DToggleButton.Add_Click({
    $script:AutoChart07Processes3DInclination += 10
    if ( $script:AutoChart07Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart07ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07ProcessesArea.Area3DStyle.Inclination = $script:AutoChart07Processes3DInclination
        $script:AutoChart07Processes3DToggleButton.Text  = "3D On ($script:AutoChart07Processes3DInclination)"
#        $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
#        $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart07Processes3DInclination -le 90 ) {
        $script:AutoChart07ProcessesArea.Area3DStyle.Inclination = $script:AutoChart07Processes3DInclination
        $script:AutoChart07Processes3DToggleButton.Text  = "3D On ($script:AutoChart07Processes3DInclination)"
#        $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
#        $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
    else {
        $script:AutoChart07Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart07Processes3DInclination = 0
        $script:AutoChart07ProcessesArea.Area3DStyle.Inclination = $script:AutoChart07Processes3DInclination
        $script:AutoChart07ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07Processes.Series["Signer Certificate"].Points.Clear()
#        $script:AutoChart07ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Signer Certificate"].Points.AddXY($_.DataField.SignerCertificate,$_.UniqueCount)}
    }
})
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart07ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07Processes3DToggleButton.Location.X + $script:AutoChart07Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ProcessesColorsAvailable) { $script:AutoChart07ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07Processes.Series["Signer Certificate"].Color = $script:AutoChart07ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07ProcessesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07 {
    # List of Positive Endpoints that positively match
    $script:AutoChart07ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'SignerCertificate' -eq $($script:AutoChart07ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart07ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ProcessesImportCsvPosResults) { $script:AutoChart07ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart07ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart07ProcessesImportCsvPosResults) { $script:AutoChart07ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ProcessesImportCsvNegResults) { $script:AutoChart07ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07ProcessesImportCsvPosResults.count))"
    $script:AutoChart07ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart07ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07ProcessesCheckDiffButton
$script:AutoChart07ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart07ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'SignerCertificate' -ExpandProperty 'SignerCertificate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart07ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07ProcessesInvestDiffDropDownArray) { $script:AutoChart07ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Execute Button
    $script:AutoChart07ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart07ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07ProcessesInvestDiffExecuteButton
    $script:AutoChart07ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07 }})
    $script:AutoChart07ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart07ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart07ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart07ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart07ProcessesInvestDiffDropDownLabel,$script:AutoChart07ProcessesInvestDiffDropDownComboBox,$script:AutoChart07ProcessesInvestDiffExecuteButton,$script:AutoChart07ProcessesInvestDiffPosResultsLabel,$script:AutoChart07ProcessesInvestDiffPosResultsTextBox,$script:AutoChart07ProcessesInvestDiffNegResultsLabel,$script:AutoChart07ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart07ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart07ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07ProcessesManipulationPanel.controls.Add($script:AutoChart07ProcessesCheckDiffButton)


$AutoChart07ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07ProcessesCheckDiffButton.Location.X + $script:AutoChart07ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process Signer Certificate" -PropertyX "SignerCertificate" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart07ExpandChartButton
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($AutoChart07ExpandChartButton)


$script:AutoChart07ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart07ProcessesCheckDiffButton.Location.Y + $script:AutoChart07ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ProcessesOpenInShell
$script:AutoChart07ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart07ProcessesManipulationPanel.controls.Add($script:AutoChart07ProcessesOpenInShell)



$script:AutoChart07ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart07ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart07ProcessesOpenInShell.Location.Y + $script:AutoChart07ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ProcessesSortButton
$script:AutoChart07ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart07ProcessesOverallDataResults = $script:AutoChart07ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart07ProcessesOverallDataResults = $script:AutoChart07ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart07Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart07ProcessesOverallDataResults | Select-Object -skip $script:AutoChart07ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart07ProcessesManipulationPanel.controls.Add($script:AutoChart07ProcessesSortButton)


$script:AutoChart07ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07ProcessesOpenInShell.Location.X + $script:AutoChart07ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ProcessesViewResults
$script:AutoChart07ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart07ProcessesManipulationPanel.controls.Add($script:AutoChart07ProcessesViewResults)


### Save the chart to file
$script:AutoChart07ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07ProcessesViewResults.Location.X
                  Y = $script:AutoChart07ProcessesViewResults.Location.Y + $script:AutoChart07ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07Processes -Title $script:AutoChart07ProcessesTitle
})
$script:AutoChart07ProcessesManipulationPanel.controls.Add($script:AutoChart07ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07ProcessesSortButton.Location.X
                        Y = $script:AutoChart07ProcessesSortButton.Location.Y + $script:AutoChart07ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ProcessesManipulationPanel.Controls.Add($script:AutoChart07ProcessesNoticeTextbox)





















##############################################################################################
# AutoChart08
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06Processes.Location.X
                  Y = $script:AutoChart06Processes.Location.Y + $script:AutoChart06Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart08ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart08Processes.Titles.Add($script:AutoChart08ProcessesTitle)

### Create Charts Area
$script:AutoChart08ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08ProcessesArea.Name        = 'Chart Area'
$script:AutoChart08ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart08ProcessesArea.AxisX.Interval          = 1
$script:AutoChart08ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart08Processes.ChartAreas.Add($script:AutoChart08ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08Processes.Series.Add("Signer Company")
$script:AutoChart08Processes.Series["Signer Company"].Enabled           = $True
$script:AutoChart08Processes.Series["Signer Company"].BorderWidth       = 1
$script:AutoChart08Processes.Series["Signer Company"].IsVisibleInLegend = $false
$script:AutoChart08Processes.Series["Signer Company"].Chartarea         = 'Chart Area'
$script:AutoChart08Processes.Series["Signer Company"].Legend            = 'Legend'
$script:AutoChart08Processes.Series["Signer Company"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08Processes.Series["Signer Company"]['PieLineColor']   = 'Black'
$script:AutoChart08Processes.Series["Signer Company"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08Processes.Series["Signer Company"].ChartType         = 'Column'
$script:AutoChart08Processes.Series["Signer Company"].Color             = 'Purple'

        function Generate-AutoChart08 {
            $script:AutoChart08ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart08ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'SignerCompany' | Sort-Object -Property 'SignerCompany' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()

            if ($script:AutoChart08ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart08ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart08ProcessesTitle.Text = "Signer Company"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart08ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08ProcessesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart08ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.SignerCompany) -eq $DataField.SignerCompany) {
                            $Count += 1
                            if ( $script:AutoChart08ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart08ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart08ProcessesUniqueCount = $script:AutoChart08ProcessesCsvComputers.Count
                    $script:AutoChart08ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08ProcessesUniqueCount
                        Computers   = $script:AutoChart08ProcessesCsvComputers
                    }
                    $script:AutoChart08ProcessesOverallDataResults += $script:AutoChart08ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount) }

                $script:AutoChart08ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ProcessesOverallDataResults.count))
                $script:AutoChart08ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart08ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart08ProcessesTitle.Text = "Signer Company`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart08

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart08ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08ProcessesOptionsButton
$script:AutoChart08ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart08ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart08Processes.Controls.Add($script:AutoChart08ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart08ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart08Processes.Controls.Remove($script:AutoChart08ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08Processes)

$script:AutoChart08ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ProcessesOverallDataResults.count))
    $script:AutoChart08ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08ProcessesTrimOffFirstTrackBarValue = $script:AutoChart08ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart08ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
        $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    })
    $script:AutoChart08ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart08ProcessesTrimOffFirstTrackBar)
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart08ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart08ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ProcessesOverallDataResults.count))
    $script:AutoChart08ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart08ProcessesOverallDataResults.count)
    $script:AutoChart08ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart08ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08ProcessesTrimOffLastTrackBarValue = $($script:AutoChart08ProcessesOverallDataResults.count) - $script:AutoChart08ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart08ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08ProcessesOverallDataResults.count) - $script:AutoChart08ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
        $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    })
$script:AutoChart08ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart08ProcessesTrimOffLastTrackBar)
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart08ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart08ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08Processes.Series["Signer Company"].ChartType = $script:AutoChart08ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
#    $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
})
$script:AutoChart08ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ProcessesChartTypesAvailable) { $script:AutoChart08ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ProcessesChartTypeComboBox.Location.X + $script:AutoChart08ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08Processes3DToggleButton
$script:AutoChart08Processes3DInclination = 0
$script:AutoChart08Processes3DToggleButton.Add_Click({
    $script:AutoChart08Processes3DInclination += 10
    if ( $script:AutoChart08Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart08ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08ProcessesArea.Area3DStyle.Inclination = $script:AutoChart08Processes3DInclination
        $script:AutoChart08Processes3DToggleButton.Text  = "3D On ($script:AutoChart08Processes3DInclination)"
#        $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
#        $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart08Processes3DInclination -le 90 ) {
        $script:AutoChart08ProcessesArea.Area3DStyle.Inclination = $script:AutoChart08Processes3DInclination
        $script:AutoChart08Processes3DToggleButton.Text  = "3D On ($script:AutoChart08Processes3DInclination)"
#        $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
#        $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
    else {
        $script:AutoChart08Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart08Processes3DInclination = 0
        $script:AutoChart08ProcessesArea.Area3DStyle.Inclination = $script:AutoChart08Processes3DInclination
        $script:AutoChart08ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08Processes.Series["Signer Company"].Points.Clear()
#        $script:AutoChart08ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Signer Company"].Points.AddXY($_.DataField.SignerCompany,$_.UniqueCount)}
    }
})
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart08ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08Processes3DToggleButton.Location.X + $script:AutoChart08Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ProcessesColorsAvailable) { $script:AutoChart08ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08Processes.Series["Signer Company"].Color = $script:AutoChart08ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08ProcessesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08 {
    # List of Positive Endpoints that positively match
    $script:AutoChart08ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'SignerCompany' -eq $($script:AutoChart08ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart08ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ProcessesImportCsvPosResults) { $script:AutoChart08ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart08ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart08ProcessesImportCsvPosResults) { $script:AutoChart08ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ProcessesImportCsvNegResults) { $script:AutoChart08ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08ProcessesImportCsvPosResults.count))"
    $script:AutoChart08ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart08ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08ProcessesCheckDiffButton
$script:AutoChart08ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart08ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'SignerCompany' -ExpandProperty 'SignerCompany' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart08ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08ProcessesInvestDiffDropDownArray) { $script:AutoChart08ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Execute Button
    $script:AutoChart08ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart08ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08ProcessesInvestDiffExecuteButton
    $script:AutoChart08ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08 }})
    $script:AutoChart08ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart08ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart08ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart08ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart08ProcessesInvestDiffDropDownLabel,$script:AutoChart08ProcessesInvestDiffDropDownComboBox,$script:AutoChart08ProcessesInvestDiffExecuteButton,$script:AutoChart08ProcessesInvestDiffPosResultsLabel,$script:AutoChart08ProcessesInvestDiffPosResultsTextBox,$script:AutoChart08ProcessesInvestDiffNegResultsLabel,$script:AutoChart08ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart08ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart08ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08ProcessesManipulationPanel.controls.Add($script:AutoChart08ProcessesCheckDiffButton)


$AutoChart08ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08ProcessesCheckDiffButton.Location.X + $script:AutoChart08ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Processes Signer Company" -PropertyX "SignerCompany" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart08ExpandChartButton
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($AutoChart08ExpandChartButton)


$script:AutoChart08ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart08ProcessesCheckDiffButton.Location.Y + $script:AutoChart08ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ProcessesOpenInShell
$script:AutoChart08ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart08ProcessesManipulationPanel.controls.Add($script:AutoChart08ProcessesOpenInShell)



$script:AutoChart08ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart08ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart08ProcessesOpenInShell.Location.Y + $script:AutoChart08ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ProcessesSortButton
$script:AutoChart08ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart08ProcessesOverallDataResults = $script:AutoChart08ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart08ProcessesOverallDataResults = $script:AutoChart08ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart08Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart08ProcessesOverallDataResults | Select-Object -skip $script:AutoChart08ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart08ProcessesManipulationPanel.controls.Add($script:AutoChart08ProcessesSortButton)


$script:AutoChart08ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08ProcessesOpenInShell.Location.X + $script:AutoChart08ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ProcessesViewResults
$script:AutoChart08ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart08ProcessesManipulationPanel.controls.Add($script:AutoChart08ProcessesViewResults)


### Save the chart to file
$script:AutoChart08ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08ProcessesViewResults.Location.X
                  Y = $script:AutoChart08ProcessesViewResults.Location.Y + $script:AutoChart08ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08Processes -Title $script:AutoChart08ProcessesTitle
})
$script:AutoChart08ProcessesManipulationPanel.controls.Add($script:AutoChart08ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08ProcessesSortButton.Location.X
                        Y = $script:AutoChart08ProcessesSortButton.Location.Y + $script:AutoChart08ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ProcessesManipulationPanel.Controls.Add($script:AutoChart08ProcessesNoticeTextbox)





















##############################################################################################
# AutoChart09
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07Processes.Location.X
                  Y = $script:AutoChart07Processes.Location.Y + $script:AutoChart07Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart09ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09Processes.Titles.Add($script:AutoChart09ProcessesTitle)

### Create Charts Area
$script:AutoChart09ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09ProcessesArea.Name        = 'Chart Area'
$script:AutoChart09ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart09ProcessesArea.AxisX.Interval          = 1
$script:AutoChart09ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart09Processes.ChartAreas.Add($script:AutoChart09ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09Processes.Series.Add("Process Path")
$script:AutoChart09Processes.Series["Process Path"].Enabled           = $True
$script:AutoChart09Processes.Series["Process Path"].BorderWidth       = 1
$script:AutoChart09Processes.Series["Process Path"].IsVisibleInLegend = $false
$script:AutoChart09Processes.Series["Process Path"].Chartarea         = 'Chart Area'
$script:AutoChart09Processes.Series["Process Path"].Legend            = 'Legend'
$script:AutoChart09Processes.Series["Process Path"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09Processes.Series["Process Path"]['PieLineColor']   = 'Black'
$script:AutoChart09Processes.Series["Process Path"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09Processes.Series["Process Path"].ChartType         = 'Column'
$script:AutoChart09Processes.Series["Process Path"].Color             = 'Yellow'

        function Generate-AutoChart09 {
            $script:AutoChart09ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart09ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'Path' | Sort-Object -Property 'Path' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09Processes.Series["Process Path"].Points.Clear()

            if ($script:AutoChart09ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart09ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart09ProcessesTitle.Text = "Process Path"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart09ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09ProcessesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Path) -eq $DataField.Path) {
                            $Count += 1
                            if ( $script:AutoChart09ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart09ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart09ProcessesUniqueCount = $script:AutoChart09ProcessesCsvComputers.Count
                    $script:AutoChart09ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09ProcessesUniqueCount
                        Computers   = $script:AutoChart09ProcessesCsvComputers
                    }
                    $script:AutoChart09ProcessesOverallDataResults += $script:AutoChart09ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount) }

                $script:AutoChart09ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ProcessesOverallDataResults.count))
                $script:AutoChart09ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart09ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart09ProcessesTitle.Text = "Process Path`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart09

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart09ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09ProcessesOptionsButton
$script:AutoChart09ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart09ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart09Processes.Controls.Add($script:AutoChart09ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart09ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart09Processes.Controls.Remove($script:AutoChart09ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09Processes)

$script:AutoChart09ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ProcessesOverallDataResults.count))
    $script:AutoChart09ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09ProcessesTrimOffFirstTrackBarValue = $script:AutoChart09ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart09ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
        $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
    $script:AutoChart09ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart09ProcessesTrimOffFirstTrackBar)
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart09ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ProcessesOverallDataResults.count))
    $script:AutoChart09ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart09ProcessesOverallDataResults.count)
    $script:AutoChart09ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart09ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09ProcessesTrimOffLastTrackBarValue = $($script:AutoChart09ProcessesOverallDataResults.count) - $script:AutoChart09ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart09ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09ProcessesOverallDataResults.count) - $script:AutoChart09ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
        $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    })
$script:AutoChart09ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart09ProcessesTrimOffLastTrackBar)
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart09ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart09ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09Processes.Series["Process Path"].ChartType = $script:AutoChart09ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
#    $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
})
$script:AutoChart09ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ProcessesChartTypesAvailable) { $script:AutoChart09ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ProcessesChartTypeComboBox.Location.X + $script:AutoChart09ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09Processes3DToggleButton
$script:AutoChart09Processes3DInclination = 0
$script:AutoChart09Processes3DToggleButton.Add_Click({
    $script:AutoChart09Processes3DInclination += 10
    if ( $script:AutoChart09Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart09ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09ProcessesArea.Area3DStyle.Inclination = $script:AutoChart09Processes3DInclination
        $script:AutoChart09Processes3DToggleButton.Text  = "3D On ($script:AutoChart09Processes3DInclination)"
#        $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
#        $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09Processes3DInclination -le 90 ) {
        $script:AutoChart09ProcessesArea.Area3DStyle.Inclination = $script:AutoChart09Processes3DInclination
        $script:AutoChart09Processes3DToggleButton.Text  = "3D On ($script:AutoChart09Processes3DInclination)"
#        $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
#        $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
    else {
        $script:AutoChart09Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart09Processes3DInclination = 0
        $script:AutoChart09ProcessesArea.Area3DStyle.Inclination = $script:AutoChart09Processes3DInclination
        $script:AutoChart09ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09Processes.Series["Process Path"].Points.Clear()
#        $script:AutoChart09ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Process Path"].Points.AddXY($_.DataField.Path,$_.UniqueCount)}
    }
})
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart09ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09Processes3DToggleButton.Location.X + $script:AutoChart09Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ProcessesColorsAvailable) { $script:AutoChart09ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09Processes.Series["Process Path"].Color = $script:AutoChart09ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09ProcessesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09 {
    # List of Positive Endpoints that positively match
    $script:AutoChart09ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Path' -eq $($script:AutoChart09ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart09ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ProcessesImportCsvPosResults) { $script:AutoChart09ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart09ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart09ProcessesImportCsvPosResults) { $script:AutoChart09ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ProcessesImportCsvNegResults) { $script:AutoChart09ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09ProcessesImportCsvPosResults.count))"
    $script:AutoChart09ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart09ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09ProcessesCheckDiffButton
$script:AutoChart09ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart09ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'Path' -ExpandProperty 'Path' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart09ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09ProcessesInvestDiffDropDownArray) { $script:AutoChart09ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Execute Button
    $script:AutoChart09ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart09ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09ProcessesInvestDiffExecuteButton
    $script:AutoChart09ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09 }})
    $script:AutoChart09ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart09ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart09ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart09ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart09ProcessesInvestDiffDropDownLabel,$script:AutoChart09ProcessesInvestDiffDropDownComboBox,$script:AutoChart09ProcessesInvestDiffExecuteButton,$script:AutoChart09ProcessesInvestDiffPosResultsLabel,$script:AutoChart09ProcessesInvestDiffPosResultsTextBox,$script:AutoChart09ProcessesInvestDiffNegResultsLabel,$script:AutoChart09ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart09ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart09ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09ProcessesManipulationPanel.controls.Add($script:AutoChart09ProcessesCheckDiffButton)


$AutoChart09ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09ProcessesCheckDiffButton.Location.X + $script:AutoChart09ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Process Paths" -PropertyX "Path" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart09ExpandChartButton
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($AutoChart09ExpandChartButton)


$script:AutoChart09ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart09ProcessesCheckDiffButton.Location.Y + $script:AutoChart09ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ProcessesOpenInShell
$script:AutoChart09ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart09ProcessesManipulationPanel.controls.Add($script:AutoChart09ProcessesOpenInShell)



$script:AutoChart09ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart09ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart09ProcessesOpenInShell.Location.Y + $script:AutoChart09ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ProcessesSortButton
$script:AutoChart09ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart09ProcessesOverallDataResults = $script:AutoChart09ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart09ProcessesOverallDataResults = $script:AutoChart09ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart09Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart09ProcessesOverallDataResults | Select-Object -skip $script:AutoChart09ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart09ProcessesManipulationPanel.controls.Add($script:AutoChart09ProcessesSortButton)


$script:AutoChart09ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09ProcessesOpenInShell.Location.X + $script:AutoChart09ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ProcessesViewResults
$script:AutoChart09ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart09ProcessesManipulationPanel.controls.Add($script:AutoChart09ProcessesViewResults)


### Save the chart to file
$script:AutoChart09ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09ProcessesViewResults.Location.X
                  Y = $script:AutoChart09ProcessesViewResults.Location.Y + $script:AutoChart09ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09Processes -Title $script:AutoChart09ProcessesTitle
})
$script:AutoChart09ProcessesManipulationPanel.controls.Add($script:AutoChart09ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09ProcessesSortButton.Location.X
                        Y = $script:AutoChart09ProcessesSortButton.Location.Y + $script:AutoChart09ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ProcessesManipulationPanel.Controls.Add($script:AutoChart09ProcessesNoticeTextbox)





















##############################################################################################
# AutoChart10
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10Processes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08Processes.Location.X
                  Y = $script:AutoChart08Processes.Location.Y + $script:AutoChart08Processes.Size.Height + $($FormScale *  20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10Processes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart10ProcessesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10Processes.Titles.Add($script:AutoChart10ProcessesTitle)

### Create Charts Area
$script:AutoChart10ProcessesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10ProcessesArea.Name        = 'Chart Area'
$script:AutoChart10ProcessesArea.AxisX.Title = 'Hosts'
$script:AutoChart10ProcessesArea.AxisX.Interval          = 1
$script:AutoChart10ProcessesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10ProcessesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10ProcessesArea.Area3DStyle.Inclination = 75
$script:AutoChart10Processes.ChartAreas.Add($script:AutoChart10ProcessesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10Processes.Series.Add("Services Started By Processes")
$script:AutoChart10Processes.Series["Services Started By Processes"].Enabled           = $True
$script:AutoChart10Processes.Series["Services Started By Processes"].BorderWidth       = 1
$script:AutoChart10Processes.Series["Services Started By Processes"].IsVisibleInLegend = $false
$script:AutoChart10Processes.Series["Services Started By Processes"].Chartarea         = 'Chart Area'
$script:AutoChart10Processes.Series["Services Started By Processes"].Legend            = 'Legend'
$script:AutoChart10Processes.Series["Services Started By Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10Processes.Series["Services Started By Processes"]['PieLineColor']   = 'Black'
$script:AutoChart10Processes.Series["Services Started By Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10Processes.Series["Services Started By Processes"].ChartType         = 'Column'
$script:AutoChart10Processes.Series["Services Started By Processes"].Color             = 'Red'

        function Generate-AutoChart10 {
            $script:AutoChart10ProcessesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique
            $script:AutoChart10ProcessesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'ServiceInfo' | Sort-Object -Property 'ServiceInfo' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10ProcessesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()

            if ($script:AutoChart10ProcessesUniqueDataFields.count -gt 0){
                $script:AutoChart10ProcessesTitle.ForeColor = 'Black'
                $script:AutoChart10ProcessesTitle.Text = "Services Started By Processes"

                # If the Second field/Y Axis equals ComputerName, it counts it
                $script:AutoChart10ProcessesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10ProcessesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10ProcessesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.ServiceInfo) -eq $DataField.ServiceInfo) {
                            $Count += 1
                            if ( $script:AutoChart10ProcessesCsvComputers -notcontains $($Line.ComputerName) ) { $script:AutoChart10ProcessesCsvComputers += $($Line.ComputerName) }
                        }
                    }
                    $script:AutoChart10ProcessesUniqueCount = $script:AutoChart10ProcessesCsvComputers.Count
                    $script:AutoChart10ProcessesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10ProcessesUniqueCount
                        Computers   = $script:AutoChart10ProcessesCsvComputers
                    }
                    $script:AutoChart10ProcessesOverallDataResults += $script:AutoChart10ProcessesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount) }

                $script:AutoChart10ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ProcessesOverallDataResults.count))
                $script:AutoChart10ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ProcessesOverallDataResults.count))
            }
            else {
                $script:AutoChart10ProcessesTitle.ForeColor = 'Red'
                $script:AutoChart10ProcessesTitle.Text = "Services Started By Processes`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart10

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart10ProcessesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10Processes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10Processes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10ProcessesOptionsButton
$script:AutoChart10ProcessesOptionsButton.Add_Click({
    if ($script:AutoChart10ProcessesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10ProcessesOptionsButton.Text = 'Options ^'
        $script:AutoChart10Processes.Controls.Add($script:AutoChart10ProcessesManipulationPanel)
    }
    elseif ($script:AutoChart10ProcessesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10ProcessesOptionsButton.Text = 'Options v'
        $script:AutoChart10Processes.Controls.Remove($script:AutoChart10ProcessesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ProcessesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10Processes)

$script:AutoChart10ProcessesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10Processes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10Processes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10ProcessesTrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10ProcessesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10ProcessesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ProcessesOverallDataResults.count))
    $script:AutoChart10ProcessesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10ProcessesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10ProcessesTrimOffFirstTrackBarValue = $script:AutoChart10ProcessesTrimOffFirstTrackBar.Value
        $script:AutoChart10ProcessesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10ProcessesTrimOffFirstTrackBar.Value)"
        $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
        $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
    })
    $script:AutoChart10ProcessesTrimOffFirstGroupBox.Controls.Add($script:AutoChart10ProcessesTrimOffFirstTrackBar)
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10ProcessesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10ProcessesTrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10ProcessesTrimOffFirstGroupBox.Location.X + $script:AutoChart10ProcessesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10ProcessesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10ProcessesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10ProcessesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10ProcessesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ProcessesOverallDataResults.count))
    $script:AutoChart10ProcessesTrimOffLastTrackBar.Value         = $($script:AutoChart10ProcessesOverallDataResults.count)
    $script:AutoChart10ProcessesTrimOffLastTrackBarValue   = 0
    $script:AutoChart10ProcessesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10ProcessesTrimOffLastTrackBarValue = $($script:AutoChart10ProcessesOverallDataResults.count) - $script:AutoChart10ProcessesTrimOffLastTrackBar.Value
        $script:AutoChart10ProcessesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10ProcessesOverallDataResults.count) - $script:AutoChart10ProcessesTrimOffLastTrackBar.Value)"
        $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
        $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
    })
$script:AutoChart10ProcessesTrimOffLastGroupBox.Controls.Add($script:AutoChart10ProcessesTrimOffLastTrackBar)
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10ProcessesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10ProcessesChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart10ProcessesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10ProcessesTrimOffFirstGroupBox.Location.Y + $script:AutoChart10ProcessesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ProcessesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10Processes.Series["Services Started By Processes"].ChartType = $script:AutoChart10ProcessesChartTypeComboBox.SelectedItem
#    $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
#    $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
})
$script:AutoChart10ProcessesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10ProcessesChartTypesAvailable) { $script:AutoChart10ProcessesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10ProcessesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10Processes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10ProcessesChartTypeComboBox.Location.X + $script:AutoChart10ProcessesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10ProcessesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10Processes3DToggleButton
$script:AutoChart10Processes3DInclination = 0
$script:AutoChart10Processes3DToggleButton.Add_Click({
    $script:AutoChart10Processes3DInclination += 10
    if ( $script:AutoChart10Processes3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart10ProcessesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10ProcessesArea.Area3DStyle.Inclination = $script:AutoChart10Processes3DInclination
        $script:AutoChart10Processes3DToggleButton.Text  = "3D On ($script:AutoChart10Processes3DInclination)"
#        $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
#        $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10Processes3DInclination -le 90 ) {
        $script:AutoChart10ProcessesArea.Area3DStyle.Inclination = $script:AutoChart10Processes3DInclination
        $script:AutoChart10Processes3DToggleButton.Text  = "3D On ($script:AutoChart10Processes3DInclination)"
#        $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
#        $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
    }
    else {
        $script:AutoChart10Processes3DToggleButton.Text  = "3D Off"
        $script:AutoChart10Processes3DInclination = 0
        $script:AutoChart10ProcessesArea.Area3DStyle.Inclination = $script:AutoChart10Processes3DInclination
        $script:AutoChart10ProcessesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10Processes.Series["Services Started By Processes"].Points.Clear()
#        $script:AutoChart10ProcessesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Services Started By Processes"].Points.AddXY($_.DataField.ServiceInfo,$_.UniqueCount)}
    }
})
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10Processes3DToggleButton)

### Change the color of the chart
$script:AutoChart10ProcessesChangeColorComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10Processes3DToggleButton.Location.X + $script:AutoChart10Processes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10Processes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ProcessesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10ProcessesColorsAvailable) { $script:AutoChart10ProcessesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10ProcessesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10Processes.Series["Services Started By Processes"].Color = $script:AutoChart10ProcessesChangeColorComboBox.SelectedItem
})
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10ProcessesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10 {
    # List of Positive Endpoints that positively match
    $script:AutoChart10ProcessesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ServiceInfo' -eq $($script:AutoChart10ProcessesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'ComputerName' -Unique
    $script:AutoChart10ProcessesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ProcessesImportCsvPosResults) { $script:AutoChart10ProcessesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10ProcessesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'ComputerName' -Unique

    $script:AutoChart10ProcessesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10ProcessesImportCsvAll) { if ($Endpoint -notin $script:AutoChart10ProcessesImportCsvPosResults) { $script:AutoChart10ProcessesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10ProcessesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ProcessesImportCsvNegResults) { $script:AutoChart10ProcessesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10ProcessesImportCsvPosResults.count))"
    $script:AutoChart10ProcessesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10ProcessesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10ProcessesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10ProcessesTrimOffLastGroupBox.Location.X + $script:AutoChart10ProcessesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ProcessesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10ProcessesCheckDiffButton
$script:AutoChart10ProcessesCheckDiffButton.Add_Click({
    $script:AutoChart10ProcessesInvestDiffDropDownArray = $script:AutoChartDataSourceCsv | Select-Object -Property 'ServiceInfo' -ExpandProperty 'ServiceInfo' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10ProcessesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10ProcessesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ProcessesInvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ProcessesInvestDiffDropDownLabel.Location.y + $script:AutoChart10ProcessesInvestDiffDropDownLabel.Size.Height }
        Width    = $Formscale * 290
        Height   = $Formscale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10ProcessesInvestDiffDropDownArray) { $script:AutoChart10ProcessesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10ProcessesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10ProcessesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Execute Button
    $script:AutoChart10ProcessesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ProcessesInvestDiffDropDownComboBox.Location.y + $script:AutoChart10ProcessesInvestDiffDropDownComboBox.Size.Height + $($FormScale * 5) }
        Width    = $Formscale * 100
        Height   = $Formscale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10ProcessesInvestDiffExecuteButton
    $script:AutoChart10ProcessesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10 }})
    $script:AutoChart10ProcessesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10ProcessesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ProcessesInvestDiffExecuteButton.Location.y + $script:AutoChart10ProcessesInvestDiffExecuteButton.Size.Height + $($FormScale *  10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ProcessesInvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Location.y + $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10ProcessesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Location.x + $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Size.Width + $($FormScale *  10)
                        Y = $script:AutoChart10ProcessesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ProcessesInvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10ProcessesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10ProcessesInvestDiffNegResultsLabel.Location.y + $script:AutoChart10ProcessesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10ProcessesInvestDiffForm.Controls.AddRange(@($script:AutoChart10ProcessesInvestDiffDropDownLabel,$script:AutoChart10ProcessesInvestDiffDropDownComboBox,$script:AutoChart10ProcessesInvestDiffExecuteButton,$script:AutoChart10ProcessesInvestDiffPosResultsLabel,$script:AutoChart10ProcessesInvestDiffPosResultsTextBox,$script:AutoChart10ProcessesInvestDiffNegResultsLabel,$script:AutoChart10ProcessesInvestDiffNegResultsTextBox))
    $script:AutoChart10ProcessesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10ProcessesInvestDiffForm.ShowDialog()
})
$script:AutoChart10ProcessesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10ProcessesManipulationPanel.controls.Add($script:AutoChart10ProcessesCheckDiffButton)


$AutoChart10ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10ProcessesCheckDiffButton.Location.X + $script:AutoChart10ProcessesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10ProcessesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Services Started By Processes" -PropertyX "ServiceInfo" -PropertyY "ComputerName" }
}
CommonButtonSettings -Button $AutoChart10ExpandChartButton
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($AutoChart10ExpandChartButton)


$script:AutoChart10ProcessesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10ProcessesCheckDiffButton.Location.X
                   Y = $script:AutoChart10ProcessesCheckDiffButton.Location.Y + $script:AutoChart10ProcessesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ProcessesOpenInShell
$script:AutoChart10ProcessesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart10ProcessesManipulationPanel.controls.Add($script:AutoChart10ProcessesOpenInShell)



$script:AutoChart10ProcessesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart10ProcessesOpenInShell.Location.X
                  Y = $script:AutoChart10ProcessesOpenInShell.Location.Y + $script:AutoChart10ProcessesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ProcessesSortButton
$script:AutoChart10ProcessesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart10ProcessesOverallDataResults = $script:AutoChart10ProcessesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart10ProcessesOverallDataResults = $script:AutoChart10ProcessesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart10Processes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart10ProcessesOverallDataResults | Select-Object -skip $script:AutoChart10ProcessesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ProcessesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10Processes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart10ProcessesManipulationPanel.controls.Add($script:AutoChart10ProcessesSortButton)


$script:AutoChart10ProcessesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10ProcessesOpenInShell.Location.X + $script:AutoChart10ProcessesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ProcessesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ProcessesViewResults
$script:AutoChart10ProcessesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart10ProcessesManipulationPanel.controls.Add($script:AutoChart10ProcessesViewResults)


### Save the chart to file
$script:AutoChart10ProcessesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10ProcessesViewResults.Location.X
                  Y = $script:AutoChart10ProcessesViewResults.Location.Y + $script:AutoChart10ProcessesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ProcessesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10ProcessesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10Processes -Title $script:AutoChart10ProcessesTitle
})
$script:AutoChart10ProcessesManipulationPanel.controls.Add($script:AutoChart10ProcessesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10ProcessesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10ProcessesSortButton.Location.X
                        Y = $script:AutoChart10ProcessesSortButton.Location.Y + $script:AutoChart10ProcessesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10ProcessesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10ProcessesManipulationPanel.Controls.Add($script:AutoChart10ProcessesNoticeTextbox)




