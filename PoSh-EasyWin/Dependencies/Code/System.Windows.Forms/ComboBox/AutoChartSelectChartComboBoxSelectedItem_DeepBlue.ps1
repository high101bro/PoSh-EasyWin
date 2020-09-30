$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Threat Hunting (Deep Blue)'
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

$script:AutoChart01DeepBlueCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Deep Blue' -or $CSVFile -match 'DeepBlue') { $script:AutoChart01DeepBlueCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01DeepBlueCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart01DeepBlue.Controls.Remove($script:AutoChart01DeepBlueManipulationPanel)
    $script:AutoChart02DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart02DeepBlue.Controls.Remove($script:AutoChart02DeepBlueManipulationPanel)
    $script:AutoChart03DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart03DeepBlue.Controls.Remove($script:AutoChart03DeepBlueManipulationPanel)
    $script:AutoChart04DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart04DeepBlue.Controls.Remove($script:AutoChart04DeepBlueManipulationPanel)
    $script:AutoChart05DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart05DeepBlue.Controls.Remove($script:AutoChart05DeepBlueManipulationPanel)
    $script:AutoChart06DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart06DeepBlue.Controls.Remove($script:AutoChart06DeepBlueManipulationPanel)
    $script:AutoChart07DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart07DeepBlue.Controls.Remove($script:AutoChart07DeepBlueManipulationPanel)
    $script:AutoChart08DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart08DeepBlue.Controls.Remove($script:AutoChart08DeepBlueManipulationPanel)
    $script:AutoChart09DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart09DeepBlue.Controls.Remove($script:AutoChart09DeepBlueManipulationPanel)
    $script:AutoChart10DeepBlueOptionsButton.Text = 'Options v'
    $script:AutoChart10DeepBlue.Controls.Remove($script:AutoChart10DeepBlueManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Threat Hunting (Deep Blue)'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','16', [System.Drawing.FontStyle]::Bold)
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
                Enabled = $false
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsDeepBlue -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsDeepBlue -ComputerNameList $script:ComputerList }
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

    Generate-AutoChart01DeepBlue
    Generate-AutoChart02DeepBlue
    Generate-AutoChart03DeepBlue
    Generate-AutoChart04DeepBlue
    Generate-AutoChart05DeepBlue
    Generate-AutoChart06DeepBlue
    Generate-AutoChart07DeepBlue
    Generate-AutoChart08DeepBlue
    Generate-AutoChart09DeepBlue
    Generate-AutoChart10DeepBlue
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
# AutoChart01DeepBlue
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01DeepBlue = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01DeepBlue.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01DeepBlueTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01DeepBlue.Titles.Add($script:AutoChart01DeepBlueTitle)

### Create Charts Area
$script:AutoChart01DeepBlueArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01DeepBlueArea.Name        = 'Chart Area'
$script:AutoChart01DeepBlueArea.AxisX.Title = 'Hosts'
$script:AutoChart01DeepBlueArea.AxisX.Interval          = 1
$script:AutoChart01DeepBlueArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01DeepBlueArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01DeepBlueArea.Area3DStyle.Inclination = 75
$script:AutoChart01DeepBlue.ChartAreas.Add($script:AutoChart01DeepBlueArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01DeepBlue.Series.Add("Application Name")
$script:AutoChart01DeepBlue.Series["Application Name"].Enabled           = $True
$script:AutoChart01DeepBlue.Series["Application Name"].BorderWidth       = 1
$script:AutoChart01DeepBlue.Series["Application Name"].IsVisibleInLegend = $false
$script:AutoChart01DeepBlue.Series["Application Name"].Chartarea         = 'Chart Area'
$script:AutoChart01DeepBlue.Series["Application Name"].Legend            = 'Legend'
$script:AutoChart01DeepBlue.Series["Application Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01DeepBlue.Series["Application Name"]['PieLineColor']   = 'Black'
$script:AutoChart01DeepBlue.Series["Application Name"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01DeepBlue.Series["Application Name"].ChartType         = 'Bar'
$script:AutoChart01DeepBlue.Series["Application Name"].Color             = 'Red'


            function Generate-AutoChart01DeepBlue {
                $script:AutoChart01DeepBlueCsvFileHosts     = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
                $script:AutoChart01DeepBlueUniqueDataFields = $script:AutoChartDataSourceCsv `
                | Select-Object -Property Message | Sort-Object Message -Unique

                $script:AutoChartsProgressBar.ForeColor = 'Red'
                $script:AutoChartsProgressBar.Minimum = 0
                $script:AutoChartsProgressBar.Maximum = $script:AutoChart01DeepBlueUniqueDataFields.count
                $script:AutoChartsProgressBar.Value   = 0
                $script:AutoChartsProgressBar.Update()

                $script:AutoChart01DeepBlue.Series["Application Name"].Points.Clear()

                if ($script:AutoChart01DeepBlueUniqueDataFields.count -gt 0){
                    $script:AutoChart01DeepBlueTitle.ForeColor = 'Black'
                    $script:AutoChart01DeepBlueTitle.Text = "Potentials Findings By Event Type"

                    # If the Second field/Y Axis equals PSComputername, it counts it
                    $script:AutoChart01DeepBlueOverallDataResults = @()

                    # Generates and Counts the data - Counts the number of times that any given property possess a given value
                    foreach ($DataField in $script:AutoChart01DeepBlueUniqueDataFields) {
                        $Count        = 0
                        $script:AutoChart01DeepBlueCsvComputers = @()
                        foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                            if ( $Line.Message -eq $DataField.Message) {
                                $Count += 1
                                if ( $script:AutoChart01DeepBlueCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01DeepBlueCsvComputers += $($Line.PSComputerName) }
                            }
                        }
                        $script:AutoChart01DeepBlueUniqueCount = $script:AutoChart01DeepBlueCsvComputers.Count
                        $script:AutoChart01DeepBlueDataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:AutoChart01DeepBlueUniqueCount
                            Computers   = $script:AutoChart01DeepBlueCsvComputers
                        }
                        $script:AutoChart01DeepBlueOverallDataResults += $script:AutoChart01DeepBlueDataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()
                    }
                    $script:AutoChart01DeepBlueSortButton.text = "View: Count"
                    $script:AutoChart01DeepBlueOverallDataResultsSortAlphaNum = $script:AutoChart01DeepBlueOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                    $script:AutoChart01DeepBlueOverallDataResultsSortCount    = $script:AutoChart01DeepBlueOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                    $script:AutoChart01DeepBlueOverallDataResults = $script:AutoChart01DeepBlueOverallDataResultsSortAlphaNum

                    $script:AutoChart01DeepBlueOverallDataResults | ForEach-Object { $script:AutoChart01DeepBlue.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount) }
                    $script:AutoChart01DeepBlueTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01DeepBlueOverallDataResults.count))
                    $script:AutoChart01DeepBlueTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01DeepBlueOverallDataResults.count))
                    }
                else {
                    $script:AutoChart01DeepBlueTitle.ForeColor = 'Red'
                    $script:AutoChart01DeepBlueTitle.Text = "Potentials Findings By Event Type`n
            [ No Data Available ]`n"
                }
            }
            Generate-AutoChart01DeepBlue


### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01DeepBlueOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01DeepBlue.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01DeepBlue.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueOptionsButton
$script:AutoChart01DeepBlueOptionsButton.Add_Click({
    if ($script:AutoChart01DeepBlueOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01DeepBlueOptionsButton.Text = 'Options ^'
        $script:AutoChart01DeepBlue.Controls.Add($script:AutoChart01DeepBlueManipulationPanel)
    }
    elseif ($script:AutoChart01DeepBlueOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01DeepBlueOptionsButton.Text = 'Options v'
        $script:AutoChart01DeepBlue.Controls.Remove($script:AutoChart01DeepBlueManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01DeepBlueOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01DeepBlue)


$script:AutoChart01DeepBlueManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01DeepBlue.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01DeepBlue.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01DeepBlueTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01DeepBlueTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01DeepBlueTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01DeepBlueOverallDataResults.count))
    $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01DeepBlueTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue = $script:AutoChart01DeepBlueTrimOffFirstTrackBar.Value
        $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01DeepBlueTrimOffFirstTrackBar.Value)"
        $script:AutoChart01DeepBlue.Series["Application Name"].Points.Clear()
        $script:AutoChart01DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01DeepBlue.Series["Application Name"].Points.AddXY($_.DataField.message,$_.UniqueCount)}
    })
    $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Controls.Add($script:AutoChart01DeepBlueTrimOffFirstTrackBar)
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlueTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01DeepBlueTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Location.X + $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01DeepBlueTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01DeepBlueTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01DeepBlueTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01DeepBlueOverallDataResults.count))
    $script:AutoChart01DeepBlueTrimOffLastTrackBar.Value         = $($script:AutoChart01DeepBlueOverallDataResults.count)
    $script:AutoChart01DeepBlueTrimOffLastTrackBarValue   = 0
    $script:AutoChart01DeepBlueTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01DeepBlueTrimOffLastTrackBarValue = $($script:AutoChart01DeepBlueOverallDataResults.count) - $script:AutoChart01DeepBlueTrimOffLastTrackBar.Value
        $script:AutoChart01DeepBlueTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01DeepBlueOverallDataResults.count) - $script:AutoChart01DeepBlueTrimOffLastTrackBar.Value)"
        $script:AutoChart01DeepBlue.Series["Application Name"].Points.Clear()
        $script:AutoChart01DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01DeepBlue.Series["Application Name"].Points.AddXY($_.DataField.message,$_.UniqueCount)}
    })
$script:AutoChart01DeepBlueTrimOffLastGroupBox.Controls.Add($script:AutoChart01DeepBlueTrimOffLastTrackBar)
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlueTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01DeepBlueChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar'
    Location  = @{ X = $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Location.Y + $script:AutoChart01DeepBlueTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01DeepBlueChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01DeepBlue.Series["Application Name"].ChartType = $script:AutoChart01DeepBlueChartTypeComboBox.SelectedItem
})
$script:AutoChart01DeepBlueChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01DeepBlueChartTypesAvailable) { $script:AutoChart01DeepBlueChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlueChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01DeepBlue3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01DeepBlueChartTypeComboBox.Location.X + $script:AutoChart01DeepBlueChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01DeepBlueChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlue3DToggleButton
$script:AutoChart01DeepBlue3DInclination = 0
$script:AutoChart01DeepBlue3DToggleButton.Add_Click({

    $script:AutoChart01DeepBlue3DInclination += 10
    if ( $script:AutoChart01DeepBlue3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01DeepBlueArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart01DeepBlue3DInclination
        $script:AutoChart01DeepBlue3DToggleButton.Text  = "3D On ($script:AutoChart01DeepBlue3DInclination)"
    }
    elseif ( $script:AutoChart01DeepBlue3DInclination -le 90 ) {
        $script:AutoChart01DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart01DeepBlue3DInclination
        $script:AutoChart01DeepBlue3DToggleButton.Text  = "3D On ($script:AutoChart01DeepBlue3DInclination)"
    }
    else {
        $script:AutoChart01DeepBlue3DToggleButton.Text  = "3D Off"
        $script:AutoChart01DeepBlue3DInclination = 0
        $script:AutoChart01DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart01DeepBlue3DInclination
        $script:AutoChart01DeepBlueArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlue3DToggleButton)

### Change the color of the chart
$script:AutoChart01DeepBlueChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01DeepBlue3DToggleButton.Location.X + $script:AutoChart01DeepBlue3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01DeepBlue3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01DeepBlueColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01DeepBlueColorsAvailable) { $script:AutoChart01DeepBlueChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01DeepBlueChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01DeepBlue.Series["Application Name"].Color = $script:AutoChart01DeepBlueChangeColorComboBox.SelectedItem
})
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlueChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01DeepBlue {
    # List of Positive Endpoints that positively match
    $script:AutoChart01DeepBlueImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object {$_.Message -eq $($script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Text)} | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01DeepBlueInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01DeepBlueImportCsvPosResults) { $script:AutoChart01DeepBlueInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01DeepBlueImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01DeepBlueImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01DeepBlueImportCsvAll) { if ($Endpoint -notin $script:AutoChart01DeepBlueImportCsvPosResults) { $script:AutoChart01DeepBlueImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01DeepBlueInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01DeepBlueImportCsvNegResults) { $script:AutoChart01DeepBlueInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01DeepBlueImportCsvPosResults.count))"
    $script:AutoChart01DeepBlueInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01DeepBlueImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01DeepBlueCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01DeepBlueTrimOffLastGroupBox.Location.X + $script:AutoChart01DeepBlueTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01DeepBlueTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueCheckDiffButton
$script:AutoChart01DeepBlueCheckDiffButton.Add_Click({
    $script:AutoChart01DeepBlueInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'Message' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01DeepBlueInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01DeepBlueInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01DeepBlueInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01DeepBlueInvestDiffDropDownLabel.Location.y + $script:AutoChart01DeepBlueInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01DeepBlueInvestDiffDropDownArray) { $script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01DeepBlue }})
    $script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01DeepBlue })

    ### Investigate Difference Execute Button
    $script:AutoChart01DeepBlueInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Location.y + $script:AutoChart01DeepBlueInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01DeepBlueInvestDiffExecuteButton
    $script:AutoChart01DeepBlueInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01DeepBlue }})
    $script:AutoChart01DeepBlueInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01DeepBlue })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01DeepBlueInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01DeepBlueInvestDiffExecuteButton.Location.y + $script:AutoChart01DeepBlueInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01DeepBlueInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Location.y + $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01DeepBlueInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Location.x + $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01DeepBlueInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01DeepBlueInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01DeepBlueInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01DeepBlueInvestDiffNegResultsLabel.Location.y + $script:AutoChart01DeepBlueInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01DeepBlueInvestDiffForm.Controls.AddRange(@($script:AutoChart01DeepBlueInvestDiffDropDownLabel,$script:AutoChart01DeepBlueInvestDiffDropDownComboBox,$script:AutoChart01DeepBlueInvestDiffExecuteButton,$script:AutoChart01DeepBlueInvestDiffPosResultsLabel,$script:AutoChart01DeepBlueInvestDiffPosResultsTextBox,$script:AutoChart01DeepBlueInvestDiffNegResultsLabel,$script:AutoChart01DeepBlueInvestDiffNegResultsTextBox))
    $script:AutoChart01DeepBlueInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01DeepBlueInvestDiffForm.ShowDialog()
})
$script:AutoChart01DeepBlueCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01DeepBlueManipulationPanel.controls.Add($script:AutoChart01DeepBlueCheckDiffButton)


$AutoChart01DeepBlueExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01DeepBlueCheckDiffButton.Location.X + $script:AutoChart01DeepBlueCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01DeepBlueCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Application Name" -QueryTabName "Application Name" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01DeepBlueExpandChartButton
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($AutoChart01DeepBlueExpandChartButton)


$script:AutoChart01DeepBlueOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01DeepBlueCheckDiffButton.Location.X
                   Y = $script:AutoChart01DeepBlueCheckDiffButton.Location.Y + $script:AutoChart01DeepBlueCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueOpenInShell
$script:AutoChart01DeepBlueOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01DeepBlueManipulationPanel.controls.Add($script:AutoChart01DeepBlueOpenInShell)


$script:AutoChart01DeepBlueSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart01DeepBlueOpenInShell.Location.X
                  Y = $script:AutoChart01DeepBlueOpenInShell.Location.Y + $script:AutoChart01DeepBlueOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueSortButton
$script:AutoChart01DeepBlueSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart01DeepBlueOverallDataResults = $script:AutoChart01DeepBlueOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart01DeepBlueOverallDataResults = $script:AutoChart01DeepBlueOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart01DeepBlue.Series["Application Name"].Points.Clear()
    $script:AutoChart01DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01DeepBlue.Series["Application Name"].Points.AddXY($_.DataField.message,$_.UniqueCount)}
})
$script:AutoChart01DeepBlueManipulationPanel.controls.Add($script:AutoChart01DeepBlueSortButton)


$script:AutoChart01DeepBlueViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01DeepBlueOpenInShell.Location.X + $script:AutoChart01DeepBlueOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01DeepBlueOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueViewResults
$script:AutoChart01DeepBlueViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart01DeepBlueManipulationPanel.controls.Add($script:AutoChart01DeepBlueViewResults)


### Save the chart to file
$script:AutoChart01DeepBlueSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01DeepBlueViewResults.Location.X
                  Y = $script:AutoChart01DeepBlueViewResults.Location.Y + $script:AutoChart01DeepBlueViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01DeepBlueSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01DeepBlueSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01DeepBlue -Title $script:AutoChart01DeepBlueTitle
})
$script:AutoChart01DeepBlueManipulationPanel.controls.Add($script:AutoChart01DeepBlueSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01DeepBlueNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01DeepBlueSortButton.Location.X
                        Y = $script:AutoChart01DeepBlueSortButton.Location.Y + $script:AutoChart01DeepBlueSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01DeepBlueCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01DeepBlueManipulationPanel.Controls.Add($script:AutoChart01DeepBlueNoticeTextbox)

$script:AutoChart01DeepBlue.Series["Application Name"].Points.Clear()
$script:AutoChart01DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart01DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01DeepBlue.Series["Application Name"].Points.AddXY($_.DataField.message,$_.UniqueCount)}























##############################################################################################
# AutoChart02DeepBlue
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02DeepBlue = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01DeepBlue.Location.X + $script:AutoChart01DeepBlue.Size.Width + 20
                  Y = $script:AutoChart01DeepBlue.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02DeepBlue.Add_MouseHover({ Close-AllOptions })


### Auto Create Charts Title
$script:AutoChart02DeepBlueTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02DeepBlue.Titles.Add($script:AutoChart02DeepBlueTitle)

### Create Charts Area
$script:AutoChart02DeepBlueArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02DeepBlueArea.Name        = 'Chart Area'
$script:AutoChart02DeepBlueArea.AxisX.Title = 'Hosts'
$script:AutoChart02DeepBlueArea.AxisX.Interval          = 1
$script:AutoChart02DeepBlueArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02DeepBlueArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02DeepBlueArea.Area3DStyle.Inclination = 75
$script:AutoChart02DeepBlue.ChartAreas.Add($script:AutoChart02DeepBlueArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02DeepBlue.Series.Add("Findings Per Endpoint")
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Enabled           = $True
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].BorderWidth       = 1
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].IsVisibleInLegend = $false
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Chartarea         = 'Chart Area'
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Legend            = 'Legend'
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"]['PieLineColor']   = 'Black'
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].ChartType         = 'Pie'
$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Color             = 'Blue'

    function Generate-AutoChart02DeepBlue {
            $script:AutoChart02DeepBlueCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart02DeepBlueUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Select-Object -Property Message | Sort-Object Message -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02DeepBlueUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02DeepBlueUniqueDataFields.count -gt 0){
                $script:AutoChart02DeepBlueTitle.ForeColor = 'Black'
                $script:AutoChart02DeepBlueTitle.Text = "Findings Per Endpoint"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02DeepBlueOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object PSComputerName) ) {
                    $LineName = $Line.Message
                    if ( $AutoChart02CheckIfFirstLine -eq $false ) { $AutoChart02CurrentComputer  = $Line.PSComputerName ; $AutoChart02CheckIfFirstLine = $true }
                    if ( $AutoChart02CheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart02CurrentComputer ) {
                            if ( $AutoChart02YResults -notcontains $LineName ) {
                                if ( $LineName -ne "" ) { $AutoChart02YResults += $LineName ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart02CurrentComputer ) {
                            $AutoChart02CurrentComputer = $Line.PSComputerName
                            $AutoChart02YDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02ResultsCount
                                Computer     = $AutoChart02Computer
                            }
                            $script:AutoChart02DeepBlueOverallDataResults += $AutoChart02YDataResults
                            $AutoChart02YResults     = @()
                            $AutoChart02ResultsCount = 0
                            $AutoChart02Computer     = @()
                            if ( $AutoChart02YResults -notcontains $LineName ) {
                                if ( $LineName -ne "" ) { $AutoChart02YResults += $LineName ; $AutoChart02ResultsCount += 1 }
                                if ( $AutoChart02Computer -notcontains $Line.PSComputerName ) { $AutoChart02Computer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02YDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02ResultsCount ; Computer = $AutoChart02Computer }
                $script:AutoChart02DeepBlueOverallDataResults += $AutoChart02YDataResults

                $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.Clear()

                $script:AutoChart02DeepBlueSortButton.text = "View: Count"
                $script:AutoChart02DeepBlueOverallDataResultsSortAlphaNum = $script:AutoChart02DeepBlueOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart02DeepBlueOverallDataResultsSortCount    = $script:AutoChart02DeepBlueOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart02DeepBlueOverallDataResults = $script:AutoChart02DeepBlueOverallDataResultsSortAlphaNum

                $script:AutoChart02DeepBlueOverallDataResults | ForEach-Object { $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount) }
                $script:AutoChart02DeepBlueTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02DeSepBlueOverallDataResults.count))
                $script:AutoChart02DeepBlueTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02DeepBlueOverallDataResults.count))
            }
            else {
                $script:AutoChart02DeepBlueTitle.ForeColor = 'Blue'
                $script:AutoChart02DeepBlueTitle.Text = "Findings Per Endpoint`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02DeepBlue

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02DeepBlueOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02DeepBlue.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02DeepBlue.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueOptionsButton
$script:AutoChart02DeepBlueOptionsButton.Add_Click({
    if ($script:AutoChart02DeepBlueOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02DeepBlueOptionsButton.Text = 'Options ^'
        $script:AutoChart02DeepBlue.Controls.Add($script:AutoChart02DeepBlueManipulationPanel)
    }
    elseif ($script:AutoChart02DeepBlueOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02DeepBlueOptionsButton.Text = 'Options v'
        $script:AutoChart02DeepBlue.Controls.Remove($script:AutoChart02DeepBlueManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02DeepBlueOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02DeepBlue)


$script:AutoChart02DeepBlueManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02DeepBlue.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02DeepBlue.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02DeepBlueTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02DeepBlueTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02DeepBlueTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02DeepBlueOverallDataResults.count))
    $script:AutoChart02DeepBlueTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02DeepBlueTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02DeepBlueTrimOffFirstTrackBarValue = $script:AutoChart02DeepBlueTrimOffFirstTrackBar.Value
        $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02DeepBlueTrimOffFirstTrackBar.Value)"
        $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.Clear()
        $script:AutoChart02DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart02DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Controls.Add($script:AutoChart02DeepBlueTrimOffFirstTrackBar)
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlueTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02DeepBlueTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Location.X + $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02DeepBlueTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02DeepBlueTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02DeepBlueTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02DeepBlueOverallDataResults.count))
    $script:AutoChart02DeepBlueTrimOffLastTrackBar.Value         = $($script:AutoChart02DeepBlueOverallDataResults.count)
    $script:AutoChart02DeepBlueTrimOffLastTrackBarValue   = 0
    $script:AutoChart02DeepBlueTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02DeepBlueTrimOffLastTrackBarValue = $($script:AutoChart02DeepBlueOverallDataResults.count) - $script:AutoChart02DeepBlueTrimOffLastTrackBar.Value
        $script:AutoChart02DeepBlueTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02DeepBlueOverallDataResults.count) - $script:AutoChart02DeepBlueTrimOffLastTrackBar.Value)"
        $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.Clear()
        $script:AutoChart02DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart02DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02DeepBlueTrimOffLastGroupBox.Controls.Add($script:AutoChart02DeepBlueTrimOffLastTrackBar)
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlueTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02DeepBlueChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Pie'
    Location  = @{ X = $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Location.Y + $script:AutoChart02DeepBlueTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02DeepBlueChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].ChartType = $script:AutoChart02DeepBlueChartTypeComboBox.SelectedItem
})
$script:AutoChart02DeepBlueChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02DeepBlueChartTypesAvailable) { $script:AutoChart02DeepBlueChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlueChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02DeepBlue3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02DeepBlueChartTypeComboBox.Location.X + $script:AutoChart02DeepBlueChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02DeepBlueChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlue3DToggleButton
$script:AutoChart02DeepBlue3DInclination = 0
$script:AutoChart02DeepBlue3DToggleButton.Add_Click({

    $script:AutoChart02DeepBlue3DInclination += 10
    if ( $script:AutoChart02DeepBlue3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02DeepBlueArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart02DeepBlue3DInclination
        $script:AutoChart02DeepBlue3DToggleButton.Text  = "3D On ($script:AutoChart02DeepBlue3DInclination)"
    }
    elseif ( $script:AutoChart02DeepBlue3DInclination -le 90 ) {
        $script:AutoChart02DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart02DeepBlue3DInclination
        $script:AutoChart02DeepBlue3DToggleButton.Text  = "3D On ($script:AutoChart02DeepBlue3DInclination)"
    }
    else {
        $script:AutoChart02DeepBlue3DToggleButton.Text  = "3D Off"
        $script:AutoChart02DeepBlue3DInclination = 0
        $script:AutoChart02DeepBlueArea.Area3DStyle.Inclination = $script:AutoChart02DeepBlue3DInclination
        $script:AutoChart02DeepBlueArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlue3DToggleButton)

### Change the color of the chart
$script:AutoChart02DeepBlueChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02DeepBlue3DToggleButton.Location.X + $script:AutoChart02DeepBlue3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02DeepBlue3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02DeepBlueColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02DeepBlueColorsAvailable) { $script:AutoChart02DeepBlueChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02DeepBlueChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Color = $script:AutoChart02DeepBlueChangeColorComboBox.SelectedItem
})
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlueChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02DeepBlue {
    # List of Positive Endpoints that positively match
    $script:AutoChart02DeepBlueImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object {$_.Message -eq $($script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Text)} | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02DeepBlueInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02DeepBlueImportCsvPosResults) { $script:AutoChart02DeepBlueInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02DeepBlueImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02DeepBlueImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02DeepBlueImportCsvAll) { if ($Endpoint -notin $script:AutoChart02DeepBlueImportCsvPosResults) { $script:AutoChart02DeepBlueImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02DeepBlueInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02DeepBlueImportCsvNegResults) { $script:AutoChart02DeepBlueInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02DeepBlueImportCsvPosResults.count))"
    $script:AutoChart02DeepBlueInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02DeepBlueImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02DeepBlueCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02DeepBlueTrimOffLastGroupBox.Location.X + $script:AutoChart02DeepBlueTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02DeepBlueTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueCheckDiffButton
$script:AutoChart02DeepBlueCheckDiffButton.Add_Click({
    $script:AutoChart02DeepBlueInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Message' -ExpandProperty 'Message' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02DeepBlueInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02DeepBlueInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02DeepBlueInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02DeepBlueInvestDiffDropDownLabel.Location.y + $script:AutoChart02DeepBlueInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02DeepBlueInvestDiffDropDownArray) { $script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02DeepBlue }})
    $script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02DeepBlue })

    ### Investigate Difference Execute Button
    $script:AutoChart02DeepBlueInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Location.y + $script:AutoChart02DeepBlueInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02DeepBlueInvestDiffExecuteButton
    $script:AutoChart02DeepBlueInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02DeepBlue }})
    $script:AutoChart02DeepBlueInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02DeepBlue })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02DeepBlueInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02DeepBlueInvestDiffExecuteButton.Location.y + $script:AutoChart02DeepBlueInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02DeepBlueInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Location.y + $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02DeepBlueInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Location.x + $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02DeepBlueInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02DeepBlueInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02DeepBlueInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02DeepBlueInvestDiffNegResultsLabel.Location.y + $script:AutoChart02DeepBlueInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02DeepBlueInvestDiffForm.Controls.AddRange(@($script:AutoChart02DeepBlueInvestDiffDropDownLabel,$script:AutoChart02DeepBlueInvestDiffDropDownComboBox,$script:AutoChart02DeepBlueInvestDiffExecuteButton,$script:AutoChart02DeepBlueInvestDiffPosResultsLabel,$script:AutoChart02DeepBlueInvestDiffPosResultsTextBox,$script:AutoChart02DeepBlueInvestDiffNegResultsLabel,$script:AutoChart02DeepBlueInvestDiffNegResultsTextBox))
    $script:AutoChart02DeepBlueInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02DeepBlueInvestDiffForm.ShowDialog()
})
$script:AutoChart02DeepBlueCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02DeepBlueManipulationPanel.controls.Add($script:AutoChart02DeepBlueCheckDiffButton)


$AutoChart02DeepBlueExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02DeepBlueCheckDiffButton.Location.X + $script:AutoChart02DeepBlueCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02DeepBlueCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Application Name" -QueryTabName "Findings Per Endpoint" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart02DeepBlueExpandChartButton
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($AutoChart02DeepBlueExpandChartButton)


$script:AutoChart02DeepBlueOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02DeepBlueCheckDiffButton.Location.X
                   Y = $script:AutoChart02DeepBlueCheckDiffButton.Location.Y + $script:AutoChart02DeepBlueCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueOpenInShell
$script:AutoChart02DeepBlueOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02DeepBlueManipulationPanel.controls.Add($script:AutoChart02DeepBlueOpenInShell)


$script:AutoChart02DeepBlueSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart02DeepBlueOpenInShell.Location.X
                  Y = $script:AutoChart02DeepBlueOpenInShell.Location.Y + $script:AutoChart02DeepBlueOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueSortButton
$script:AutoChart02DeepBlueSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart02DeepBlueOverallDataResults = $script:AutoChart02DeepBlueOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart02DeepBlueOverallDataResults = $script:AutoChart02DeepBlueOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.Clear()
    $script:AutoChart02DeepBlueOverallDataResults | Select-Object -skip $script:AutoChart02DeepBlueTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02DeepBlueTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02DeepBlue.Series["Findings Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02DeepBlueManipulationPanel.controls.Add($script:AutoChart02DeepBlueSortButton)


$script:AutoChart02DeepBlueViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02DeepBlueOpenInShell.Location.X + $script:AutoChart02DeepBlueOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02DeepBlueOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueViewResults
$script:AutoChart02DeepBlueViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView })
$script:AutoChart02DeepBlueManipulationPanel.controls.Add($script:AutoChart02DeepBlueViewResults)


### Save the chart to file
$script:AutoChart02DeepBlueSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02DeepBlueViewResults.Location.X
                  Y = $script:AutoChart02DeepBlueViewResults.Location.Y + $script:AutoChart02DeepBlueViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02DeepBlueSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02DeepBlueSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02DeepBlue -Title $script:AutoChart02DeepBlueTitle
})
$script:AutoChart02DeepBlueManipulationPanel.controls.Add($script:AutoChart02DeepBlueSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02DeepBlueNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02DeepBlueSortButton.Location.X
                        Y = $script:AutoChart02DeepBlueSortButton.Location.Y + $script:AutoChart02DeepBlueSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02DeepBlueCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02DeepBlueManipulationPanel.Controls.Add($script:AutoChart02DeepBlueNoticeTextbox)





