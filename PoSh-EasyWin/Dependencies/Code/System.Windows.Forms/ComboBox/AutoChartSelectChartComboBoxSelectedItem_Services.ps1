$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization


### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Service Info'
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


$script:AutoChart01ServicesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Services') { $script:AutoChart01ServicesCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ServicesCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()

function Close-AllOptions {
    $script:AutoChart01ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart01Services.Controls.Remove($script:AutoChart01ServicesManipulationPanel)
    $script:AutoChart02ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart02Services.Controls.Remove($script:AutoChart02ServicesManipulationPanel)
    $script:AutoChart03ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart03Services.Controls.Remove($script:AutoChart03ServicesManipulationPanel)
    $script:AutoChart04ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart04Services.Controls.Remove($script:AutoChart04ServicesManipulationPanel)
    $script:AutoChart05ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart05Services.Controls.Remove($script:AutoChart05ServicesManipulationPanel)
    $script:AutoChart06ServicesOptionsButton.Text = 'Options v'
    $script:AutoChart06Services.Controls.Remove($script:AutoChart06ServicesManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Service Info'
    Location  = @{ X = $FormScale * 5
                   Y = $FormScale * 5 }
    Size      = @{ Width  = $FormScale * 1150
                   Height = $FormScale * 25 }
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
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
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-EasyWin')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsServices -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsServices -ComputerNameList $script:ComputerList }
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

    Generate-AutoChart01 -Filter 'Running'
    Generate-AutoChart02 -Filter 'Running'
    Generate-AutoChart03 -Filter 'Auto'
    Generate-AutoChart04 -Filter 'LocalSystem'
    Generate-AutoChart05
    Generate-AutoChart06
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
$script:AutoChart01Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01Services.Titles.Add($script:AutoChart01ServicesTitle)

### Create Charts Area
$script:AutoChart01ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ServicesArea.Name        = 'Chart Area'
$script:AutoChart01ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart01ServicesArea.AxisX.Interval          = 1
$script:AutoChart01ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart01Services.ChartAreas.Add($script:AutoChart01ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01Services.Series.Add("Running Services")
$script:AutoChart01Services.Series["Running Services"].Enabled           = $True
$script:AutoChart01Services.Series["Running Services"].BorderWidth       = 1
$script:AutoChart01Services.Series["Running Services"].IsVisibleInLegend = $false
$script:AutoChart01Services.Series["Running Services"].Chartarea         = 'Chart Area'
$script:AutoChart01Services.Series["Running Services"].Legend            = 'Legend'
$script:AutoChart01Services.Series["Running Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01Services.Series["Running Services"]['PieLineColor']   = 'Black'
$script:AutoChart01Services.Series["Running Services"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01Services.Series["Running Services"].ChartType         = 'Column'
$script:AutoChart01Services.Series["Running Services"].Color             = 'Red'

        function Generate-AutoChart01 ($Filter) {
            $script:AutoChart01ServicesCsvFileHosts     = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01ServicesUniqueDataFields = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            $script:AutoChart01Services.Series["Running Services"].Points.Clear()

            if ($script:AutoChart01ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart01ServicesTitle.ForeColor = 'Black'
                $script:AutoChart01ServicesTitle.Text = "$Filter Services"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01ServicesOverallDataResults = @()

                $FilteredData = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"}

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ServicesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01ServicesCsvComputers = @()
                    foreach ( $Line in $FilteredData ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart01ServicesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01ServicesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    ### much slower than the above code
                    #$DataMatch = $FilteredData | Where-Object {$_.name -eq $DataField.Name}
                    #$Count = $DataMatch.Count
                    #$script:AutoChart01ServicesCsvComputers = $DataMatch | Select-Object PSComputerName -unique

                    $script:AutoChart01ServicesUniqueCount = $script:AutoChart01ServicesCsvComputers.Count
                    $script:AutoChart01ServicesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ServicesUniqueCount
                        Computers   = $script:AutoChart01ServicesCsvComputers
                    }
                    $script:AutoChart01ServicesOverallDataResults += $script:AutoChart01ServicesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()

                }
                $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:AutoChart01ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ServicesOverallDataResults.count))
                $script:AutoChart01ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart01ServicesTitle.ForeColor = 'Red'
                $script:AutoChart01ServicesTitle.Text = "$Filter Services`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ServicesOptionsButton
$script:AutoChart01ServicesOptionsButton.Add_Click({
    if ($script:AutoChart01ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart01Services.Controls.Add($script:AutoChart01ServicesManipulationPanel)
    }
    elseif ($script:AutoChart01ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart01Services.Controls.Remove($script:AutoChart01ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ServicesOptionsButton)

# A filter combobox to modify what is displayed
$script:AutoChart01ServicesFilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running'
    Location  = @{ X = $script:AutoChart01ServicesOptionsButton.Location.X + 1
                    Y = $script:AutoChart01ServicesOptionsButton.Location.Y - $script:AutoChart01ServicesOptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ServicesFilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart01 -Filter $script:AutoChart01ServicesFilterComboBox.SelectedItem
#    $script:AutoChart01Services.Series["Running Services"].Points.Clear()
#    $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ServicesFilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:AutoChart01ServicesFilterAvailable) { $script:AutoChart01ServicesFilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ServicesFilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01Services)
$script:AutoChart01ServicesFilterComboBox.SelectedIndeX = 0


$script:AutoChart01ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ServicesOverallDataResults.count))
    $script:AutoChart01ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ServicesTrimOffFirstTrackBarValue = $script:AutoChart01ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart01ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart01Services.Series["Running Services"].Points.Clear()
        $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ServicesTrimOffFirstTrackBar)
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart01ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }

    $script:AutoChart01ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ServicesOverallDataResults.count))
    $script:AutoChart01ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart01ServicesOverallDataResults.count)
    $script:AutoChart01ServicesTrimOffLastTrackBarValue          = 0
    $script:AutoChart01ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ServicesTrimOffLastTrackBarValue = $($script:AutoChart01ServicesOverallDataResults.count) - $script:AutoChart01ServicesTrimOffLastTrackBar.Value
        $script:AutoChart01ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ServicesOverallDataResults.count) - $script:AutoChart01ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart01Services.Series["Running Services"].Points.Clear()
        $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart01ServicesTrimOffLastTrackBar)
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Services.Series["Running Services"].ChartType = $script:AutoChart01ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart01Services.Series["Running Services"].Points.Clear()
#    $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ServicesChartTypesAvailable) { $script:AutoChart01ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ServicesChartTypeComboBox.Location.X + $script:AutoChart01ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01Services3DToggleButton
$script:AutoChart01Services3DInclination = 0
$script:AutoChart01Services3DToggleButton.Add_Click({

    $script:AutoChart01Services3DInclination += 10
    if ( $script:AutoChart01Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ServicesArea.Area3DStyle.Inclination = $script:AutoChart01Services3DInclination
        $script:AutoChart01Services3DToggleButton.Text  = "3D On ($script:AutoChart01Services3DInclination)"
#        $script:AutoChart01Services.Series["Running Services"].Points.Clear()
#        $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01Services3DInclination -le 90 ) {
        $script:AutoChart01ServicesArea.Area3DStyle.Inclination = $script:AutoChart01Services3DInclination
        $script:AutoChart01Services3DToggleButton.Text  = "3D On ($script:AutoChart01Services3DInclination)"
#        $script:AutoChart01Services.Series["Running Services"].Points.Clear()
#        $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart01Services3DInclination = 0
        $script:AutoChart01ServicesArea.Area3DStyle.Inclination = $script:AutoChart01Services3DInclination
        $script:AutoChart01ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01Services.Series["Running Services"].Points.Clear()
#        $script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01Services3DToggleButton)

### Change the color of the chart
$script:AutoChart01ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01Services3DToggleButton.Location.X + $script:AutoChart01Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ServicesColorsAvailable) { $script:AutoChart01ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01Services.Series["Running Services"].Color = $script:AutoChart01ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 ($Filter) {
    # List of Positive Endpoints that positively match
    $script:AutoChart01ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart01ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ServicesImportCsvPosResults) { $script:AutoChart01ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ServicesImportCsvPosResults) { $script:AutoChart01ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ServicesImportCsvNegResults) { $script:AutoChart01ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ServicesImportCsvPosResults.count))"
    $script:AutoChart01ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart01ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
CommonButtonSettings -Button $script:AutoChart01ServicesCheckDiffButton
$script:AutoChart01ServicesCheckDiffButton.Add_Click({
    $script:AutoChart01ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart01ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ServicesInvestDiffDropDownArray) { $script:AutoChart01ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01  -Filter $script:AutoChart01ServicesFilterComboBox.SelectedItem }})
    $script:AutoChart01ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 -Filter $script:AutoChart01ServicesFilterComboBox.SelectedItem })

    ### Investigate Difference Execute Button
    $script:AutoChart01ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01ServicesInvestDiffExecuteButton
    $script:AutoChart01ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 -Filter $script:AutoChart01ServicesFilterComboBox.SelectedItem }})
    $script:AutoChart01ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 -Filter $script:AutoChart01ServicesFilterComboBox.SelectedItem })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart01ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart01ServicesInvestDiffDropDownLabel,$script:AutoChart01ServicesInvestDiffDropDownComboBox,$script:AutoChart01ServicesInvestDiffExecuteButton,$script:AutoChart01ServicesInvestDiffPosResultsLabel,$script:AutoChart01ServicesInvestDiffPosResultsTextBox,$script:AutoChart01ServicesInvestDiffNegResultsLabel,$script:AutoChart01ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart01ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart01ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ServicesManipulationPanel.controls.Add($script:AutoChart01ServicesCheckDiffButton)


$script:AutoChart01ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ServicesCheckDiffButton.Location.X + $script:AutoChart01ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:AutoChart01ServicesExpandChartButton
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesExpandChartButton)


$script:AutoChart01ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart01ServicesCheckDiffButton.Location.Y + $script:AutoChart01ServicesCheckDiffButton.Size.Height + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ServicesOpenInShell
$script:AutoChart01ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01ServicesManipulationPanel.controls.Add($script:AutoChart01ServicesOpenInShell)


$script:AutoChart01ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ServicesOpenInShell.Location.X + $script:AutoChart01ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ServicesResults
$script:AutoChart01ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01ServicesManipulationPanel.controls.Add($script:AutoChart01ServicesResults)

### Save the chart to file
$script:AutoChart01ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ServicesOpenInShell.Location.X
                  Y = $script:AutoChart01ServicesOpenInShell.Location.Y + $script:AutoChart01ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01Services -Title $script:AutoChart01ServicesTitle
})
$script:AutoChart01ServicesManipulationPanel.controls.Add($script:AutoChart01ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ServicesSaveButton.Location.X
                        Y = $script:AutoChart01ServicesSaveButton.Location.Y + $script:AutoChart01ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ServicesManipulationPanel.Controls.Add($script:AutoChart01ServicesNoticeTextbox)

$script:AutoChart01Services.Series["Running Services"].Points.Clear()
$script:AutoChart01ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01Services.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
























##############################################################################################
# AutoChart02
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Services.Location.X + $script:AutoChart01Services.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01Services.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02Services.Titles.Add($script:AutoChart02ServicesTitle)

### Create Charts Area
$script:AutoChart02ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ServicesArea.Name        = 'Chart Area'
$script:AutoChart02ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart02ServicesArea.AxisX.Interval          = 1
$script:AutoChart02ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart02Services.ChartAreas.Add($script:AutoChart02ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02Services.Series.Add("Running Services Per Host")
$script:AutoChart02Services.Series["Running Services Per Host"].Enabled           = $True
$script:AutoChart02Services.Series["Running Services Per Host"].BorderWidth       = 1
$script:AutoChart02Services.Series["Running Services Per Host"].IsVisibleInLegend = $false
$script:AutoChart02Services.Series["Running Services Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02Services.Series["Running Services Per Host"].Legend            = 'Legend'
$script:AutoChart02Services.Series["Running Services Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02Services.Series["Running Services Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02Services.Series["Running Services Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02Services.Series["Running Services Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02Services.Series["Running Services Per Host"].Color             = 'Blue'

        function Generate-AutoChart02 ($Filter) {
            $script:AutoChart02ServicesCsvFileHosts     = $script:AutoChartDataSourceCsv | Select-Object -Property 'PSComputerName' -ExpandProperty 'PSComputerName' | Sort-Object -Unique
            $script:AutoChart02ServicesUniqueDataFields = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object  -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            if ($script:AutoChart02ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart02ServicesTitle.ForeColor = 'Black'
                $script:AutoChart02ServicesTitle.Text = "$Filter Services Per Host"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02ServicesOverallDataResults = @()

                $FilteredData = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq "$Filter" -or $_.Status -eq "$Filter"} | Sort-Object PSComputerName

                foreach ( $Line in $FilteredData ) {
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
                            $script:AutoChart02ServicesOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02ServicesOverallDataResults += $AutoChart02YDataResults
                $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | ForEach-Object { $script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
                $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ServicesOverallDataResults.count))
                $script:AutoChart02ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
                $script:AutoChart02ServicesTitle.ForeColor = 'Red'
                $script:AutoChart02ServicesTitle.Text = "$Filter Services Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02 -Filter 'Running'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ServicesOptionsButton
$script:AutoChart02ServicesOptionsButton.Add_Click({
    if ($script:AutoChart02ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart02Services.Controls.Add($script:AutoChart02ServicesManipulationPanel)
    }
    elseif ($script:AutoChart02ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart02Services.Controls.Remove($script:AutoChart02ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ServicesOptionsButton)

# A filter combobox to modify what is displayed
$script:AutoChart02ServicesFilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Running'
    Location  = @{ X = $script:AutoChart02ServicesOptionsButton.Location.X + 1
                    Y = $script:AutoChart02ServicesOptionsButton.Location.Y - $script:AutoChart02ServicesOptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ServicesFilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart02 -Filter $script:AutoChart02ServicesFilterComboBox.SelectedItem
#    $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
#    $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ServicesFilterAvailable = @('Running','Stopped')
ForEach ($Item in $script:AutoChart02ServicesFilterAvailable) { $script:AutoChart02ServicesFilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ServicesFilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02Services)
$script:AutoChart02ServicesFilterComboBox.SelectedIndeX = 0


$script:AutoChart02ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ServicesOverallDataResults.count))
    $script:AutoChart02ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ServicesTrimOffFirstTrackBarValue = $script:AutoChart02ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart02ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
        $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ServicesTrimOffFirstTrackBar)
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart02ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                        Y = $script:AutoChart02ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ServicesOverallDataResults.count))
    $script:AutoChart02ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart02ServicesOverallDataResults.count)
    $script:AutoChart02ServicesTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ServicesTrimOffLastTrackBarValue = $($script:AutoChart02ServicesOverallDataResults.count) - $script:AutoChart02ServicesTrimOffLastTrackBar.Value
        $script:AutoChart02ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ServicesOverallDataResults.count) - $script:AutoChart02ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
        $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart02ServicesTrimOffLastTrackBar)
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Services.Series["Running Services Per Host"].ChartType = $script:AutoChart02ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
#    $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ServicesChartTypesAvailable) { $script:AutoChart02ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ServicesChartTypeComboBox.Location.X + $script:AutoChart02ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02Services3DToggleButton
$script:AutoChart02Services3DInclination = 0
$script:AutoChart02Services3DToggleButton.Add_Click({
    $script:AutoChart02Services3DInclination += 10
    if ( $script:AutoChart02Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ServicesArea.Area3DStyle.Inclination = $script:AutoChart02Services3DInclination
        $script:AutoChart02Services3DToggleButton.Text  = "3D On ($script:AutoChart02Services3DInclination)"
#        $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02Services3DInclination -le 90 ) {
        $script:AutoChart02ServicesArea.Area3DStyle.Inclination = $script:AutoChart02Services3DInclination
        $script:AutoChart02Services3DToggleButton.Text  = "3D On ($script:AutoChart02Services3DInclination)"
#        $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart02Services3DInclination = 0
        $script:AutoChart02ServicesArea.Area3DStyle.Inclination = $script:AutoChart02Services3DInclination
        $script:AutoChart02ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
#        $script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02Services3DToggleButton)

### Change the color of the chart
$script:AutoChart02ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02Services3DToggleButton.Location.X + $script:AutoChart02Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ServicesColorsAvailable) { $script:AutoChart02ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02Services.Series["Running Services Per Host"].Color = $script:AutoChart02ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {
    # List of Positive Endpoints that positively match
    $script:AutoChart02ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart02ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ServicesImportCsvPosResults) { $script:AutoChart02ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ServicesImportCsvPosResults) { $script:AutoChart02ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ServicesImportCsvNegResults) { $script:AutoChart02ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ServicesImportCsvPosResults.count))"
    $script:AutoChart02ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart02ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02ServicesCheckDiffButton
$script:AutoChart02ServicesCheckDiffButton.Add_Click({
    $script:AutoChart02ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart02ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ServicesInvestDiffDropDownArray) { $script:AutoChart02ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02ServicesInvestDiffExecuteButton
    $script:AutoChart02ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart02ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart02ServicesInvestDiffDropDownLabel,$script:AutoChart02ServicesInvestDiffDropDownComboBox,$script:AutoChart02ServicesInvestDiffExecuteButton,$script:AutoChart02ServicesInvestDiffPosResultsLabel,$script:AutoChart02ServicesInvestDiffPosResultsTextBox,$script:AutoChart02ServicesInvestDiffNegResultsLabel,$script:AutoChart02ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart02ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart02ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ServicesManipulationPanel.controls.Add($script:AutoChart02ServicesCheckDiffButton)


$script:AutoChart02ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ServicesCheckDiffButton.Location.X + $script:AutoChart02ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Services per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }
}
CommonButtonSettings -Button $script:AutoChart02ServicesExpandChartButton
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesExpandChartButton)


$script:AutoChart02ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart02ServicesCheckDiffButton.Location.Y + $script:AutoChart02ServicesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ServicesOpenInShell
$script:AutoChart02ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02ServicesManipulationPanel.controls.Add($script:AutoChart02ServicesOpenInShell)


$script:AutoChart02ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ServicesOpenInShell.Location.X + $script:AutoChart02ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ServicesResults
$script:AutoChart02ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02ServicesManipulationPanel.controls.Add($script:AutoChart02ServicesResults)

### Save the chart to file
$script:AutoChart02ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ServicesOpenInShell.Location.X
                  Y = $script:AutoChart02ServicesOpenInShell.Location.Y + $script:AutoChart02ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02Services -Title $script:AutoChart02ServicesTitle
})
$script:AutoChart02ServicesManipulationPanel.controls.Add($script:AutoChart02ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ServicesSaveButton.Location.X
                        Y = $script:AutoChart02ServicesSaveButton.Location.Y + $script:AutoChart02ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ServicesManipulationPanel.Controls.Add($script:AutoChart02ServicesNoticeTextbox)

$script:AutoChart02Services.Series["Running Services Per Host"].Points.Clear()
$script:AutoChart02ServicesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02Services.Series["Running Services Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




















##############################################################################################
# AutoChart03
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01Services.Location.X
                  Y = $script:AutoChart01Services.Location.Y + $script:AutoChart01Services.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03Services.Titles.Add($script:AutoChart03ServicesTitle)

### Create Charts Area
$script:AutoChart03ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ServicesArea.Name        = 'Chart Area'
$script:AutoChart03ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart03ServicesArea.AxisX.Interval          = 1
$script:AutoChart03ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart03Services.ChartAreas.Add($script:AutoChart03ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03Services.Series.Add("Automatic Startup Services")
$script:AutoChart03Services.Series["Automatic Startup Services"].Enabled           = $True
$script:AutoChart03Services.Series["Automatic Startup Services"].BorderWidth       = 1
$script:AutoChart03Services.Series["Automatic Startup Services"].IsVisibleInLegend = $false
$script:AutoChart03Services.Series["Automatic Startup Services"].Chartarea         = 'Chart Area'
$script:AutoChart03Services.Series["Automatic Startup Services"].Legend            = 'Legend'
$script:AutoChart03Services.Series["Automatic Startup Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03Services.Series["Automatic Startup Services"]['PieLineColor']   = 'Black'
$script:AutoChart03Services.Series["Automatic Startup Services"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03Services.Series["Automatic Startup Services"].ChartType         = 'Column'
$script:AutoChart03Services.Series["Automatic Startup Services"].Color             = 'Green'

        function Generate-AutoChart03 ($Filter) {
            $script:AutoChart03ServicesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03ServicesUniqueDataFields  = $script:AutoChartDataSourceCsv | Where-Object {$_.StartType -match $Filter -or $_.StartMode -match $Filter} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()

            if ($script:AutoChart03ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart03ServicesTitle.ForeColor = 'Black'
                $script:AutoChart03ServicesTitle.Text = "$Filter Startup Services"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03ServicesOverallDataResults = @()

                $FilteredData = $script:AutoChartDataSourceCsv | Where-Object {$_.StartType -match $Filter -or $_.StartMode -match $Filter}

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ServicesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03ServicesCsvComputers = @()
                    foreach ( $Line in $FilteredData ) {
                        if ($Line.Name -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart03ServicesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03ServicesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03ServicesUniqueCount = $script:AutoChart03ServicesCsvComputers.Count
                    $script:AutoChart03ServicesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ServicesUniqueCount
                        Computers   = $script:AutoChart03ServicesCsvComputers
                    }
                    $script:AutoChart03ServicesOverallDataResults += $script:AutoChart03ServicesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()

                }
                $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:AutoChart03ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ServicesOverallDataResults.count))
                $script:AutoChart03ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart03ServicesTitle.ForeColor = 'Red'
                $script:AutoChart03ServicesTitle.Text = "$Filter Startup Services`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03 -Filter 'Auto'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ServicesOptionsButton
$script:AutoChart03ServicesOptionsButton.Add_Click({
    if ($script:AutoChart03ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart03Services.Controls.Add($script:AutoChart03ServicesManipulationPanel)
    }
    elseif ($script:AutoChart03ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart03Services.Controls.Remove($script:AutoChart03ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ServicesOptionsButton)


# A filter combobox to modify what is displayed
$script:AutoChart03ServicesFilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Auto'
    Location  = @{ X = $script:AutoChart03ServicesOptionsButton.Location.X + 1
                    Y = $script:AutoChart03ServicesOptionsButton.Location.Y - $script:AutoChart03ServicesOptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ServicesFilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart03 -Filter $script:AutoChart03ServicesFilterComboBox.SelectedItem
#    $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
#    $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
 $WhichVersionStart = $script:AutoChartDataSourceCsv | Where-Object {$_.StartType -match $Filter -or $_.StartMode -match $Filter}
if ($WhichVersionStart.StartType -ne $null) {
    $script:AutoChart03ServicesFilterAvailable = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty StartType -Unique
    if ($script:AutoChart03ServicesFilterAvailable.Count -eq 0){ $script:AutoChartDataSourceCsv | Select-Object StartType -Unique | ForEach-Object { if ($script:AutoChart03ServicesFilterAvailable -inotcontains $_.StartType) {$script:AutoChart03ServicesFilterAvailable += $_.StartType}} }
}
else {
    $script:AutoChart03ServicesFilterAvailable = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty StartMode -Unique
    if ($script:AutoChart03ServicesFilterAvailable.Count -eq 0){ $script:AutoChartDataSourceCsv | Select-Object StartMode -Unique | ForEach-Object { if ($script:AutoChart03ServicesFilterAvailable -inotcontains $_.StartMode) {$script:AutoChart03ServicesFilterAvailable += $_.StartMode}} }
}
ForEach ($Item in $script:AutoChart03ServicesFilterAvailable) { $script:AutoChart03ServicesFilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ServicesFilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03Services)


$script:AutoChart03ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ServicesOverallDataResults.count))
    $script:AutoChart03ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ServicesTrimOffFirstTrackBarValue = $script:AutoChart03ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart03ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
        $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart03ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ServicesTrimOffFirstTrackBar)
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart03ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart03ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ServicesOverallDataResults.count))
    $script:AutoChart03ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart03ServicesOverallDataResults.count)
    $script:AutoChart03ServicesTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ServicesTrimOffLastTrackBarValue = $($script:AutoChart03ServicesOverallDataResults.count) - $script:AutoChart03ServicesTrimOffLastTrackBar.Value
        $script:AutoChart03ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ServicesOverallDataResults.count) - $script:AutoChart03ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
        $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart03ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart03ServicesTrimOffLastTrackBar)
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Services.Series["Automatic Startup Services"].ChartType = $script:AutoChart03ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
#    $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart03ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ServicesChartTypesAvailable) { $script:AutoChart03ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ServicesChartTypeComboBox.Location.X + $script:AutoChart03ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03Services3DToggleButton
$script:AutoChart03Services3DInclination = 0
$script:AutoChart03Services3DToggleButton.Add_Click({
    $script:AutoChart03Services3DInclination += 10
    if ( $script:AutoChart03Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ServicesArea.Area3DStyle.Inclination = $script:AutoChart03Services3DInclination
        $script:AutoChart03Services3DToggleButton.Text  = "3D On ($script:AutoChart03Services3DInclination)"
#        $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
#        $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03Services3DInclination -le 90 ) {
        $script:AutoChart03ServicesArea.Area3DStyle.Inclination = $script:AutoChart03Services3DInclination
        $script:AutoChart03Services3DToggleButton.Text  = "3D On ($script:AutoChart03Services3DInclination)"
#        $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
#        $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart03Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart03Services3DInclination = 0
        $script:AutoChart03ServicesArea.Area3DStyle.Inclination = $script:AutoChart03Services3DInclination
        $script:AutoChart03ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
#        $script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03Services3DToggleButton)

### Change the color of the chart
$script:AutoChart03ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03Services3DToggleButton.Location.X + $script:AutoChart03Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ServicesColorsAvailable) { $script:AutoChart03ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03Services.Series["Automatic Startup Services"].Color = $script:AutoChart03ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {
    # List of Positive Endpoints that positively match
    $script:AutoChart03ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart03ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ServicesImportCsvPosResults) { $script:AutoChart03ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ServicesImportCsvPosResults) { $script:AutoChart03ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ServicesImportCsvNegResults) { $script:AutoChart03ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ServicesImportCsvPosResults.count))"
    $script:AutoChart03ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart03ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03ServicesCheckDiffButton
$script:AutoChart03ServicesCheckDiffButton.Add_Click({
    $script:AutoChart03ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart03ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ServicesInvestDiffDropDownArray) { $script:AutoChart03ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03ServicesInvestDiffExecuteButton
    $script:AutoChart03ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart03ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart03ServicesInvestDiffDropDownLabel,$script:AutoChart03ServicesInvestDiffDropDownComboBox,$script:AutoChart03ServicesInvestDiffExecuteButton,$script:AutoChart03ServicesInvestDiffPosResultsLabel,$script:AutoChart03ServicesInvestDiffPosResultsTextBox,$script:AutoChart03ServicesInvestDiffNegResultsLabel,$script:AutoChart03ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart03ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart03ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ServicesManipulationPanel.controls.Add($script:AutoChart03ServicesCheckDiffButton)


$script:AutoChart03ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ServicesCheckDiffButton.Location.X + $script:AutoChart03ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:AutoChart03ServicesExpandChartButton
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesExpandChartButton)


$script:AutoChart03ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart03ServicesCheckDiffButton.Location.Y + $script:AutoChart03ServicesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ServicesOpenInShell
$script:AutoChart03ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03ServicesManipulationPanel.controls.Add($script:AutoChart03ServicesOpenInShell)


$script:AutoChart03ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ServicesOpenInShell.Location.X + $script:AutoChart03ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ServicesResults
$script:AutoChart03ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03ServicesManipulationPanel.controls.Add($script:AutoChart03ServicesResults)

### Save the chart to file
$script:AutoChart03ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ServicesOpenInShell.Location.X
                  Y = $script:AutoChart03ServicesOpenInShell.Location.Y + $script:AutoChart03ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03Services -Title $script:AutoChart03ServicesTitle
})
$script:AutoChart03ServicesManipulationPanel.controls.Add($script:AutoChart03ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ServicesSaveButton.Location.X
                        Y = $script:AutoChart03ServicesSaveButton.Location.Y + $script:AutoChart03ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ServicesManipulationPanel.Controls.Add($script:AutoChart03ServicesNoticeTextbox)

$script:AutoChart03Services.Series["Automatic Startup Services"].Points.Clear()
$script:AutoChart03ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03Services.Series["Automatic Startup Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}





















##############################################################################################
# AutoChart04
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02Services.Location.X
                  Y = $script:AutoChart02Services.Location.Y + $script:AutoChart02Services.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04Services.Titles.Add($script:AutoChart04ServicesTitle)

### Create Charts Area
$script:AutoChart04ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ServicesArea.Name        = 'Chart Area'
$script:AutoChart04ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart04ServicesArea.AxisX.Interval          = 1
$script:AutoChart04ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart04Services.ChartAreas.Add($script:AutoChart04ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04Services.Series.Add("Services Started By LocalSystem")
$script:AutoChart04Services.Series["Services Started By LocalSystem"].Enabled           = $True
$script:AutoChart04Services.Series["Services Started By LocalSystem"].BorderWidth       = 1
$script:AutoChart04Services.Series["Services Started By LocalSystem"].IsVisibleInLegend = $false
$script:AutoChart04Services.Series["Services Started By LocalSystem"].Chartarea         = 'Chart Area'
$script:AutoChart04Services.Series["Services Started By LocalSystem"].Legend            = 'Legend'
$script:AutoChart04Services.Series["Services Started By LocalSystem"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04Services.Series["Services Started By LocalSystem"]['PieLineColor']   = 'Black'
$script:AutoChart04Services.Series["Services Started By LocalSystem"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04Services.Series["Services Started By LocalSystem"].ChartType         = 'Column'
$script:AutoChart04Services.Series["Services Started By LocalSystem"].Color             = 'Orange'

        function Generate-AutoChart04 ($Filter) {
            $script:AutoChart04ServicesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart04ServicesUniqueDataFields  = $script:AutoChartDataSourceCsv | Where-Object {$_.StartName -eq "$Filter"} | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()

            if ($script:AutoChart04ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart04ServicesTitle.ForeColor = 'Black'
                $script:AutoChart04ServicesTitle.Text = "Services Started By $Filter"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04ServicesOverallDataResults = @()

                $FilteredData = $script:AutoChartDataSourceCsv | Where-Object {$_.StartName -eq "$Filter"}

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ServicesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04ServicesCsvComputers = @()
                    foreach ( $Line in $FilteredData ) {
                        if ($($Line.Name) -eq $DataField.Name) {
                            $Count += 1
                            if ( $script:AutoChart04ServicesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04ServicesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04ServicesUniqueCount = $script:AutoChart04ServicesCsvComputers.Count
                    $script:AutoChart04ServicesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ServicesUniqueCount
                        Computers   = $script:AutoChart04ServicesCsvComputers
                    }
                    $script:AutoChart04ServicesOverallDataResults += $script:AutoChart04ServicesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()

                }
                $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }

                $script:AutoChart04ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ServicesOverallDataResults.count))
                $script:AutoChart04ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart04ServicesTitle.ForeColor = 'Red'
                $script:AutoChart04ServicesTitle.Text = "Services Started By $Filter`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04 -Filter 'LocalSystem'

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ServicesOptionsButton
$script:AutoChart04ServicesOptionsButton.Add_Click({
    if ($script:AutoChart04ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart04Services.Controls.Add($script:AutoChart04ServicesManipulationPanel)
    }
    elseif ($script:AutoChart04ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart04Services.Controls.Remove($script:AutoChart04ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ServicesOptionsButton)


# A filter combobox to modify what is displayed
$script:AutoChart04ServicesFilterComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text = 'LocalSystem'
    Location  = @{ X = $script:AutoChart04ServicesOptionsButton.Location.X + 1
                    Y = $script:AutoChart04ServicesOptionsButton.Location.Y - $script:AutoChart04ServicesOptionsButton.Size.Height - $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 76
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ServicesFilterComboBox.add_SelectedIndexChanged({
    Generate-AutoChart04 -Filter $script:AutoChart04ServicesFilterComboBox.SelectedItem
#    $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
#    $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart04ServicesFilterAvailable = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty StartName -Unique
ForEach ($Item in $script:AutoChart04ServicesFilterAvailable) { $script:AutoChart04ServicesFilterComboBox.Items.Add($Item) }
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ServicesFilterComboBox)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04Services)
$script:AutoChart04ServicesFilterComboBox.SelectedIndeX = 0


$script:AutoChart04ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ServicesOverallDataResults.count))
    $script:AutoChart04ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ServicesTrimOffFirstTrackBarValue = $script:AutoChart04ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart04ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
        $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart04ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ServicesTrimOffFirstTrackBar)
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart04ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart04ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ServicesOverallDataResults.count))
    $script:AutoChart04ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart04ServicesOverallDataResults.count)
    $script:AutoChart04ServicesTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ServicesTrimOffLastTrackBarValue = $($script:AutoChart04ServicesOverallDataResults.count) - $script:AutoChart04ServicesTrimOffLastTrackBar.Value
        $script:AutoChart04ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ServicesOverallDataResults.count) - $script:AutoChart04ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
        $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart04ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart04ServicesTrimOffLastTrackBar)
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Services.Series["Services Started By LocalSystem"].ChartType = $script:AutoChart04ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
#    $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart04ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ServicesChartTypesAvailable) { $script:AutoChart04ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ServicesChartTypeComboBox.Location.X + $script:AutoChart04ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04Services3DToggleButton
$script:AutoChart04Services3DInclination = 0
$script:AutoChart04Services3DToggleButton.Add_Click({
    $script:AutoChart04Services3DInclination += 10
    if ( $script:AutoChart04Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ServicesArea.Area3DStyle.Inclination = $script:AutoChart04Services3DInclination
        $script:AutoChart04Services3DToggleButton.Text  = "3D On ($script:AutoChart04Services3DInclination)"
#        $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04Services3DInclination -le 90 ) {
        $script:AutoChart04ServicesArea.Area3DStyle.Inclination = $script:AutoChart04Services3DInclination
        $script:AutoChart04Services3DToggleButton.Text  = "3D On ($script:AutoChart04Services3DInclination)"
#        $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else {
        $script:AutoChart04Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart04Services3DInclination = 0
        $script:AutoChart04ServicesArea.Area3DStyle.Inclination = $script:AutoChart04Services3DInclination
        $script:AutoChart04ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
#        $script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04Services3DToggleButton)

### Change the color of the chart
$script:AutoChart04ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04Services3DToggleButton.Location.X + $script:AutoChart04Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ServicesColorsAvailable) { $script:AutoChart04ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04Services.Series["Services Started By LocalSystem"].Color = $script:AutoChart04ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {
    # List of Positive Endpoints that positively match
    $script:AutoChart04ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart04ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ServicesImportCsvPosResults) { $script:AutoChart04ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ServicesImportCsvPosResults) { $script:AutoChart04ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ServicesImportCsvNegResults) { $script:AutoChart04ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ServicesImportCsvPosResults.count))"
    $script:AutoChart04ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart04ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04ServicesCheckDiffButton
$script:AutoChart04ServicesCheckDiffButton.Add_Click({
    $script:AutoChart04ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart04ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ServicesInvestDiffDropDownArray) { $script:AutoChart04ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04ServicesInvestDiffExecuteButton
    $script:AutoChart04ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart04ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart04ServicesInvestDiffDropDownLabel,$script:AutoChart04ServicesInvestDiffDropDownComboBox,$script:AutoChart04ServicesInvestDiffExecuteButton,$script:AutoChart04ServicesInvestDiffPosResultsLabel,$script:AutoChart04ServicesInvestDiffPosResultsTextBox,$script:AutoChart04ServicesInvestDiffNegResultsLabel,$script:AutoChart04ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart04ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart04ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ServicesManipulationPanel.controls.Add($script:AutoChart04ServicesCheckDiffButton)


$script:AutoChart04ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ServicesCheckDiffButton.Location.X + $script:AutoChart04ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:AutoChart04ServicesExpandChartButton
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesExpandChartButton)


$script:AutoChart04ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart04ServicesCheckDiffButton.Location.Y + $script:AutoChart04ServicesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ServicesOpenInShell
$script:AutoChart04ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04ServicesManipulationPanel.controls.Add($script:AutoChart04ServicesOpenInShell)


$script:AutoChart04ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ServicesOpenInShell.Location.X + $script:AutoChart04ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ServicesResults
$script:AutoChart04ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04ServicesManipulationPanel.controls.Add($script:AutoChart04ServicesResults)

### Save the chart to file
$script:AutoChart04ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ServicesOpenInShell.Location.X
                  Y = $script:AutoChart04ServicesOpenInShell.Location.Y + $script:AutoChart04ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04Services -Title $script:AutoChart04ServicesTitle
})
$script:AutoChart04ServicesManipulationPanel.controls.Add($script:AutoChart04ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ServicesSaveButton.Location.X
                        Y = $script:AutoChart04ServicesSaveButton.Location.Y + $script:AutoChart04ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ServicesManipulationPanel.Controls.Add($script:AutoChart04ServicesNoticeTextbox)

$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.Clear()
$script:AutoChart04ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04Services.Series["Services Started By LocalSystem"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}






















##############################################################################################
# AutoChart05
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03Services.Location.X
                  Y = $script:AutoChart03Services.Location.Y + $script:AutoChart03Services.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05Services.Titles.Add($script:AutoChart05ServicesTitle)

### Create Charts Area
$script:AutoChart05ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ServicesArea.Name        = 'Chart Area'
$script:AutoChart05ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart05ServicesArea.AxisX.Interval          = 1
$script:AutoChart05ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart05Services.ChartAreas.Add($script:AutoChart05ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05Services.Series.Add("Processes That Started Services ")
$script:AutoChart05Services.Series["Processes That Started Services "].Enabled           = $True
$script:AutoChart05Services.Series["Processes That Started Services "].BorderWidth       = 1
$script:AutoChart05Services.Series["Processes That Started Services "].IsVisibleInLegend = $false
$script:AutoChart05Services.Series["Processes That Started Services "].Chartarea         = 'Chart Area'
$script:AutoChart05Services.Series["Processes That Started Services "].Legend            = 'Legend'
$script:AutoChart05Services.Series["Processes That Started Services "].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05Services.Series["Processes That Started Services "]['PieLineColor']   = 'Black'
$script:AutoChart05Services.Series["Processes That Started Services "]['PieLabelStyle']  = 'Outside'
$script:AutoChart05Services.Series["Processes That Started Services "].ChartType         = 'Column'
$script:AutoChart05Services.Series["Processes That Started Services "].Color             = 'Brown'

        function Generate-AutoChart05 {
            $script:AutoChart05ServicesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart05ServicesUniqueDataFields  = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'} | Select-Object -Property 'ProcessName' | Sort-Object -Property 'ProcessName' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()

            if ($script:AutoChart05ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart05ServicesTitle.ForeColor = 'Black'
                $script:AutoChart05ServicesTitle.Text = "Processes That Started Services "

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart05ServicesOverallDataResults = @()

                $FilteredData = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'}

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05ServicesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart05ServicesCsvComputers = @()
                    foreach ( $Line in $FilteredData ) {
                        if ($Line.ProcessName -eq $DataField.ProcessName) {
                            $Count += 1
                            if ( $script:AutoChart05ServicesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart05ServicesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    if ($Count -gt 0) {
                        $script:AutoChart05ServicesUniqueCount = $script:AutoChart05ServicesCsvComputers.Count
                        $script:AutoChart05ServicesDataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:AutoChart05ServicesUniqueCount
                            Computers   = $script:AutoChart05ServicesCsvComputers
                        }
                        $script:AutoChart05ServicesOverallDataResults += $script:AutoChart05ServicesDataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()

                    }
                }
                $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
                $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}

                $script:AutoChart05ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ServicesOverallDataResults.count))
                $script:AutoChart05ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart05ServicesTitle.ForeColor = 'Red'
                $script:AutoChart05ServicesTitle.Text = "Processes That Started Services `n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart05

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ServicesOptionsButton
$script:AutoChart05ServicesOptionsButton.Add_Click({
    if ($script:AutoChart05ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart05Services.Controls.Add($script:AutoChart05ServicesManipulationPanel)
    }
    elseif ($script:AutoChart05ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart05Services.Controls.Remove($script:AutoChart05ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ServicesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05Services)

$script:AutoChart05ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ServicesOverallDataResults.count))
    $script:AutoChart05ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ServicesTrimOffFirstTrackBarValue = $script:AutoChart05ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart05ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
        $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    })
    $script:AutoChart05ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ServicesTrimOffFirstTrackBar)
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart05ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart05ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ServicesOverallDataResults.count))
    $script:AutoChart05ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart05ServicesOverallDataResults.count)
    $script:AutoChart05ServicesTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ServicesTrimOffLastTrackBarValue = $($script:AutoChart05ServicesOverallDataResults.count) - $script:AutoChart05ServicesTrimOffLastTrackBar.Value
        $script:AutoChart05ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ServicesOverallDataResults.count) - $script:AutoChart05ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
        $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    })
$script:AutoChart05ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart05ServicesTrimOffLastTrackBar)
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Services.Series["Processes That Started Services "].ChartType = $script:AutoChart05ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
#    $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
})
$script:AutoChart05ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ServicesChartTypesAvailable) { $script:AutoChart05ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ServicesChartTypeComboBox.Location.X + $script:AutoChart05ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05Services3DToggleButton
$script:AutoChart05Services3DInclination = 0
$script:AutoChart05Services3DToggleButton.Add_Click({
    $script:AutoChart05Services3DInclination += 10
    if ( $script:AutoChart05Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ServicesArea.Area3DStyle.Inclination = $script:AutoChart05Services3DInclination
        $script:AutoChart05Services3DToggleButton.Text  = "3D On ($script:AutoChart05Services3DInclination)"
#        $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
#        $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05Services3DInclination -le 90 ) {
        $script:AutoChart05ServicesArea.Area3DStyle.Inclination = $script:AutoChart05Services3DInclination
        $script:AutoChart05Services3DToggleButton.Text  = "3D On ($script:AutoChart05Services3DInclination)"
#        $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
#        $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
    else {
        $script:AutoChart05Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart05Services3DInclination = 0
        $script:AutoChart05ServicesArea.Area3DStyle.Inclination = $script:AutoChart05Services3DInclination
        $script:AutoChart05ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
#        $script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}
    }
})
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05Services3DToggleButton)

### Change the color of the chart
$script:AutoChart05ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05Services3DToggleButton.Location.X + $script:AutoChart05Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ServicesColorsAvailable) { $script:AutoChart05ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05Services.Series["Processes That Started Services "].Color = $script:AutoChart05ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {
    # List of Positive Endpoints that positively match
    $script:AutoChart05ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ProcessName' -eq $($script:AutoChart05ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ServicesImportCsvPosResults) { $script:AutoChart05ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart05ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ServicesImportCsvPosResults) { $script:AutoChart05ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ServicesImportCsvNegResults) { $script:AutoChart05ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ServicesImportCsvPosResults.count))"
    $script:AutoChart05ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart05ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05ServicesCheckDiffButton
$script:AutoChart05ServicesCheckDiffButton.Add_Click({
    $script:AutoChart05ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'ProcessName' -ExpandProperty 'ProcessName' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart05ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ServicesInvestDiffDropDownArray) { $script:AutoChart05ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05ServicesInvestDiffExecuteButton
    $script:AutoChart05ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart05ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart05ServicesInvestDiffDropDownLabel,$script:AutoChart05ServicesInvestDiffDropDownComboBox,$script:AutoChart05ServicesInvestDiffExecuteButton,$script:AutoChart05ServicesInvestDiffPosResultsLabel,$script:AutoChart05ServicesInvestDiffPosResultsTextBox,$script:AutoChart05ServicesInvestDiffNegResultsLabel,$script:AutoChart05ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart05ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart05ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ServicesManipulationPanel.controls.Add($script:AutoChart05ServicesCheckDiffButton)


$script:AutoChart05ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ServicesCheckDiffButton.Location.X + $script:AutoChart05ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:AutoChart05ServicesExpandChartButton
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesExpandChartButton)


$script:AutoChart05ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart05ServicesCheckDiffButton.Location.Y + $script:AutoChart05ServicesCheckDiffButton.Size.Height + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ServicesOpenInShell
$script:AutoChart05ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05ServicesManipulationPanel.controls.Add($script:AutoChart05ServicesOpenInShell)


$script:AutoChart05ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ServicesOpenInShell.Location.X + $script:AutoChart05ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ServicesResults
$script:AutoChart05ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05ServicesManipulationPanel.controls.Add($script:AutoChart05ServicesResults)

### Save the chart to file
$script:AutoChart05ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ServicesOpenInShell.Location.X
                  Y = $script:AutoChart05ServicesOpenInShell.Location.Y + $script:AutoChart05ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05Services -Title $script:AutoChart05ServicesTitle
})
$script:AutoChart05ServicesManipulationPanel.controls.Add($script:AutoChart05ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ServicesSaveButton.Location.X
                        Y = $script:AutoChart05ServicesSaveButton.Location.Y + $script:AutoChart05ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ServicesManipulationPanel.Controls.Add($script:AutoChart05ServicesNoticeTextbox)

$script:AutoChart05Services.Series["Processes That Started Services "].Points.Clear()
$script:AutoChart05ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05Services.Series["Processes That Started Services "].Points.AddXY($_.DataField.ProcessName,$_.UniqueCount)}






















#
##############################################################################################
# AutoChart06
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06Services = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04Services.Location.X
                  Y = $script:AutoChart04Services.Location.Y + $script:AutoChart04Services.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06Services.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06ServicesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06Services.Titles.Add($script:AutoChart06ServicesTitle)

### Create Charts Area
$script:AutoChart06ServicesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ServicesArea.Name        = 'Chart Area'
$script:AutoChart06ServicesArea.AxisX.Title = 'Hosts'
$script:AutoChart06ServicesArea.AxisX.Interval          = 1
$script:AutoChart06ServicesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ServicesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ServicesArea.Area3DStyle.Inclination = 75
$script:AutoChart06Services.ChartAreas.Add($script:AutoChart06ServicesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06Services.Series.Add("Accounts That Started Services")
$script:AutoChart06Services.Series["Accounts That Started Services"].Enabled           = $True
$script:AutoChart06Services.Series["Accounts That Started Services"].BorderWidth       = 1
$script:AutoChart06Services.Series["Accounts That Started Services"].IsVisibleInLegend = $false
$script:AutoChart06Services.Series["Accounts That Started Services"].Chartarea         = 'Chart Area'
$script:AutoChart06Services.Series["Accounts That Started Services"].Legend            = 'Legend'
$script:AutoChart06Services.Series["Accounts That Started Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06Services.Series["Accounts That Started Services"]['PieLineColor']   = 'Black'
$script:AutoChart06Services.Series["Accounts That Started Services"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06Services.Series["Accounts That Started Services"].ChartType         = 'Column'
$script:AutoChart06Services.Series["Accounts That Started Services"].Color             = 'Gray'

        function Generate-AutoChart06 {
            $script:AutoChart06ServicesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart06ServicesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'StartName' | Sort-Object -Property 'StartName' -Unique
#            $script:AutoChart05ServicesUniqueDataFields  = $script:AutoChartDataSourceCsv | Where-Object {$_.State -eq 'Running' -or $_.Status -eq 'Running'} | Select-Object -Property 'ProcessName' | Sort-Object -Property 'ProcessName' -Unique
#batman
            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ServicesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()


            $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()

            if ($script:AutoChart06ServicesUniqueDataFields.count -gt 0){
                $script:AutoChart06ServicesTitle.ForeColor = 'Black'
                $script:AutoChart06ServicesTitle.Text = "Accounts That Started Services"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart06ServicesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06ServicesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06ServicesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.StartName) -eq $DataField.StartName) {
                            $Count += 1
                            if ( $script:AutoChart06ServicesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart06ServicesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart06ServicesUniqueCount = $script:AutoChart06ServicesCsvComputers.Count
                    $script:AutoChart06ServicesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06ServicesUniqueCount
                        Computers   = $script:AutoChart06ServicesCsvComputers
                    }
                    $script:AutoChart06ServicesOverallDataResults += $script:AutoChart06ServicesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()

                }
                $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount) }

                $script:AutoChart06ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ServicesOverallDataResults.count))
                $script:AutoChart06ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ServicesOverallDataResults.count))
            }
            else {
                $script:AutoChart06ServicesTitle.ForeColor = 'Red'
                $script:AutoChart06ServicesTitle.Text = "Accounts That Started Services`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart06

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06ServicesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06Services.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06Services.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ServicesOptionsButton
$script:AutoChart06ServicesOptionsButton.Add_Click({
    if ($script:AutoChart06ServicesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ServicesOptionsButton.Text = 'Options ^'
        $script:AutoChart06Services.Controls.Add($script:AutoChart06ServicesManipulationPanel)
    }
    elseif ($script:AutoChart06ServicesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ServicesOptionsButton.Text = 'Options v'
        $script:AutoChart06Services.Controls.Remove($script:AutoChart06ServicesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ServicesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06Services)

$script:AutoChart06ServicesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06Services.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06Services.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ServicesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ServicesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ServicesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ServicesOverallDataResults.count))
    $script:AutoChart06ServicesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ServicesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ServicesTrimOffFirstTrackBarValue = $script:AutoChart06ServicesTrimOffFirstTrackBar.Value
        $script:AutoChart06ServicesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ServicesTrimOffFirstTrackBar.Value)"
        $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
        $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    })
    $script:AutoChart06ServicesTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ServicesTrimOffFirstTrackBar)
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ServicesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ServicesTrimOffFirstGroupBox.Location.X + $script:AutoChart06ServicesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart06ServicesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ServicesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ServicesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ServicesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ServicesOverallDataResults.count))
    $script:AutoChart06ServicesTrimOffLastTrackBar.Value         = $($script:AutoChart06ServicesOverallDataResults.count)
    $script:AutoChart06ServicesTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ServicesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ServicesTrimOffLastTrackBarValue = $($script:AutoChart06ServicesOverallDataResults.count) - $script:AutoChart06ServicesTrimOffLastTrackBar.Value
        $script:AutoChart06ServicesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ServicesOverallDataResults.count) - $script:AutoChart06ServicesTrimOffLastTrackBar.Value)"
        $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
        $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    })
$script:AutoChart06ServicesTrimOffLastGroupBox.Controls.Add($script:AutoChart06ServicesTrimOffLastTrackBar)
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ServicesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06ServicesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ServicesTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ServicesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ServicesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Services.Series["Accounts That Started Services"].ChartType = $script:AutoChart06ServicesChartTypeComboBox.SelectedItem
#    $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
#    $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
})
$script:AutoChart06ServicesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ServicesChartTypesAvailable) { $script:AutoChart06ServicesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06Services3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ServicesChartTypeComboBox.Location.X + $script:AutoChart06ServicesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ServicesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06Services3DToggleButton
$script:AutoChart06Services3DInclination = 0
$script:AutoChart06Services3DToggleButton.Add_Click({
    $script:AutoChart06Services3DInclination += 10
    if ( $script:AutoChart06Services3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06ServicesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ServicesArea.Area3DStyle.Inclination = $script:AutoChart06Services3DInclination
        $script:AutoChart06Services3DToggleButton.Text  = "3D On ($script:AutoChart06Services3DInclination)"
#        $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
#        $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06Services3DInclination -le 90 ) {
        $script:AutoChart06ServicesArea.Area3DStyle.Inclination = $script:AutoChart06Services3DInclination
        $script:AutoChart06Services3DToggleButton.Text  = "3D On ($script:AutoChart06Services3DInclination)"
#        $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
#        $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
    else {
        $script:AutoChart06Services3DToggleButton.Text  = "3D Off"
        $script:AutoChart06Services3DInclination = 0
        $script:AutoChart06ServicesArea.Area3DStyle.Inclination = $script:AutoChart06Services3DInclination
        $script:AutoChart06ServicesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
#        $script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}
    }
})
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06Services3DToggleButton)

### Change the color of the chart
$script:AutoChart06ServicesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06Services3DToggleButton.Location.X + $script:AutoChart06Services3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06Services3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ServicesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ServicesColorsAvailable) { $script:AutoChart06ServicesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ServicesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06Services.Series["Accounts That Started Services"].Color = $script:AutoChart06ServicesChangeColorComboBox.SelectedItem
})
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {
    # List of Positive Endpoints that positively match
    $script:AutoChart06ServicesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'StartName' -eq $($script:AutoChart06ServicesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06ServicesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ServicesImportCsvPosResults) { $script:AutoChart06ServicesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ServicesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart06ServicesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ServicesImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ServicesImportCsvPosResults) { $script:AutoChart06ServicesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ServicesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ServicesImportCsvNegResults) { $script:AutoChart06ServicesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ServicesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ServicesImportCsvPosResults.count))"
    $script:AutoChart06ServicesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ServicesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ServicesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ServicesTrimOffLastGroupBox.Location.X + $script:AutoChart06ServicesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ServicesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06ServicesCheckDiffButton
$script:AutoChart06ServicesCheckDiffButton.Add_Click({
    $script:AutoChart06ServicesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'StartName' -ExpandProperty 'StartName' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ServicesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ServicesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ServicesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ServicesInvestDiffDropDownLabel.Location.y + $script:AutoChart06ServicesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ServicesInvestDiffDropDownArray) { $script:AutoChart06ServicesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ServicesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06ServicesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06ServicesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ServicesInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ServicesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06ServicesInvestDiffExecuteButton
    $script:AutoChart06ServicesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06ServicesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ServicesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ServicesInvestDiffExecuteButton.Location.y + $script:AutoChart06ServicesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ServicesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ServicesInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ServicesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ServicesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ServicesInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ServicesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06ServicesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ServicesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ServicesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ServicesInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ServicesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ServicesInvestDiffForm.Controls.AddRange(@($script:AutoChart06ServicesInvestDiffDropDownLabel,$script:AutoChart06ServicesInvestDiffDropDownComboBox,$script:AutoChart06ServicesInvestDiffExecuteButton,$script:AutoChart06ServicesInvestDiffPosResultsLabel,$script:AutoChart06ServicesInvestDiffPosResultsTextBox,$script:AutoChart06ServicesInvestDiffNegResultsLabel,$script:AutoChart06ServicesInvestDiffNegResultsTextBox))
    $script:AutoChart06ServicesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ServicesInvestDiffForm.ShowDialog()
})
$script:AutoChart06ServicesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ServicesManipulationPanel.controls.Add($script:AutoChart06ServicesCheckDiffButton)


$script:AutoChart06ServicesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ServicesCheckDiffButton.Location.X + $script:AutoChart06ServicesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ServicesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartOpenResultsOpenFileDialogfilename -QueryName "Services" -QueryTabName "Service Names" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $script:AutoChart06ServicesExpandChartButton
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesExpandChartButton)


$script:AutoChart06ServicesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ServicesCheckDiffButton.Location.X
                   Y = $script:AutoChart06ServicesCheckDiffButton.Location.Y + $script:AutoChart06ServicesCheckDiffButton.Size.Height + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ServicesOpenInShell
$script:AutoChart06ServicesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06ServicesManipulationPanel.controls.Add($script:AutoChart06ServicesOpenInShell)


$script:AutoChart06ServicesResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ServicesOpenInShell.Location.X + $script:AutoChart06ServicesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ServicesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ServicesResults
$script:AutoChart06ServicesResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06ServicesManipulationPanel.controls.Add($script:AutoChart06ServicesResults)

### Save the chart to file
$script:AutoChart06ServicesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ServicesOpenInShell.Location.X
                  Y = $script:AutoChart06ServicesOpenInShell.Location.Y + $script:AutoChart06ServicesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ServicesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ServicesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06Services -Title $script:AutoChart06ServicesTitle
})
$script:AutoChart06ServicesManipulationPanel.controls.Add($script:AutoChart06ServicesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ServicesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ServicesSaveButton.Location.X
                        Y = $script:AutoChart06ServicesSaveButton.Location.Y + $script:AutoChart06ServicesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ServicesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ServicesManipulationPanel.Controls.Add($script:AutoChart06ServicesNoticeTextbox)

$script:AutoChart06Services.Series["Accounts That Started Services"].Points.Clear()
$script:AutoChart06ServicesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ServicesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ServicesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06Services.Series["Accounts That Started Services"].Points.AddXY($_.DataField.StartName,$_.UniqueCount)}


















