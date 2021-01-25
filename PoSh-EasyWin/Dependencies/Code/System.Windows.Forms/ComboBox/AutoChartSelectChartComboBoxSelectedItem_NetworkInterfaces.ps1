$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Network Infterfaces'
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

$script:AutoChart01NetworkInterfacesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Network Settings') { $script:AutoChart01NetworkInterfacesCSVFileMatch += $CSVFile } }
}
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01NetworkInterfacesCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart01NetworkInterfaces.Controls.Remove($script:AutoChart01NetworkInterfacesManipulationPanel)
    $script:AutoChart02NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart02NetworkInterfaces.Controls.Remove($script:AutoChart02NetworkInterfacesManipulationPanel)
    $script:AutoChart03NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart03NetworkInterfaces.Controls.Remove($script:AutoChart03NetworkInterfacesManipulationPanel)
    $script:AutoChart04NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart04NetworkInterfaces.Controls.Remove($script:AutoChart04NetworkInterfacesManipulationPanel)
    $script:AutoChart05NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart05NetworkInterfaces.Controls.Remove($script:AutoChart05NetworkInterfacesManipulationPanel)
    $script:AutoChart06NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart06NetworkInterfaces.Controls.Remove($script:AutoChart06NetworkInterfacesManipulationPanel)
    $script:AutoChart07NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart07NetworkInterfaces.Controls.Remove($script:AutoChart07NetworkInterfacesManipulationPanel)
    $script:AutoChart08NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart08NetworkInterfaces.Controls.Remove($script:AutoChart08NetworkInterfacesManipulationPanel)
    $script:AutoChart09NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart09NetworkInterfaces.Controls.Remove($script:AutoChart09NetworkInterfacesManipulationPanel)
    $script:AutoChart10NetworkInterfacesOptionsButton.Text = 'Options v'
    $script:AutoChart10NetworkInterfaces.Controls.Remove($script:AutoChart10NetworkInterfacesManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Network Interfaces Info'
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
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-EasyWin')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsNetworkInterfaces -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsNetworkInterfaces -ComputerNameList $script:ComputerList }
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

    Generate-AutoChart01NetworkInterfaces
    Generate-AutoChart02NetworkInterfaces
    Generate-AutoChart03NetworkInterfaces
    Generate-AutoChart04NetworkInterfaces
    Generate-AutoChart05NetworkInterfaces
    Generate-AutoChart06NetworkInterfaces
    Generate-AutoChart07NetworkInterfaces
    Generate-AutoChart08NetworkInterfaces
    Generate-AutoChart09NetworkInterfaces
    Generate-AutoChart10NetworkInterfaces
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
# AutoChart01NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart01NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01NetworkInterfaces.Titles.Add($script:AutoChart01NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart01NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart01NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart01NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart01NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart01NetworkInterfaces.ChartAreas.Add($script:AutoChart01NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01NetworkInterfaces.Series.Add("Interface Alias")
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Enabled           = $True
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].BorderWidth       = 1
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].IsVisibleInLegend = $false
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Chartarea         = 'Chart Area'
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Legend            = 'Legend'
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"]['PieLineColor']   = 'Black'
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].ChartType         = 'Column'
$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Color             = 'Red'

        function Generate-AutoChart01NetworkInterfaces {
            $script:AutoChart01NetworkInterfacesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01NetworkInterfacesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'InterfaceAlias' | Sort-Object -Property 'InterfaceAlias' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()

            if ($script:AutoChart01NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart01NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart01NetworkInterfacesTitle.Text = "Interface Alias"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01NetworkInterfacesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01NetworkInterfacesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01NetworkInterfacesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.InterfaceAlias) -eq $DataField.InterfaceAlias) {
                            $Count += 1
                            if ( $script:AutoChart01NetworkInterfacesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01NetworkInterfacesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01NetworkInterfacesUniqueCount = $script:AutoChart01NetworkInterfacesCsvComputers.Count
                    $script:AutoChart01NetworkInterfacesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01NetworkInterfacesUniqueCount
                        Computers   = $script:AutoChart01NetworkInterfacesCsvComputers
                    }
                    $script:AutoChart01NetworkInterfacesOverallDataResults += $script:AutoChart01NetworkInterfacesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount) }
                $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01NetworkInterfacesOverallDataResults.count))
                $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart01NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart01NetworkInterfacesTitle.Text = "Interface Alias`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart01NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart01NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesOptionsButton
$script:AutoChart01NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart01NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart01NetworkInterfaces.Controls.Add($script:AutoChart01NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart01NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart01NetworkInterfaces.Controls.Remove($script:AutoChart01NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01NetworkInterfaces)


$script:AutoChart01NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01NetworkInterfacesOverallDataResults.count))
    $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
        $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    })
    $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart01NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01NetworkInterfacesOverallDataResults.count))
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart01NetworkInterfacesOverallDataResults.count)
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart01NetworkInterfacesOverallDataResults.count) - $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart01NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01NetworkInterfacesOverallDataResults.count) - $script:AutoChart01NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
        $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    })
$script:AutoChart01NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart01NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart01NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].ChartType = $script:AutoChart01NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
#    $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
})
$script:AutoChart01NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01NetworkInterfacesChartTypesAvailable) { $script:AutoChart01NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfacesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart01NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfaces3DToggleButton
$script:AutoChart01NetworkInterfaces3DInclination = 0
$script:AutoChart01NetworkInterfaces3DToggleButton.Add_Click({

    $script:AutoChart01NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart01NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart01NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart01NetworkInterfaces3DInclination
        $script:AutoChart01NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart01NetworkInterfaces3DInclination)"
#        $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart01NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart01NetworkInterfaces3DInclination
        $script:AutoChart01NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart01NetworkInterfaces3DInclination)"
#        $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
    else {
        $script:AutoChart01NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart01NetworkInterfaces3DInclination = 0
        $script:AutoChart01NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart01NetworkInterfaces3DInclination
        $script:AutoChart01NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
#        $script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}
    }
})
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart01NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart01NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01NetworkInterfacesColorsAvailable) { $script:AutoChart01NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Color = $script:AutoChart01NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfacesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart01NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'InterfaceAlias' -eq $($script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01NetworkInterfacesImportCsvPosResults) { $script:AutoChart01NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart01NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart01NetworkInterfacesImportCsvPosResults) { $script:AutoChart01NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01NetworkInterfacesImportCsvNegResults) { $script:AutoChart01NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart01NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesCheckDiffButton
$script:AutoChart01NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart01NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'InterfaceAlias' -ExpandProperty 'InterfaceAlias' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart01NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01NetworkInterfaces }})
    $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01NetworkInterfaces }})
    $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart01NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart01NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart01NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart01NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart01NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart01NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart01NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart01NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart01NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart01NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart01NetworkInterfacesCheckDiffButton)


$AutoChart01NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart01NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Interface Alias" -PropertyX "InterfaceAlias" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01NetworkInterfacesExpandChartButton
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($AutoChart01NetworkInterfacesExpandChartButton)


$script:AutoChart01NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart01NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart01NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesOpenInShell
$script:AutoChart01NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart01NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart01NetworkInterfacesOpenInShell)


$script:AutoChart01NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01NetworkInterfacesOpenInShell.Location.X + $script:AutoChart01NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesViewResults
$script:AutoChart01NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart01NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart01NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart01NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart01NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart01NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01NetworkInterfaces -Title $script:AutoChart01NetworkInterfacesTitle
})
$script:AutoChart01NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart01NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart01NetworkInterfacesSaveButton.Location.Y + $script:AutoChart01NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart01NetworkInterfacesNoticeTextbox)

$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.Clear()
$script:AutoChart01NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01NetworkInterfaces.Series["Interface Alias"].Points.AddXY($_.DataField.InterfaceAlias,$_.UniqueCount)}























##############################################################################################
# AutoChart02NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01NetworkInterfaces.Location.X + $script:AutoChart01NetworkInterfaces.Size.Width + 20
                  Y = $script:AutoChart01NetworkInterfaces.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart02NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02NetworkInterfaces.Titles.Add($script:AutoChart02NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart02NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart02NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart02NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart02NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart02NetworkInterfaces.ChartAreas.Add($script:AutoChart02NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02NetworkInterfaces.Series.Add("Interfaces with IPs Per Host")
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Enabled           = $True
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].BorderWidth       = 1
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].IsVisibleInLegend = $false
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Legend            = 'Legend'
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].ChartType         = 'DoughNut'
$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Color             = 'Blue'

        function Generate-AutoChart02NetworkInterfaces {
            $script:AutoChart02NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart02NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart02NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart02NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart02NetworkInterfacesTitle.Text = "Interfaces with IPs Per Host"

                $AutoChart02NetworkInterfacesCurrentComputer  = ''
                $AutoChart02NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart02NetworkInterfacesResultsCount     = 0
                $AutoChart02NetworkInterfacesComputer         = @()
                $AutoChart02NetworkInterfacesYResults         = @()
                $script:AutoChart02NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Sort-Object PSComputerName) ) {
                    if ( $AutoChart02NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart02NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart02NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart02NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart02NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart02NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart02NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart02NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart02NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart02NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart02NetworkInterfacesCurrentComputer ) {
                            $AutoChart02NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart02NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart02NetworkInterfacesResultsCount
                                Computer     = $AutoChart02NetworkInterfacesComputer
                            }
                            $script:AutoChart02NetworkInterfacesOverallDataResults += $AutoChart02NetworkInterfacesYDataResults
                            $AutoChart02NetworkInterfacesYResults     = @()
                            $AutoChart02NetworkInterfacesResultsCount = 0
                            $AutoChart02NetworkInterfacesComputer     = @()
                            if ( $AutoChart02NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart02NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart02NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart02NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart02NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart02NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart02NetworkInterfacesResultsCount ; Computer = $AutoChart02NetworkInterfacesComputer }
                $script:AutoChart02NetworkInterfacesOverallDataResults += $AutoChart02NetworkInterfacesYDataResults
                $script:AutoChart02NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
                $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02NetworkInterfacesOverallDataResults.count))
                $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
                $script:AutoChart02NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart02NetworkInterfacesTitle.Text = "Interfaces with IPs Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart02NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart02NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesOptionsButton
$script:AutoChart02NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart02NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart02NetworkInterfaces.Controls.Add($script:AutoChart02NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart02NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart02NetworkInterfaces.Controls.Remove($script:AutoChart02NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02NetworkInterfaces)

$script:AutoChart02NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02NetworkInterfacesOverallDataResults.count))
    $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
        $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart02NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02NetworkInterfacesOverallDataResults.count))
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart02NetworkInterfacesOverallDataResults.count)
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart02NetworkInterfacesOverallDataResults.count) - $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart02NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02NetworkInterfacesOverallDataResults.count) - $script:AutoChart02NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
        $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart02NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart02NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].ChartType = $script:AutoChart02NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
#    $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart02NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02NetworkInterfacesChartTypesAvailable) { $script:AutoChart02NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart02NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfaces3DToggleButton
$script:AutoChart02NetworkInterfaces3DInclination = 0
$script:AutoChart02NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart02NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart02NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart02NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart02NetworkInterfaces3DInclination
        $script:AutoChart02NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart02NetworkInterfaces3DInclination)"
#        $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart02NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart02NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart02NetworkInterfaces3DInclination
        $script:AutoChart02NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart02NetworkInterfaces3DInclination)"
#        $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart02NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart02NetworkInterfaces3DInclination = 0
        $script:AutoChart02NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart02NetworkInterfaces3DInclination
        $script:AutoChart02NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
#        $script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart02NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart02NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02NetworkInterfacesColorsAvailable) { $script:AutoChart02NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Color = $script:AutoChart02NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart02NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02NetworkInterfacesImportCsvPosResults) { $script:AutoChart02NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart02NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart02NetworkInterfacesImportCsvPosResults) { $script:AutoChart02NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02NetworkInterfacesImportCsvNegResults) { $script:AutoChart02NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart02NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesCheckDiffButton
$script:AutoChart02NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart02NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart02NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02NetworkInterfaces }})
    $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02NetworkInterfaces }})
    $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart02NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart02NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart02NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart02NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart02NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart02NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart02NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart02NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart02NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart02NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart02NetworkInterfacesCheckDiffButton)


$AutoChart02NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart02NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Interfaces with IPs Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart02NetworkInterfacesExpandChartButton
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($AutoChart02NetworkInterfacesExpandChartButton)


$script:AutoChart02NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart02NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart02NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesOpenInShell
$script:AutoChart02NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart02NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart02NetworkInterfacesOpenInShell)


$script:AutoChart02NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02NetworkInterfacesOpenInShell.Location.X + $script:AutoChart02NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesViewResults
$script:AutoChart02NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart02NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart02NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart02NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart02NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart02NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02NetworkInterfaces -Title $script:AutoChart02NetworkInterfacesTitle
})
$script:AutoChart02NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart02NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart02NetworkInterfacesSaveButton.Location.Y + $script:AutoChart02NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart02NetworkInterfacesNoticeTextbox)

$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.Clear()
$script:AutoChart02NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart02NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02NetworkInterfaces.Series["Interfaces with IPs Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

























##############################################################################################
# AutoChart03NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01NetworkInterfaces.Location.X
                  Y = $script:AutoChart01NetworkInterfaces.Location.Y + $script:AutoChart01NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart03NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart03NetworkInterfaces.Titles.Add($script:AutoChart03NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart03NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart03NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart03NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart03NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart03NetworkInterfaces.ChartAreas.Add($script:AutoChart03NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03NetworkInterfaces.Series.Add("IPv4 Interfaces Per Host")
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Enabled           = $True
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].BorderWidth       = 1
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].IsVisibleInLegend = $false
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Legend            = 'Legend'
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].ChartType         = 'Column'
$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Color             = 'Green'

        function Generate-AutoChart03NetworkInterfaces {
            $script:AutoChart03NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart03NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart03NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart03NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart03NetworkInterfacesTitle.Text = "IPv4 Interfaces Per Host"

                $AutoChart03NetworkInterfacesCurrentComputer  = ''
                $AutoChart03NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart03NetworkInterfacesResultsCount     = 0
                $AutoChart03NetworkInterfacesComputer         = @()
                $AutoChart03NetworkInterfacesYResults         = @()
                $script:AutoChart03NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.AddressFamily -eq 'IPv4'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart03NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart03NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart03NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart03NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart03NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart03NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart03NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart03NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart03NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart03NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart03NetworkInterfacesCurrentComputer ) {
                            $AutoChart03NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart03NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart03NetworkInterfacesResultsCount
                                Computer     = $AutoChart03NetworkInterfacesComputer
                            }
                            $script:AutoChart03NetworkInterfacesOverallDataResults += $AutoChart03NetworkInterfacesYDataResults
                            $AutoChart03NetworkInterfacesYResults     = @()
                            $AutoChart03NetworkInterfacesResultsCount = 0
                            $AutoChart03NetworkInterfacesComputer     = @()
                            if ( $AutoChart03NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart03NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart03NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart03NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart03NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart03NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart03NetworkInterfacesResultsCount ; Computer = $AutoChart03NetworkInterfacesComputer }
                $script:AutoChart03NetworkInterfacesOverallDataResults += $AutoChart03NetworkInterfacesYDataResults
                $script:AutoChart03NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
                $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03NetworkInterfacesOverallDataResults.count))
                $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
                $script:AutoChart03NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart03NetworkInterfacesTitle.Text = "IPv4 Interfaces Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart03NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart03NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesOptionsButton
$script:AutoChart03NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart03NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart03NetworkInterfaces.Controls.Add($script:AutoChart03NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart03NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart03NetworkInterfaces.Controls.Remove($script:AutoChart03NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03NetworkInterfaces)

$script:AutoChart03NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03NetworkInterfacesOverallDataResults.count))
    $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
        $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart03NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03NetworkInterfacesOverallDataResults.count))
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart03NetworkInterfacesOverallDataResults.count)
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart03NetworkInterfacesOverallDataResults.count) - $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart03NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03NetworkInterfacesOverallDataResults.count) - $script:AutoChart03NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
        $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart03NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart03NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart03NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].ChartType = $script:AutoChart03NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
#    $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart03NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03NetworkInterfacesChartTypesAvailable) { $script:AutoChart03NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart03NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfaces3DToggleButton
$script:AutoChart03NetworkInterfaces3DInclination = 0
$script:AutoChart03NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart03NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart03NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart03NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart03NetworkInterfaces3DInclination
        $script:AutoChart03NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart03NetworkInterfaces3DInclination)"
#        $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart03NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart03NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart03NetworkInterfaces3DInclination
        $script:AutoChart03NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart03NetworkInterfaces3DInclination)"
#        $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart03NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart03NetworkInterfaces3DInclination = 0
        $script:AutoChart03NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart03NetworkInterfaces3DInclination
        $script:AutoChart03NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart03NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart03NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03NetworkInterfacesColorsAvailable) { $script:AutoChart03NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Color = $script:AutoChart03NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart03NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03NetworkInterfacesImportCsvPosResults) { $script:AutoChart03NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart03NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart03NetworkInterfacesImportCsvPosResults) { $script:AutoChart03NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03NetworkInterfacesImportCsvNegResults) { $script:AutoChart03NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart03NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesCheckDiffButton
$script:AutoChart03NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart03NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart03NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03NetworkInterfaces }})
    $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03NetworkInterfaces }})
    $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart03NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart03NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart03NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart03NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart03NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart03NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart03NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart03NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart03NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart03NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart03NetworkInterfacesCheckDiffButton)


$AutoChart03NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart03NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPv4 Interfaces Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart03NetworkInterfacesExpandChartButton
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($AutoChart03NetworkInterfacesExpandChartButton)


$script:AutoChart03NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart03NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart03NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesOpenInShell
$script:AutoChart03NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart03NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart03NetworkInterfacesOpenInShell)


$script:AutoChart03NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03NetworkInterfacesOpenInShell.Location.X + $script:AutoChart03NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesViewResults
$script:AutoChart03NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart03NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart03NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart03NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart03NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart03NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03NetworkInterfaces -Title $script:AutoChart03NetworkInterfacesTitle
})
$script:AutoChart03NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart03NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart03NetworkInterfacesSaveButton.Location.Y + $script:AutoChart03NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart03NetworkInterfacesNoticeTextbox)

$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.Clear()
$script:AutoChart03NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart03NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkInterfaces.Series["IPv4 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}




























##############################################################################################
# AutoChart04NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02NetworkInterfaces.Location.X
                  Y = $script:AutoChart02NetworkInterfaces.Location.Y + $script:AutoChart02NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart04NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart04NetworkInterfaces.Titles.Add($script:AutoChart04NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart04NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart04NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart04NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart04NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart04NetworkInterfaces.ChartAreas.Add($script:AutoChart04NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04NetworkInterfaces.Series.Add("IPv6 Interfaces Per Host")
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Enabled           = $True
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].BorderWidth       = 1
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].IsVisibleInLegend = $false
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Legend            = 'Legend'
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].ChartType         = 'Column'
$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Color             = 'orange'

        function Generate-AutoChart04NetworkInterfaces {
            $script:AutoChart04NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart04NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart04NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart04NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart04NetworkInterfacesTitle.Text = "IPv6 Interfaces Per Host"

                $AutoChart04NetworkInterfacesCurrentComputer  = ''
                $AutoChart04NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart04NetworkInterfacesResultsCount     = 0
                $AutoChart04NetworkInterfacesComputer         = @()
                $AutoChart04NetworkInterfacesYResults         = @()
                $script:AutoChart04NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.AddressFamily -eq 'IPv6'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart04NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart04NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart04NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart04NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart04NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart04NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart04NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart04NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart04NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart04NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart04NetworkInterfacesCurrentComputer ) {
                            $AutoChart04NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart04NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart04NetworkInterfacesResultsCount
                                Computer     = $AutoChart04NetworkInterfacesComputer
                            }
                            $script:AutoChart04NetworkInterfacesOverallDataResults += $AutoChart04NetworkInterfacesYDataResults
                            $AutoChart04NetworkInterfacesYResults     = @()
                            $AutoChart04NetworkInterfacesResultsCount = 0
                            $AutoChart04NetworkInterfacesComputer     = @()
                            if ( $AutoChart04NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart04NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart04NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart04NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart04NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart04NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart04NetworkInterfacesResultsCount ; Computer = $AutoChart04NetworkInterfacesComputer }
                $script:AutoChart04NetworkInterfacesOverallDataResults += $AutoChart04NetworkInterfacesYDataResults
                $script:AutoChart04NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
                $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04NetworkInterfacesOverallDataResults.count))
                $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
                $script:AutoChart04NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart04NetworkInterfacesTitle.Text = "IPv6 Interfaces Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart04NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart04NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesOptionsButton
$script:AutoChart04NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart04NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart04NetworkInterfaces.Controls.Add($script:AutoChart04NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart04NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart04NetworkInterfaces.Controls.Remove($script:AutoChart04NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04NetworkInterfaces)

$script:AutoChart04NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04NetworkInterfacesOverallDataResults.count))
    $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
        $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart04NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04NetworkInterfacesOverallDataResults.count))
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart04NetworkInterfacesOverallDataResults.count)
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart04NetworkInterfacesOverallDataResults.count) - $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart04NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04NetworkInterfacesOverallDataResults.count) - $script:AutoChart04NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
        $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart04NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart04NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart04NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].ChartType = $script:AutoChart04NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
#    $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart04NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04NetworkInterfacesChartTypesAvailable) { $script:AutoChart04NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart04NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfaces3DToggleButton
$script:AutoChart04NetworkInterfaces3DInclination = 0
$script:AutoChart04NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart04NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart04NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart04NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart04NetworkInterfaces3DInclination
        $script:AutoChart04NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart04NetworkInterfaces3DInclination)"
#        $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart04NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart04NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart04NetworkInterfaces3DInclination
        $script:AutoChart04NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart04NetworkInterfaces3DInclination)"
#        $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart04NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart04NetworkInterfaces3DInclination = 0
        $script:AutoChart04NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart04NetworkInterfaces3DInclination
        $script:AutoChart04NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
#        $script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart04NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart04NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04NetworkInterfacesColorsAvailable) { $script:AutoChart04NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Color = $script:AutoChart04NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart04NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04NetworkInterfacesImportCsvPosResults) { $script:AutoChart04NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart04NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart04NetworkInterfacesImportCsvPosResults) { $script:AutoChart04NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04NetworkInterfacesImportCsvNegResults) { $script:AutoChart04NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart04NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesCheckDiffButton
$script:AutoChart04NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart04NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart04NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04NetworkInterfaces }})
    $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04NetworkInterfaces }})
    $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart04NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart04NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart04NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart04NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart04NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart04NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart04NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart04NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart04NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart04NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart04NetworkInterfacesCheckDiffButton)


$AutoChart04NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart04NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPv6 Interfaces Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart04NetworkInterfacesExpandChartButton
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($AutoChart04NetworkInterfacesExpandChartButton)


$script:AutoChart04NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart04NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart04NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesOpenInShell
$script:AutoChart04NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart04NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart04NetworkInterfacesOpenInShell)


$script:AutoChart04NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04NetworkInterfacesOpenInShell.Location.X + $script:AutoChart04NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesViewResults
$script:AutoChart04NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart04NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart04NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart04NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart04NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart04NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04NetworkInterfaces -Title $script:AutoChart04NetworkInterfacesTitle
})
$script:AutoChart04NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart04NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart04NetworkInterfacesSaveButton.Location.Y + $script:AutoChart04NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart04NetworkInterfacesNoticeTextbox)

$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.Clear()
$script:AutoChart04NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart04NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkInterfaces.Series["IPv6 Interfaces Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}



























##############################################################################################
# AutoChart05NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03NetworkInterfaces.Location.X
                  Y = $script:AutoChart03NetworkInterfaces.Location.Y + $script:AutoChart03NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart05NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart05NetworkInterfaces.Titles.Add($script:AutoChart05NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart05NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart05NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart05NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart05NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart05NetworkInterfaces.ChartAreas.Add($script:AutoChart05NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05NetworkInterfaces.Series.Add("IPs (Manual) Per Host")
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Enabled           = $True
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].BorderWidth       = 1
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].IsVisibleInLegend = $false
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Legend            = 'Legend'
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].ChartType         = 'Column'
$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Color             = 'Brown'

        function Generate-AutoChart05NetworkInterfaces {
            $script:AutoChart05NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart05NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart05NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart05NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart05NetworkInterfacesTitle.Text = "IPs (Manual) Per Host"

                $AutoChart05NetworkInterfacesCurrentComputer  = ''
                $AutoChart05NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart05NetworkInterfacesResultsCount     = 0
                $AutoChart05NetworkInterfacesComputer         = @()
                $AutoChart05NetworkInterfacesYResults         = @()
                $script:AutoChart05NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'Manual'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart05NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart05NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart05NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart05NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart05NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart05NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart05NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart05NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart05NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart05NetworkInterfacesCurrentComputer ) {
                            $AutoChart05NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart05NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart05NetworkInterfacesResultsCount
                                Computer     = $AutoChart05NetworkInterfacesComputer
                            }
                            $script:AutoChart05NetworkInterfacesOverallDataResults += $AutoChart05NetworkInterfacesYDataResults
                            $AutoChart05NetworkInterfacesYResults     = @()
                            $AutoChart05NetworkInterfacesResultsCount = 0
                            $AutoChart05NetworkInterfacesComputer     = @()
                            if ( $AutoChart05NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart05NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart05NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart05NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart05NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart05NetworkInterfacesResultsCount ; Computer = $AutoChart05NetworkInterfacesComputer }
                $script:AutoChart05NetworkInterfacesOverallDataResults += $AutoChart05NetworkInterfacesYDataResults
                $script:AutoChart05NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05NetworkInterfacesOverallDataResults.count))
                $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart05NetworkInterfacesTitle.Text = "IPs (Manual) Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart05NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart05NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesOptionsButton
$script:AutoChart05NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart05NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart05NetworkInterfaces.Controls.Add($script:AutoChart05NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart05NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart05NetworkInterfaces.Controls.Remove($script:AutoChart05NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05NetworkInterfaces)

$script:AutoChart05NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05NetworkInterfacesOverallDataResults.count))
    $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart05NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05NetworkInterfacesOverallDataResults.count))
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart05NetworkInterfacesOverallDataResults.count)
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart05NetworkInterfacesOverallDataResults.count) - $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart05NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05NetworkInterfacesOverallDataResults.count) - $script:AutoChart05NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart05NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart05NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart05NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].ChartType = $script:AutoChart05NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
#    $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart05NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05NetworkInterfacesChartTypesAvailable) { $script:AutoChart05NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart05NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfaces3DToggleButton
$script:AutoChart05NetworkInterfaces3DInclination = 0
$script:AutoChart05NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart05NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart05NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart05NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart05NetworkInterfaces3DInclination
        $script:AutoChart05NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart05NetworkInterfaces3DInclination)"
#        $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart05NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart05NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart05NetworkInterfaces3DInclination
        $script:AutoChart05NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart05NetworkInterfaces3DInclination)"
#        $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart05NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart05NetworkInterfaces3DInclination = 0
        $script:AutoChart05NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart05NetworkInterfaces3DInclination
        $script:AutoChart05NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart05NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart05NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05NetworkInterfacesColorsAvailable) { $script:AutoChart05NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Color = $script:AutoChart05NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart05NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05NetworkInterfacesImportCsvPosResults) { $script:AutoChart05NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart05NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart05NetworkInterfacesImportCsvPosResults) { $script:AutoChart05NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05NetworkInterfacesImportCsvNegResults) { $script:AutoChart05NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart05NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesCheckDiffButton
$script:AutoChart05NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart05NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart05NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05NetworkInterfaces }})
    $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05NetworkInterfaces }})
    $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart05NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart05NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart05NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart05NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart05NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart05NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart05NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart05NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart05NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart05NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart05NetworkInterfacesCheckDiffButton)


$AutoChart05NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart05NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Manual) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart05NetworkInterfacesExpandChartButton
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($AutoChart05NetworkInterfacesExpandChartButton)


$script:AutoChart05NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart05NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart05NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesOpenInShell
$script:AutoChart05NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart05NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart05NetworkInterfacesOpenInShell)


$script:AutoChart05NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05NetworkInterfacesOpenInShell.Location.X + $script:AutoChart05NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesViewResults
$script:AutoChart05NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart05NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart05NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart05NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart05NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart05NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05NetworkInterfaces -Title $script:AutoChart05NetworkInterfacesTitle
})
$script:AutoChart05NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart05NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart05NetworkInterfacesSaveButton.Location.Y + $script:AutoChart05NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart05NetworkInterfacesNoticeTextbox)

$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.Clear()
$script:AutoChart05NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkInterfaces.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

























##############################################################################################
# AutoChart06NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04NetworkInterfaces.Location.X
                  Y = $script:AutoChart04NetworkInterfaces.Location.Y + $script:AutoChart04NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart06NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06NetworkInterfaces.Titles.Add($script:AutoChart06NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart06NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart06NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart06NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart06NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart06NetworkInterfaces.ChartAreas.Add($script:AutoChart06NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06NetworkInterfaces.Series.Add("IPs (DHCP) Per Host")
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Enabled           = $True
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].BorderWidth       = 1
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].IsVisibleInLegend = $false
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Legend            = 'Legend'
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].ChartType         = 'Column'
$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Color             = 'Gray'

        function Generate-AutoChart06NetworkInterfaces {
            $script:AutoChart06NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart06NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart06NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart06NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart06NetworkInterfacesTitle.Text = "IPs (DHCP) Per Host"

                $AutoChart06NetworkInterfacesCurrentComputer  = ''
                $AutoChart06NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart06NetworkInterfacesResultsCount     = 0
                $AutoChart06NetworkInterfacesComputer         = @()
                $AutoChart06NetworkInterfacesYResults         = @()
                $script:AutoChart06NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'DHCP'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart06NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart06NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart06NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart06NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart06NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart06NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart06NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart06NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart06NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart06NetworkInterfacesCurrentComputer ) {
                            $AutoChart06NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart06NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart06NetworkInterfacesResultsCount
                                Computer     = $AutoChart06NetworkInterfacesComputer
                            }
                            $script:AutoChart06NetworkInterfacesOverallDataResults += $AutoChart06NetworkInterfacesYDataResults
                            $AutoChart06NetworkInterfacesYResults     = @()
                            $AutoChart06NetworkInterfacesResultsCount = 0
                            $AutoChart06NetworkInterfacesComputer     = @()
                            if ( $AutoChart06NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart06NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart06NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart06NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart06NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart06NetworkInterfacesResultsCount ; Computer = $AutoChart06NetworkInterfacesComputer }
                $script:AutoChart06NetworkInterfacesOverallDataResults += $AutoChart06NetworkInterfacesYDataResults
                $script:AutoChart06NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06NetworkInterfacesOverallDataResults.count))
                $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart06NetworkInterfacesTitle.Text = "IPs (DHCP) Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart06NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart06NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesOptionsButton
$script:AutoChart06NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart06NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart06NetworkInterfaces.Controls.Add($script:AutoChart06NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart06NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart06NetworkInterfaces.Controls.Remove($script:AutoChart06NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06NetworkInterfaces)

$script:AutoChart06NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06NetworkInterfacesOverallDataResults.count))
    $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart06NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06NetworkInterfacesOverallDataResults.count))
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart06NetworkInterfacesOverallDataResults.count)
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart06NetworkInterfacesOverallDataResults.count) - $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart06NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06NetworkInterfacesOverallDataResults.count) - $script:AutoChart06NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart06NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart06NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart06NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].ChartType = $script:AutoChart06NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
#    $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06NetworkInterfacesChartTypesAvailable) { $script:AutoChart06NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart06NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfaces3DToggleButton
$script:AutoChart06NetworkInterfaces3DInclination = 0
$script:AutoChart06NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart06NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart06NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart06NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart06NetworkInterfaces3DInclination
        $script:AutoChart06NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart06NetworkInterfaces3DInclination)"
#        $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart06NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart06NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart06NetworkInterfaces3DInclination
        $script:AutoChart06NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart06NetworkInterfaces3DInclination)"
#        $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart06NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart06NetworkInterfaces3DInclination = 0
        $script:AutoChart06NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart06NetworkInterfaces3DInclination
        $script:AutoChart06NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart06NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart06NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06NetworkInterfacesColorsAvailable) { $script:AutoChart06NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Color = $script:AutoChart06NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart06NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06NetworkInterfacesImportCsvPosResults) { $script:AutoChart06NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart06NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart06NetworkInterfacesImportCsvPosResults) { $script:AutoChart06NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06NetworkInterfacesImportCsvNegResults) { $script:AutoChart06NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart06NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesCheckDiffButton
$script:AutoChart06NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart06NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart06NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06NetworkInterfaces }})
    $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06NetworkInterfaces }})
    $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart06NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart06NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart06NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart06NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart06NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart06NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart06NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart06NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart06NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart06NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart06NetworkInterfacesCheckDiffButton)


$AutoChart06NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart06NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (DHCP) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart06NetworkInterfacesExpandChartButton
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($AutoChart06NetworkInterfacesExpandChartButton)


$script:AutoChart06NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart06NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart06NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesOpenInShell
$script:AutoChart06NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart06NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart06NetworkInterfacesOpenInShell)


$script:AutoChart06NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06NetworkInterfacesOpenInShell.Location.X + $script:AutoChart06NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesViewResults
$script:AutoChart06NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart06NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart06NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart06NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart06NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart06NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06NetworkInterfaces -Title $script:AutoChart06NetworkInterfacesTitle
})
$script:AutoChart06NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart06NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart06NetworkInterfacesSaveButton.Location.Y + $script:AutoChart06NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart06NetworkInterfacesNoticeTextbox)

$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.Clear()
$script:AutoChart06NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkInterfaces.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}





















##############################################################################################
# AutoChart07NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05NetworkInterfaces.Location.X
                  Y = $script:AutoChart05NetworkInterfaces.Location.Y + $script:AutoChart05NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart07NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart07NetworkInterfaces.Titles.Add($script:AutoChart07NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart07NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart07NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart07NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart07NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart07NetworkInterfaces.ChartAreas.Add($script:AutoChart07NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07NetworkInterfaces.Series.Add("IPs (Well Known) Per Host")
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Enabled           = $True
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].BorderWidth       = 1
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].IsVisibleInLegend = $false
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Legend            = 'Legend'
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].ChartType         = 'Column'
$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Color             = 'SlateBLue'

        function Generate-AutoChart07NetworkInterfaces {
            $script:AutoChart07NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart07NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart07NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart07NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart07NetworkInterfacesTitle.Text = "IPs (Well Known) Per Host"

                $AutoChart07NetworkInterfacesCurrentComputer  = ''
                $AutoChart07NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart07NetworkInterfacesResultsCount     = 0
                $AutoChart07NetworkInterfacesComputer         = @()
                $AutoChart07NetworkInterfacesYResults         = @()
                $script:AutoChart07NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'WellKnown'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart07NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart07NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart07NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart07NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart07NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart07NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart07NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart07NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart07NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart07NetworkInterfacesCurrentComputer ) {
                            $AutoChart07NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart07NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart07NetworkInterfacesResultsCount
                                Computer     = $AutoChart07NetworkInterfacesComputer
                            }
                            $script:AutoChart07NetworkInterfacesOverallDataResults += $AutoChart07NetworkInterfacesYDataResults
                            $AutoChart07NetworkInterfacesYResults     = @()
                            $AutoChart07NetworkInterfacesResultsCount = 0
                            $AutoChart07NetworkInterfacesComputer     = @()
                            if ( $AutoChart07NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart07NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart07NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart07NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart07NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart07NetworkInterfacesResultsCount ; Computer = $AutoChart07NetworkInterfacesComputer }
                $script:AutoChart07NetworkInterfacesOverallDataResults += $AutoChart07NetworkInterfacesYDataResults
                $script:AutoChart07NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07NetworkInterfacesOverallDataResults.count))
                $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart07NetworkInterfacesTitle.Text = "IPs (Well Known) Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart07NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart07NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesOptionsButton
$script:AutoChart07NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart07NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart07NetworkInterfaces.Controls.Add($script:AutoChart07NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart07NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart07NetworkInterfaces.Controls.Remove($script:AutoChart07NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07NetworkInterfaces)

$script:AutoChart07NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07NetworkInterfacesOverallDataResults.count))
    $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart07NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07NetworkInterfacesOverallDataResults.count))
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart07NetworkInterfacesOverallDataResults.count)
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart07NetworkInterfacesOverallDataResults.count) - $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart07NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07NetworkInterfacesOverallDataResults.count) - $script:AutoChart07NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart07NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart07NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart07NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].ChartType = $script:AutoChart07NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
#    $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart07NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07NetworkInterfacesChartTypesAvailable) { $script:AutoChart07NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart07NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfaces3DToggleButton
$script:AutoChart07NetworkInterfaces3DInclination = 0
$script:AutoChart07NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart07NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart07NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart07NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart07NetworkInterfaces3DInclination
        $script:AutoChart07NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart07NetworkInterfaces3DInclination)"
#        $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart07NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart07NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart07NetworkInterfaces3DInclination
        $script:AutoChart07NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart07NetworkInterfaces3DInclination)"
#        $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart07NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart07NetworkInterfaces3DInclination = 0
        $script:AutoChart07NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart07NetworkInterfaces3DInclination
        $script:AutoChart07NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart07NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart07NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07NetworkInterfacesColorsAvailable) { $script:AutoChart07NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Color = $script:AutoChart07NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart07NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart07NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07NetworkInterfacesImportCsvPosResults) { $script:AutoChart07NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart07NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart07NetworkInterfacesImportCsvPosResults) { $script:AutoChart07NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07NetworkInterfacesImportCsvNegResults) { $script:AutoChart07NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart07NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesCheckDiffButton
$script:AutoChart07NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart07NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart07NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07NetworkInterfaces }})
    $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07NetworkInterfaces }})
    $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart07NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart07NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart07NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart07NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart07NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart07NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart07NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart07NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart07NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart07NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart07NetworkInterfacesCheckDiffButton)


$AutoChart07NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart07NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Well Known) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart07NetworkInterfacesExpandChartButton
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($AutoChart07NetworkInterfacesExpandChartButton)


$script:AutoChart07NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart07NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart07NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesOpenInShell
$script:AutoChart07NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart07NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart07NetworkInterfacesOpenInShell)


$script:AutoChart07NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07NetworkInterfacesOpenInShell.Location.X + $script:AutoChart07NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesViewResults
$script:AutoChart07NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart07NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart07NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart07NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart07NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart07NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07NetworkInterfaces -Title $script:AutoChart07NetworkInterfacesTitle
})
$script:AutoChart07NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart07NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart07NetworkInterfacesSaveButton.Location.Y + $script:AutoChart07NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart07NetworkInterfacesNoticeTextbox)

$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.Clear()
$script:AutoChart07NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkInterfaces.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}


























##############################################################################################
# AutoChart08NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06NetworkInterfaces.Location.X
                  Y = $script:AutoChart06NetworkInterfaces.Location.Y + $script:AutoChart06NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart08NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart08NetworkInterfaces.Titles.Add($script:AutoChart08NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart08NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart08NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart08NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart08NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart08NetworkInterfaces.ChartAreas.Add($script:AutoChart08NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08NetworkInterfaces.Series.Add("IPs (Router Advertisement) Per Host")
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Enabled           = $True
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].BorderWidth       = 1
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].IsVisibleInLegend = $false
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Legend            = 'Legend'
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].ChartType         = 'Column'
$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Color             = 'Purple'

        function Generate-AutoChart08NetworkInterfaces {
            $script:AutoChart08NetworkInterfacesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart08NetworkInterfacesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart08NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart08NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart08NetworkInterfacesTitle.Text = "IPs (Router Advertisement) Per Host"

                $AutoChart08NetworkInterfacesCurrentComputer  = ''
                $AutoChart08NetworkInterfacesCheckIfFirstLine = $false
                $AutoChart08NetworkInterfacesResultsCount     = 0
                $AutoChart08NetworkInterfacesComputer         = @()
                $AutoChart08NetworkInterfacesYResults         = @()
                $script:AutoChart08NetworkInterfacesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'RouterAdvertisement'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart08NetworkInterfacesCheckIfFirstLine -eq $false ) { $AutoChart08NetworkInterfacesCurrentComputer  = $Line.PSComputerName ; $AutoChart08NetworkInterfacesCheckIfFirstLine = $true }
                    if ( $AutoChart08NetworkInterfacesCheckIfFirstLine -eq $true ) {
                        if ( $Line.PSComputerName -eq $AutoChart08NetworkInterfacesCurrentComputer ) {
                            if ( $AutoChart08NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart08NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart08NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart08NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart08NetworkInterfacesCurrentComputer ) {
                            $AutoChart08NetworkInterfacesCurrentComputer = $Line.PSComputerName
                            $AutoChart08NetworkInterfacesYDataResults    = New-Object PSObject -Property @{
                                ResultsCount = $AutoChart08NetworkInterfacesResultsCount
                                Computer     = $AutoChart08NetworkInterfacesComputer
                            }
                            $script:AutoChart08NetworkInterfacesOverallDataResults += $AutoChart08NetworkInterfacesYDataResults
                            $AutoChart08NetworkInterfacesYResults     = @()
                            $AutoChart08NetworkInterfacesResultsCount = 0
                            $AutoChart08NetworkInterfacesComputer     = @()
                            if ( $AutoChart08NetworkInterfacesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08NetworkInterfacesYResults += $Line.IPAddress ; $AutoChart08NetworkInterfacesResultsCount += 1 }
                                if ( $AutoChart08NetworkInterfacesComputer -notcontains $Line.PSComputerName ) { $AutoChart08NetworkInterfacesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart08NetworkInterfacesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart08NetworkInterfacesResultsCount ; Computer = $AutoChart08NetworkInterfacesComputer }
                $script:AutoChart08NetworkInterfacesOverallDataResults += $AutoChart08NetworkInterfacesYDataResults
                $script:AutoChart08NetworkInterfacesOverallDataResults | ForEach-Object { $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08NetworkInterfacesOverallDataResults.count))
                $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart08NetworkInterfacesTitle.Text = "IPs (Router Advertisement) Per Host`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart08NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart08NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesOptionsButton
$script:AutoChart08NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart08NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart08NetworkInterfaces.Controls.Add($script:AutoChart08NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart08NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart08NetworkInterfaces.Controls.Remove($script:AutoChart08NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08NetworkInterfaces)

$script:AutoChart08NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08NetworkInterfacesOverallDataResults.count))
    $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
    $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart08NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08NetworkInterfacesOverallDataResults.count))
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart08NetworkInterfacesOverallDataResults.count)
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart08NetworkInterfacesOverallDataResults.count) - $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart08NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08NetworkInterfacesOverallDataResults.count) - $script:AutoChart08NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart08NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart08NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart08NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].ChartType = $script:AutoChart08NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#    $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart08NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08NetworkInterfacesChartTypesAvailable) { $script:AutoChart08NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart08NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfaces3DToggleButton
$script:AutoChart08NetworkInterfaces3DInclination = 0
$script:AutoChart08NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart08NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart08NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart08NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart08NetworkInterfaces3DInclination
        $script:AutoChart08NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart08NetworkInterfaces3DInclination)"
#        $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart08NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart08NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart08NetworkInterfaces3DInclination
        $script:AutoChart08NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart08NetworkInterfaces3DInclination)"
#        $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else {
        $script:AutoChart08NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart08NetworkInterfaces3DInclination = 0
        $script:AutoChart08NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart08NetworkInterfaces3DInclination
        $script:AutoChart08NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart08NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart08NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08NetworkInterfacesColorsAvailable) { $script:AutoChart08NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Color = $script:AutoChart08NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfacesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart08NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart08NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08NetworkInterfacesImportCsvPosResults) { $script:AutoChart08NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart08NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart08NetworkInterfacesImportCsvPosResults) { $script:AutoChart08NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08NetworkInterfacesImportCsvNegResults) { $script:AutoChart08NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart08NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesCheckDiffButton
$script:AutoChart08NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart08NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart08NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08NetworkInterfaces }})
    $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08NetworkInterfaces }})
    $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart08NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart08NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart08NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart08NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart08NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart08NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart08NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart08NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart08NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart08NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart08NetworkInterfacesCheckDiffButton)


$AutoChart08NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart08NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Router Advertisement) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart08NetworkInterfacesExpandChartButton
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($AutoChart08NetworkInterfacesExpandChartButton)


$script:AutoChart08NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart08NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart08NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesOpenInShell
$script:AutoChart08NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart08NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart08NetworkInterfacesOpenInShell)


$script:AutoChart08NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08NetworkInterfacesOpenInShell.Location.X + $script:AutoChart08NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesViewResults
$script:AutoChart08NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart08NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart08NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart08NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart08NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart08NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08NetworkInterfaces -Title $script:AutoChart08NetworkInterfacesTitle
})
$script:AutoChart08NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart08NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart08NetworkInterfacesSaveButton.Location.Y + $script:AutoChart08NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart08NetworkInterfacesNoticeTextbox)

$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
$script:AutoChart08NetworkInterfacesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkInterfaces.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}



























##############################################################################################
# AutoChart09NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07NetworkInterfaces.Location.X
                  Y = $script:AutoChart07NetworkInterfaces.Location.Y + $script:AutoChart07NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart09NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09NetworkInterfaces.Titles.Add($script:AutoChart09NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart09NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart09NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart09NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart09NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart09NetworkInterfaces.ChartAreas.Add($script:AutoChart09NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09NetworkInterfaces.Series.Add("Address State")
$script:AutoChart09NetworkInterfaces.Series["Address State"].Enabled           = $True
$script:AutoChart09NetworkInterfaces.Series["Address State"].BorderWidth       = 1
$script:AutoChart09NetworkInterfaces.Series["Address State"].IsVisibleInLegend = $false
$script:AutoChart09NetworkInterfaces.Series["Address State"].Chartarea         = 'Chart Area'
$script:AutoChart09NetworkInterfaces.Series["Address State"].Legend            = 'Legend'
$script:AutoChart09NetworkInterfaces.Series["Address State"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09NetworkInterfaces.Series["Address State"]['PieLineColor']   = 'Black'
$script:AutoChart09NetworkInterfaces.Series["Address State"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09NetworkInterfaces.Series["Address State"].ChartType         = 'Column'
$script:AutoChart09NetworkInterfaces.Series["Address State"].Color             = 'Yellow'

        function Generate-AutoChart09NetworkInterfaces {
            $script:AutoChart09NetworkInterfacesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart09NetworkInterfacesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' | Sort-Object -Property 'AddressState' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()

            if ($script:AutoChart09NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart09NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart09NetworkInterfacesTitle.Text = "Address State"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart09NetworkInterfacesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09NetworkInterfacesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09NetworkInterfacesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressState) -eq $DataField.AddressState) {
                            $Count += 1
                            if ( $script:AutoChart09NetworkInterfacesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart09NetworkInterfacesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart09NetworkInterfacesUniqueCount = $script:AutoChart09NetworkInterfacesCsvComputers.Count
                    $script:AutoChart09NetworkInterfacesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09NetworkInterfacesUniqueCount
                        Computers   = $script:AutoChart09NetworkInterfacesCsvComputers
                    }
                    $script:AutoChart09NetworkInterfacesOverallDataResults += $script:AutoChart09NetworkInterfacesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount) }

                $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09NetworkInterfacesOverallDataResults.count))
                $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart09NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart09NetworkInterfacesTitle.Text = "Address State`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart09NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart09NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesOptionsButton
$script:AutoChart09NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart09NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart09NetworkInterfaces.Controls.Add($script:AutoChart09NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart09NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart09NetworkInterfaces.Controls.Remove($script:AutoChart09NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09NetworkInterfaces)

$script:AutoChart09NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09NetworkInterfacesOverallDataResults.count))
    $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
        $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    })
    $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart09NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09NetworkInterfacesOverallDataResults.count))
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart09NetworkInterfacesOverallDataResults.count)
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart09NetworkInterfacesOverallDataResults.count) - $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart09NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09NetworkInterfacesOverallDataResults.count) - $script:AutoChart09NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
        $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    })
$script:AutoChart09NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart09NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart09NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09NetworkInterfaces.Series["Address State"].ChartType = $script:AutoChart09NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
#    $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
})
$script:AutoChart09NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09NetworkInterfacesChartTypesAvailable) { $script:AutoChart09NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart09NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfaces3DToggleButton
$script:AutoChart09NetworkInterfaces3DInclination = 0
$script:AutoChart09NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart09NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart09NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart09NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart09NetworkInterfaces3DInclination
        $script:AutoChart09NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart09NetworkInterfaces3DInclination)"
#        $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart09NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart09NetworkInterfaces3DInclination
        $script:AutoChart09NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart09NetworkInterfaces3DInclination)"
#        $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    else {
        $script:AutoChart09NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart09NetworkInterfaces3DInclination = 0
        $script:AutoChart09NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart09NetworkInterfaces3DInclination
        $script:AutoChart09NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
})
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart09NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart09NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09NetworkInterfacesColorsAvailable) { $script:AutoChart09NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09NetworkInterfaces.Series["Address State"].Color = $script:AutoChart09NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfacesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart09NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressState' -eq $($script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart09NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09NetworkInterfacesImportCsvPosResults) { $script:AutoChart09NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart09NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart09NetworkInterfacesImportCsvPosResults) { $script:AutoChart09NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09NetworkInterfacesImportCsvNegResults) { $script:AutoChart09NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart09NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesCheckDiffButton
$script:AutoChart09NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart09NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' -ExpandProperty 'AddressState' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart09NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09NetworkInterfaces }})
    $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09NetworkInterfaces }})
    $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart09NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart09NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart09NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart09NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart09NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart09NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart09NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart09NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart09NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart09NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart09NetworkInterfacesCheckDiffButton)


$AutoChart09NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart09NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address States" -PropertyX "AddressState" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart09NetworkInterfacesExpandChartButton
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($AutoChart09NetworkInterfacesExpandChartButton)


$script:AutoChart09NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart09NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart09NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesOpenInShell
$script:AutoChart09NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart09NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart09NetworkInterfacesOpenInShell)


$script:AutoChart09NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09NetworkInterfacesOpenInShell.Location.X + $script:AutoChart09NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesViewResults
$script:AutoChart09NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart09NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart09NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart09NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart09NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart09NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09NetworkInterfaces -Title $script:AutoChart09NetworkInterfacesTitle
})
$script:AutoChart09NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart09NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart09NetworkInterfacesSaveButton.Location.Y + $script:AutoChart09NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart09NetworkInterfacesNoticeTextbox)

$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.Clear()
$script:AutoChart09NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkInterfaces.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}






















##############################################################################################
# AutoChart10NetworkInterfaces
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10NetworkInterfaces = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08NetworkInterfaces.Location.X
                  Y = $script:AutoChart08NetworkInterfaces.Location.Y + $script:AutoChart08NetworkInterfaces.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10NetworkInterfaces.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title
$script:AutoChart10NetworkInterfacesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10NetworkInterfaces.Titles.Add($script:AutoChart10NetworkInterfacesTitle)

### Create Charts Area
$script:AutoChart10NetworkInterfacesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10NetworkInterfacesArea.Name        = 'Chart Area'
$script:AutoChart10NetworkInterfacesArea.AxisX.Title = 'Hosts'
$script:AutoChart10NetworkInterfacesArea.AxisX.Interval          = 1
$script:AutoChart10NetworkInterfacesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10NetworkInterfacesArea.Area3DStyle.Inclination = 75
$script:AutoChart10NetworkInterfaces.ChartAreas.Add($script:AutoChart10NetworkInterfacesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10NetworkInterfaces.Series.Add("Address Family")
$script:AutoChart10NetworkInterfaces.Series["Address Family"].Enabled           = $True
$script:AutoChart10NetworkInterfaces.Series["Address Family"].BorderWidth       = 1
$script:AutoChart10NetworkInterfaces.Series["Address Family"].IsVisibleInLegend = $false
$script:AutoChart10NetworkInterfaces.Series["Address Family"].Chartarea         = 'Chart Area'
$script:AutoChart10NetworkInterfaces.Series["Address Family"].Legend            = 'Legend'
$script:AutoChart10NetworkInterfaces.Series["Address Family"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10NetworkInterfaces.Series["Address Family"]['PieLineColor']   = 'Black'
$script:AutoChart10NetworkInterfaces.Series["Address Family"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10NetworkInterfaces.Series["Address Family"].ChartType         = 'Column'
$script:AutoChart10NetworkInterfaces.Series["Address Family"].Color             = 'Red'

        function Generate-AutoChart10NetworkInterfaces {
            $script:AutoChart10NetworkInterfacesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart10NetworkInterfacesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' | Sort-Object -Property 'AddressFamily' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10NetworkInterfacesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()

            if ($script:AutoChart10NetworkInterfacesUniqueDataFields.count -gt 0){
                $script:AutoChart10NetworkInterfacesTitle.ForeColor = 'Black'
                $script:AutoChart10NetworkInterfacesTitle.Text = "Address Family"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart10NetworkInterfacesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10NetworkInterfacesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10NetworkInterfacesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressFamily) -eq $DataField.AddressFamily) {
                            $Count += 1
                            if ( $script:AutoChart10NetworkInterfacesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart10NetworkInterfacesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart10NetworkInterfacesUniqueCount = $script:AutoChart10NetworkInterfacesCsvComputers.Count
                    $script:AutoChart10NetworkInterfacesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10NetworkInterfacesUniqueCount
                        Computers   = $script:AutoChart10NetworkInterfacesCsvComputers
                    }
                    $script:AutoChart10NetworkInterfacesOverallDataResults += $script:AutoChart10NetworkInterfacesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount) }

                $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10NetworkInterfacesOverallDataResults.count))
                $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10NetworkInterfacesOverallDataResults.count))
            }
            else {
                $script:AutoChart10NetworkInterfacesTitle.ForeColor = 'Red'
                $script:AutoChart10NetworkInterfacesTitle.Text = "Address Family`n
[ No Data Available ]`n"
            }
        }
        Generate-AutoChart10NetworkInterfaces

### Auto Chart Panel that contains all the options to manage open/close feature
$script:AutoChart10NetworkInterfacesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10NetworkInterfaces.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkInterfaces.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesOptionsButton
$script:AutoChart10NetworkInterfacesOptionsButton.Add_Click({
    if ($script:AutoChart10NetworkInterfacesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10NetworkInterfacesOptionsButton.Text = 'Options ^'
        $script:AutoChart10NetworkInterfaces.Controls.Add($script:AutoChart10NetworkInterfacesManipulationPanel)
    }
    elseif ($script:AutoChart10NetworkInterfacesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10NetworkInterfacesOptionsButton.Text = 'Options v'
        $script:AutoChart10NetworkInterfaces.Controls.Remove($script:AutoChart10NetworkInterfacesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10NetworkInterfacesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10NetworkInterfaces)

$script:AutoChart10NetworkInterfacesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10NetworkInterfaces.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10NetworkInterfaces.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10NetworkInterfacesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10NetworkInterfacesOverallDataResults.count))
    $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue = $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar.Value
        $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar.Value)"
        $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
        $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    })
    $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Controls.Add($script:AutoChart10NetworkInterfacesTrimOffFirstTrackBar)
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10NetworkInterfacesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Location.X + $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10NetworkInterfacesOverallDataResults.count))
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.Value         = $($script:AutoChart10NetworkInterfacesOverallDataResults.count)
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue   = 0
    $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue = $($script:AutoChart10NetworkInterfacesOverallDataResults.count) - $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.Value
        $script:AutoChart10NetworkInterfacesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10NetworkInterfacesOverallDataResults.count) - $script:AutoChart10NetworkInterfacesTrimOffLastTrackBar.Value)"
        $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
        $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    })
$script:AutoChart10NetworkInterfacesTrimOffLastGroupBox.Controls.Add($script:AutoChart10NetworkInterfacesTrimOffLastTrackBar)
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfacesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10NetworkInterfacesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column'
    Location  = @{ X = $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Location.Y + $script:AutoChart10NetworkInterfacesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10NetworkInterfacesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10NetworkInterfaces.Series["Address Family"].ChartType = $script:AutoChart10NetworkInterfacesChartTypeComboBox.SelectedItem
#    $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
#    $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
})
$script:AutoChart10NetworkInterfacesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10NetworkInterfacesChartTypesAvailable) { $script:AutoChart10NetworkInterfacesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfacesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10NetworkInterfaces3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10NetworkInterfacesChartTypeComboBox.Location.X + $script:AutoChart10NetworkInterfacesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10NetworkInterfacesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfaces3DToggleButton
$script:AutoChart10NetworkInterfaces3DInclination = 0
$script:AutoChart10NetworkInterfaces3DToggleButton.Add_Click({
    $script:AutoChart10NetworkInterfaces3DInclination += 10
    if ( $script:AutoChart10NetworkInterfaces3DToggleButton.Text -eq "3D Off" ) {
        $script:AutoChart10NetworkInterfacesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart10NetworkInterfaces3DInclination
        $script:AutoChart10NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart10NetworkInterfaces3DInclination)"
#        $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10NetworkInterfaces3DInclination -le 90 ) {
        $script:AutoChart10NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart10NetworkInterfaces3DInclination
        $script:AutoChart10NetworkInterfaces3DToggleButton.Text  = "3D On ($script:AutoChart10NetworkInterfaces3DInclination)"
#        $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    else {
        $script:AutoChart10NetworkInterfaces3DToggleButton.Text  = "3D Off"
        $script:AutoChart10NetworkInterfaces3DInclination = 0
        $script:AutoChart10NetworkInterfacesArea.Area3DStyle.Inclination = $script:AutoChart10NetworkInterfaces3DInclination
        $script:AutoChart10NetworkInterfacesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
})
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfaces3DToggleButton)

### Change the color of the chart
$script:AutoChart10NetworkInterfacesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10NetworkInterfaces3DToggleButton.Location.X + $script:AutoChart10NetworkInterfaces3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkInterfaces3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10NetworkInterfacesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10NetworkInterfacesColorsAvailable) { $script:AutoChart10NetworkInterfacesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10NetworkInterfacesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10NetworkInterfaces.Series["Address Family"].Color = $script:AutoChart10NetworkInterfacesChangeColorComboBox.SelectedItem
})
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfacesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10NetworkInterfaces {
    # List of Positive Endpoints that positively match
    $script:AutoChart10NetworkInterfacesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressFamily' -eq $($script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart10NetworkInterfacesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10NetworkInterfacesImportCsvPosResults) { $script:AutoChart10NetworkInterfacesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10NetworkInterfacesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique

    $script:AutoChart10NetworkInterfacesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10NetworkInterfacesImportCsvAll) { if ($Endpoint -notin $script:AutoChart10NetworkInterfacesImportCsvPosResults) { $script:AutoChart10NetworkInterfacesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10NetworkInterfacesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10NetworkInterfacesImportCsvNegResults) { $script:AutoChart10NetworkInterfacesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10NetworkInterfacesImportCsvPosResults.count))"
    $script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10NetworkInterfacesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10NetworkInterfacesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10NetworkInterfacesTrimOffLastGroupBox.Location.X + $script:AutoChart10NetworkInterfacesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkInterfacesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesCheckDiffButton
$script:AutoChart10NetworkInterfacesCheckDiffButton.Add_Click({
    $script:AutoChart10NetworkInterfacesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' -ExpandProperty 'AddressFamily' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10NetworkInterfacesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10NetworkInterfacesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffDropDownLabel.Location.y + $script:AutoChart10NetworkInterfacesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10NetworkInterfacesInvestDiffDropDownArray) { $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10NetworkInterfaces }})
    $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10NetworkInterfaces })

    ### Investigate Difference Execute Button
    $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Location.y + $script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton
    $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10NetworkInterfaces }})
    $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10NetworkInterfaces })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton.Location.y + $script:AutoChart10NetworkInterfacesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10NetworkInterfacesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Location.y + $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Location.x + $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10NetworkInterfacesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel.Location.y + $script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10NetworkInterfacesInvestDiffForm.Controls.AddRange(@($script:AutoChart10NetworkInterfacesInvestDiffDropDownLabel,$script:AutoChart10NetworkInterfacesInvestDiffDropDownComboBox,$script:AutoChart10NetworkInterfacesInvestDiffExecuteButton,$script:AutoChart10NetworkInterfacesInvestDiffPosResultsLabel,$script:AutoChart10NetworkInterfacesInvestDiffPosResultsTextBox,$script:AutoChart10NetworkInterfacesInvestDiffNegResultsLabel,$script:AutoChart10NetworkInterfacesInvestDiffNegResultsTextBox))
    $script:AutoChart10NetworkInterfacesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10NetworkInterfacesInvestDiffForm.ShowDialog()
})
$script:AutoChart10NetworkInterfacesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart10NetworkInterfacesCheckDiffButton)


$AutoChart10NetworkInterfacesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10NetworkInterfacesCheckDiffButton.Location.X + $script:AutoChart10NetworkInterfacesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10NetworkInterfacesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address Family" -PropertyX "AddressFamily" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart10NetworkInterfacesExpandChartButton
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($AutoChart10NetworkInterfacesExpandChartButton)


$script:AutoChart10NetworkInterfacesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10NetworkInterfacesCheckDiffButton.Location.X
                   Y = $script:AutoChart10NetworkInterfacesCheckDiffButton.Location.Y + $script:AutoChart10NetworkInterfacesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesOpenInShell
$script:AutoChart10NetworkInterfacesOpenInShell.Add_Click({ AutoChartOpenDataInShell })
$script:AutoChart10NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart10NetworkInterfacesOpenInShell)


$script:AutoChart10NetworkInterfacesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10NetworkInterfacesOpenInShell.Location.X + $script:AutoChart10NetworkInterfacesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkInterfacesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesViewResults
$script:AutoChart10NetworkInterfacesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" })
$script:AutoChart10NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart10NetworkInterfacesViewResults)


### Save the chart to file
$script:AutoChart10NetworkInterfacesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10NetworkInterfacesOpenInShell.Location.X
                  Y = $script:AutoChart10NetworkInterfacesOpenInShell.Location.Y + $script:AutoChart10NetworkInterfacesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkInterfacesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10NetworkInterfacesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10NetworkInterfaces -Title $script:AutoChart10NetworkInterfacesTitle
})
$script:AutoChart10NetworkInterfacesManipulationPanel.controls.Add($script:AutoChart10NetworkInterfacesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10NetworkInterfacesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10NetworkInterfacesSaveButton.Location.X
                        Y = $script:AutoChart10NetworkInterfacesSaveButton.Location.Y + $script:AutoChart10NetworkInterfacesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10NetworkInterfacesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10NetworkInterfacesManipulationPanel.Controls.Add($script:AutoChart10NetworkInterfacesNoticeTextbox)

$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.Clear()
$script:AutoChart10NetworkInterfacesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkInterfacesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkInterfacesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkInterfaces.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}






