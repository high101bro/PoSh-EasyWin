$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Application Crashes - Last 1000 Logs Per Endpoint"
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

$script:AutoChart01ApplicationCrashesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Application Crashes' -or $CSVFile -match 'ApplicationCrashes') { $script:AutoChart01ApplicationCrashesCSVFileMatch += $CSVFile } }
} 
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ApplicationCrashesCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart01ApplicationCrashes.Controls.Remove($script:AutoChart01ApplicationCrashesManipulationPanel)
    $script:AutoChart02ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart02ApplicationCrashes.Controls.Remove($script:AutoChart02ApplicationCrashesManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Application Crashes"
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
                Enabled = $true
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsApplicationCrashes -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsApplicationCrashes -ComputerNameList $script:ComputerList }
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

    Generate-AutoChart01ApplicationCrashes
    Generate-AutoChart02ApplicationCrashes
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
# AutoChart01ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart01ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01ApplicationCrashes.Titles.Add($script:AutoChart01ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart01ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart01ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart01ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart01ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart01ApplicationCrashes.ChartAreas.Add($script:AutoChart01ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01ApplicationCrashes.Series.Add("Application Name")
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Enabled           = $True
$script:AutoChart01ApplicationCrashes.Series["Application Name"].BorderWidth       = 1
$script:AutoChart01ApplicationCrashes.Series["Application Name"].IsVisibleInLegend = $false
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Chartarea         = 'Chart Area'
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Legend            = 'Legend'
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01ApplicationCrashes.Series["Application Name"]['PieLineColor']   = 'Black'
$script:AutoChart01ApplicationCrashes.Series["Application Name"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01ApplicationCrashes.Series["Application Name"].ChartType         = 'Bar'
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Color             = 'Red'


            function Generate-AutoChart01ApplicationCrashes {
                $script:AutoChart01ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
                $script:AutoChart01ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv `
                | Select-Object -Property @{n='Name';e={$_.Message.split(':')[1].split(',')[0].trim() } } | Sort-Object Name -Unique

                $script:AutoChartsProgressBar.ForeColor = 'Red'
                $script:AutoChartsProgressBar.Minimum = 0
                $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ApplicationCrashesUniqueDataFields.count
                $script:AutoChartsProgressBar.Value   = 0
                $script:AutoChartsProgressBar.Update()
            
                $script:AutoChart01ApplicationCrashes.Series["Application Crashes"].Points.Clear()
            
                if ($script:AutoChart01ApplicationCrashesUniqueDataFields.count -gt 0){
                    $script:AutoChart01ApplicationCrashesTitle.ForeColor = 'Black'
                    $script:AutoChart01ApplicationCrashesTitle.Text = "Unique Application Crashes"
            
                    # If the Second field/Y Axis equals PSComputername, it counts it
                    $script:AutoChart01ApplicationCrashesOverallDataResults = @()
            
                    # Generates and Counts the data - Counts the number of times that any given property possess a given value
                    foreach ($DataField in $script:AutoChart01ApplicationCrashesUniqueDataFields) {
                        $Count        = 0
                        $script:AutoChart01ApplicationCrashesCsvComputers = @()
                        foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                            if ( $( $Line.Message.split(':')[1].split(',')[0].trim() ) -eq $DataField.Name) {
                                $Count += 1
                                if ( $script:AutoChart01ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01ApplicationCrashesCsvComputers += $($Line.PSComputerName) }
                            }
                        }
                        $script:AutoChart01ApplicationCrashesUniqueCount = $script:AutoChart01ApplicationCrashesCsvComputers.Count
                        $script:AutoChart01ApplicationCrashesDataResults = New-Object PSObject -Property @{
                            DataField   = $DataField
                            TotalCount  = $Count
                            UniqueCount = $script:AutoChart01ApplicationCrashesUniqueCount
                            Computers   = $script:AutoChart01ApplicationCrashesCsvComputers 
                        }
                        $script:AutoChart01ApplicationCrashesOverallDataResults += $script:AutoChart01ApplicationCrashesDataResults
                        $script:AutoChartsProgressBar.Value += 1
                        $script:AutoChartsProgressBar.Update()
                    }
                    $script:AutoChart01ApplicationCrashesSortButton.text = "View: Count"
                    $script:AutoChart01ApplicationCrashesOverallDataResultsSortAlphaNum = $script:AutoChart01ApplicationCrashesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                    $script:AutoChart01ApplicationCrashesOverallDataResultsSortCount    = $script:AutoChart01ApplicationCrashesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                    $script:AutoChart01ApplicationCrashesOverallDataResults = $script:AutoChart01ApplicationCrashesOverallDataResultsSortAlphaNum
    
                    $script:AutoChart01ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount) }
                    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))
                    $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))
                }
                else {
                    $script:AutoChart01ApplicationCrashesTitle.ForeColor = 'Red'
                    $script:AutoChart01ApplicationCrashesTitle.Text = "Unique Application Crashes`n
            [ No Data Available ]`n"                
                }
            }
            Generate-AutoChart01ApplicationCrashes


### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart01ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesOptionsButton
$script:AutoChart01ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart01ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart01ApplicationCrashes.Controls.Add($script:AutoChart01ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart01ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart01ApplicationCrashes.Controls.Remove($script:AutoChart01ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ApplicationCrashes)


$script:AutoChart01ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()
        $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
    $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart01ApplicationCrashesOverallDataResults.count)
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart01ApplicationCrashesOverallDataResults.count) - $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ApplicationCrashesOverallDataResults.count) - $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()
        $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ApplicationCrashes.Series["Application Name"].ChartType = $script:AutoChart01ApplicationCrashesChartTypeComboBox.SelectedItem
})
$script:AutoChart01ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ApplicationCrashesChartTypesAvailable) { $script:AutoChart01ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart01ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashes3DToggleButton
$script:AutoChart01ApplicationCrashes3DInclination = 0
$script:AutoChart01ApplicationCrashes3DToggleButton.Add_Click({
    
    $script:AutoChart01ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart01ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart01ApplicationCrashes3DInclination
        $script:AutoChart01ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart01ApplicationCrashes3DInclination)"
    }
    elseif ( $script:AutoChart01ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart01ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart01ApplicationCrashes3DInclination
        $script:AutoChart01ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart01ApplicationCrashes3DInclination)" 
    }
    else { 
        $script:AutoChart01ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart01ApplicationCrashes3DInclination = 0
        $script:AutoChart01ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart01ApplicationCrashes3DInclination
        $script:AutoChart01ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart01ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart01ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ApplicationCrashesColorsAvailable) { $script:AutoChart01ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ApplicationCrashes.Series["Application Name"].Color = $script:AutoChart01ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object {$($_.Message.split(':')[1].split(',')[0].trim()) -eq $($script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Text)} | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ApplicationCrashesImportCsvPosResults) { $script:AutoChart01ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart01ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ApplicationCrashesImportCsvPosResults) { $script:AutoChart01ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ApplicationCrashesImportCsvNegResults) { $script:AutoChart01ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesCheckDiffButton
$script:AutoChart01ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property @{n='Name';e={$_.Message.split(':')[1].split(',')[0].trim() } } | Select-Object -ExpandProperty Name | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart01ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ApplicationCrashes }})
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ApplicationCrashes }})
    $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart01ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart01ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart01ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart01ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart01ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart01ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart01ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart01ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart01ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart01ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart01ApplicationCrashesCheckDiffButton)


$AutoChart01ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart01ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Application Crashes" -QueryTabName "Application Name" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01ApplicationCrashesExpandChartButton
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($AutoChart01ApplicationCrashesExpandChartButton)


$script:AutoChart01ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart01ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart01ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesOpenInShell
$script:AutoChart01ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart01ApplicationCrashesOpenInShell)


$script:AutoChart01ApplicationCrashesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart01ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart01ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart01ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesSortButton
$script:AutoChart01ApplicationCrashesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart01ApplicationCrashesOverallDataResults = $script:AutoChart01ApplicationCrashesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart01ApplicationCrashesOverallDataResults = $script:AutoChart01ApplicationCrashesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()
    $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart01ApplicationCrashesSortButton)


$script:AutoChart01ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ApplicationCrashesOpenInShell.Location.X + $script:AutoChart01ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesViewResults
$script:AutoChart01ApplicationCrashesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart01ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart01ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart01ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ApplicationCrashesViewResults.Location.X
                  Y = $script:AutoChart01ApplicationCrashesViewResults.Location.Y + $script:AutoChart01ApplicationCrashesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01ApplicationCrashes -Title $script:AutoChart01ApplicationCrashesTitle
})
$script:AutoChart01ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart01ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ApplicationCrashesSortButton.Location.X 
                        Y = $script:AutoChart01ApplicationCrashesSortButton.Location.Y + $script:AutoChart01ApplicationCrashesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesNoticeTextbox)

$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()
$script:AutoChart01ApplicationCrashesOverallDataResults | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}






















##############################################################################################
# AutoChart02ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ApplicationCrashes.Location.X + $script:AutoChart01ApplicationCrashes.Size.Width + 20
                  Y = $script:AutoChart01ApplicationCrashes.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02ApplicationCrashes.Add_MouseHover({ Close-AllOptions })


### Auto Create Charts Title 
$script:AutoChart02ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02ApplicationCrashes.Titles.Add($script:AutoChart02ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart02ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart02ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart02ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart02ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart02ApplicationCrashes.ChartAreas.Add($script:AutoChart02ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02ApplicationCrashes.Series.Add("Application Crashes Per Endpoint")
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Enabled           = $True
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].BorderWidth       = 1
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].IsVisibleInLegend = $false
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Chartarea         = 'Chart Area'
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Legend            = 'Legend'
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"]['PieLineColor']   = 'Black'
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].ChartType         = 'Pie'
$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Color             = 'Blue'

    function Generate-AutoChart02ApplicationCrashes {
            $script:AutoChart02ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart02ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Select-Object -Property @{n='Name';e={$_.Message.split(':')[1].split(',')[0].trim() } } | Sort-Object Name -Unique
        
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart02ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart02ApplicationCrashesTitle.Text = "Application Crashes Per Endpoint"

                $AutoChart02CurrentComputer  = ''
                $AutoChart02CheckIfFirstLine = $false
                $AutoChart02ResultsCount     = 0
                $AutoChart02Computer         = @()
                $AutoChart02YResults         = @()
                $script:AutoChart02ApplicationCrashesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object PSComputerName) ) {
                    $LineName = $Line.Message.split(':')[1].split(',')[0].trim()
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
                            $script:AutoChart02ApplicationCrashesOverallDataResults += $AutoChart02YDataResults
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
                $script:AutoChart02ApplicationCrashesOverallDataResults += $AutoChart02YDataResults

                $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.Clear()

                $script:AutoChart02ApplicationCrashesSortButton.text = "View: Count"
                $script:AutoChart02ApplicationCrashesOverallDataResultsSortAlphaNum = $script:AutoChart02ApplicationCrashesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart02ApplicationCrashesOverallDataResultsSortCount    = $script:AutoChart02ApplicationCrashesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart02ApplicationCrashesOverallDataResults = $script:AutoChart02ApplicationCrashesOverallDataResultsSortAlphaNum

                $script:AutoChart02ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount) }
                $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))
                $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart02ApplicationCrashesTitle.ForeColor = 'Blue'
                $script:AutoChart02ApplicationCrashesTitle.Text = "Application Crashes Per Endpoint`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart02ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart02ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesOptionsButton
$script:AutoChart02ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart02ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart02ApplicationCrashes.Controls.Add($script:AutoChart02ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart02ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart02ApplicationCrashes.Controls.Remove($script:AutoChart02ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ApplicationCrashes)


$script:AutoChart02ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.Clear()
        $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart02ApplicationCrashesOverallDataResults.count)
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart02ApplicationCrashesOverallDataResults.count) - $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ApplicationCrashesOverallDataResults.count) - $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.Clear()
        $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Pie' 
    Location  = @{ X = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].ChartType = $script:AutoChart02ApplicationCrashesChartTypeComboBox.SelectedItem
})
$script:AutoChart02ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ApplicationCrashesChartTypesAvailable) { $script:AutoChart02ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart02ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashes3DToggleButton
$script:AutoChart02ApplicationCrashes3DInclination = 0
$script:AutoChart02ApplicationCrashes3DToggleButton.Add_Click({
    
    $script:AutoChart02ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart02ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart02ApplicationCrashes3DInclination
        $script:AutoChart02ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart02ApplicationCrashes3DInclination)"
    }
    elseif ( $script:AutoChart02ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart02ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart02ApplicationCrashes3DInclination
        $script:AutoChart02ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart02ApplicationCrashes3DInclination)" 
    }
    else { 
        $script:AutoChart02ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart02ApplicationCrashes3DInclination = 0
        $script:AutoChart02ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart02ApplicationCrashes3DInclination
        $script:AutoChart02ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart02ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart02ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ApplicationCrashesColorsAvailable) { $script:AutoChart02ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Color = $script:AutoChart02ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object {$($_.Message.split(':')[1].split(',')[0].trim()) -eq $($script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Text)} | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ApplicationCrashesImportCsvPosResults) { $script:AutoChart02ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart02ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ApplicationCrashesImportCsvPosResults) { $script:AutoChart02ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ApplicationCrashesImportCsvNegResults) { $script:AutoChart02ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesCheckDiffButton
$script:AutoChart02ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property @{n='Name';e={$_.Message.split(':')[1].split(',')[0].trim() } } | Select-Object -ExpandProperty Name | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart02ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ApplicationCrashes }})
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ApplicationCrashes }})
    $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart02ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart02ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart02ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart02ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart02ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart02ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart02ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart02ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart02ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart02ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart02ApplicationCrashesCheckDiffButton)


$AutoChart02ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart02ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Application Crashes" -QueryTabName "Application Crashes Per Endpoint" -PropertyX "Name" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart02ApplicationCrashesExpandChartButton
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($AutoChart02ApplicationCrashesExpandChartButton)


$script:AutoChart02ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart02ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart02ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesOpenInShell
$script:AutoChart02ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart02ApplicationCrashesOpenInShell)


$script:AutoChart02ApplicationCrashesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart02ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart02ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart02ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesSortButton
$script:AutoChart02ApplicationCrashesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart02ApplicationCrashesOverallDataResults = $script:AutoChart02ApplicationCrashesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart02ApplicationCrashesOverallDataResults = $script:AutoChart02ApplicationCrashesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.Clear()
    $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Application Crashes Per Endpoint"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart02ApplicationCrashesSortButton)


$script:AutoChart02ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ApplicationCrashesOpenInShell.Location.X + $script:AutoChart02ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesViewResults
$script:AutoChart02ApplicationCrashesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart02ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart02ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart02ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ApplicationCrashesViewResults.Location.X
                  Y = $script:AutoChart02ApplicationCrashesViewResults.Location.Y + $script:AutoChart02ApplicationCrashesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02ApplicationCrashes -Title $script:AutoChart02ApplicationCrashesTitle
})
$script:AutoChart02ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart02ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ApplicationCrashesSortButton.Location.X 
                        Y = $script:AutoChart02ApplicationCrashesSortButton.Location.Y + $script:AutoChart02ApplicationCrashesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesNoticeTextbox)



