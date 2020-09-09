$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Network Connections'
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
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart01NetworkConnections.Controls.Remove($script:AutoChart01NetworkConnectionsManipulationPanel)
    $script:AutoChart02NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart02NetworkConnections.Controls.Remove($script:AutoChart02NetworkConnectionsManipulationPanel)
    $script:AutoChart03NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart03NetworkConnections.Controls.Remove($script:AutoChart03NetworkConnectionsManipulationPanel)
    $script:AutoChart04NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart04NetworkConnections.Controls.Remove($script:AutoChart04NetworkConnectionsManipulationPanel)
    $script:AutoChart05NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart05NetworkConnections.Controls.Remove($script:AutoChart05NetworkConnectionsManipulationPanel)
    $script:AutoChart06NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart06NetworkConnections.Controls.Remove($script:AutoChart06NetworkConnectionsManipulationPanel)
    $script:AutoChart07NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart07NetworkConnections.Controls.Remove($script:AutoChart07NetworkConnectionsManipulationPanel)
    $script:AutoChart08NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart08NetworkConnections.Controls.Remove($script:AutoChart08NetworkConnectionsManipulationPanel)
    $script:AutoChart09NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart09NetworkConnections.Controls.Remove($script:AutoChart09NetworkConnectionsManipulationPanel)
    $script:AutoChart10NetworkConnectionsOptionsButton.Text = 'Options v'
    $script:AutoChart10NetworkConnections.Controls.Remove($script:AutoChart10NetworkConnectionsManipulationPanel)
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
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-ACME')
        }
        else {
            $ScriptBlockProgressBarInput = { Update-AutoChartsNetworkConnections -ComputerNameList $ChartComputerList }
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
            $ScriptBlockProgressBarInput = { Update-AutoChartsNetworkConnections -ComputerNameList $script:ComputerList }
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

    Generate-AutoChart01NetworkConnections
    Generate-AutoChart02NetworkConnections
    Generate-AutoChart03NetworkConnections
    Generate-AutoChart04NetworkConnections
    Generate-AutoChart05NetworkConnections
    Generate-AutoChart06NetworkConnections
    Generate-AutoChart07NetworkConnections
    Generate-AutoChart08NetworkConnections
    Generate-AutoChart09NetworkConnections
    Generate-AutoChart10NetworkConnections
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
            $script:AutoChart01NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart01NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart01NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv `
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
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
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
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsOptionsButton
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
CommonButtonSettings -Button $script:AutoChart01NetworkConnections3DToggleButton
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
    $script:AutoChart01NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'LocalAddressPort' -eq $($script:AutoChart01NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01NetworkConnectionsImportCsvPosResults) { $script:AutoChart01NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsCheckDiffButton
$script:AutoChart01NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart01NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'LocalAddressPort' -ExpandProperty 'LocalAddressPort' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsInvestDiffExecuteButton
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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPv4 Ports Listening" -PropertyX "LocalAddressPort" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart01NetworkConnectionsExpandChartButton
$script:AutoChart01NetworkConnectionsManipulationPanel.Controls.Add($AutoChart01NetworkConnectionsExpandChartButton)


$script:AutoChart01NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart01NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart01NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsOpenInShell
$script:AutoChart01NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsOpenInShell)


$script:AutoChart01NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart01NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart01NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart01NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsSortButton
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
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsViewResults
$script:AutoChart01NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart01NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart01NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart01NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart01NetworkConnectionsViewResults.Location.Y + $script:AutoChart01NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01NetworkConnectionsSaveButton
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
            $script:AutoChart02NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart02NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $LocalNetworkArray = @(10,172.16,172.17,172.18,172.19,172.20,172.21,172.22,172.23,172.24,172.25,172.26,172.27,172.28,172.29,172.30,172.31,192.168)

            $script:AutoChart02NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv `
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
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
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
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsOptionsButton
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
CommonButtonSettings -Button $script:AutoChart02NetworkConnections3DToggleButton
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
    $script:AutoChart02NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'RemoteAddress' -eq $($script:AutoChart02NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02NetworkConnectionsImportCsvPosResults) { $script:AutoChart02NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
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
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsCheckDiffButton
$script:AutoChart02NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart02NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'RemoteAddress' -ExpandProperty 'RemoteAddress' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
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
    CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsInvestDiffExecuteButton
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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Connections to Private Network Endpoints" -PropertyX "RemoteAddress" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart02NetworkConnectionsExpandChartButton
$script:AutoChart02NetworkConnectionsManipulationPanel.Controls.Add($AutoChart02NetworkConnectionsExpandChartButton)


$script:AutoChart02NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart02NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart02NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsOpenInShell
$script:AutoChart02NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsOpenInShell)


$script:AutoChart02NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart02NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart02NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart02NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsSortButton
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
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsViewResults
$script:AutoChart02NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart02NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart02NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart02NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart02NetworkConnectionsViewResults.Location.Y + $script:AutoChart02NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02NetworkConnectionsSaveButton
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























<#
##############################################################################################
# AutoChart03NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01NetworkConnections.Location.X
                  Y = $script:AutoChart01NetworkConnections.Location.Y + $script:AutoChart01NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03NetworkConnections.Add_MouseHover({ Close-AllOptions })


### Auto Create Charts Title 
$script:AutoChart03NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03NetworkConnections.Titles.Add($script:AutoChart03NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart03NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart03NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart03NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart03NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart03NetworkConnections.ChartAreas.Add($script:AutoChart03NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03NetworkConnections.Series.Add("Duration in Minutes")
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Enabled           = $True
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].BorderWidth       = 1
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].IsVisibleInLegend = $false
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Chartarea         = 'Chart Area'
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Legend            = 'Legend'
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"]['PieLineColor']   = 'Black'
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].ChartType         = 'Column'
$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Color             = 'Red'

function Generate-AutoChart03NetworkConnections {
            $script:AutoChart03NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart03NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart03NetworkConnectionsUniqueDataFields = $script:AutoChartDataSourceCsv `
            | Where-Object {$_.State         -eq 'Established'} `
            | Where-Object {$_.LocalAddress  -notmatch ':'} `
            | Where-Object {$_.RemoteAddress -ne '0.0.0.0'} `
            | Where-Object {$_.RemoteAddress -notmatch "127.[\d]{1,3}.[\d]{1,3}.[\d]{1,3}"} `
            | ForEach-Object {
                $Duration = ((New-TimeSpan -Start $_.CreationTime -End (Get-date)).ToString())
                $Duration = $Duration.Substring(0,$Duration.Length-11)
                if ($Duration.split(':')[0] -notlike '*.*') { $Duration = '0.' + $Duration }
                [PSCustomObject]@{
                    #LocalAddress  = $_.LocalAddress
                    #LocalPort     = $_.LocalPort
                    #RemoteAddress = $_.RemoteAddress
                    #RemotePort    = $_.RemotePort
                    #State         = $_.State
                    #OwningProcess = $_.OwningProcess
                    #CreationTime  = $_.CreationTime
                    Duration      = $Duration -replace '\.',':'
                }
            } | Select-Object Duration | Sort-Object {$_.Duration -as [string]} -Unique
            $script:AutoChart03NetworkConnectionsUniqueDataFields | ogv
            
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.Clear()

            if ($script:AutoChart03NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart03NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart03NetworkConnectionsTitle.Text = "Duration in Minutes (DD:HH:MM)"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03NetworkConnectionsOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03NetworkConnectionsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart03NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Duration -eq $DataField.Duration) {
                            $Count += 1
                            if ( $script:AutoChart03NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03NetworkConnectionsCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03NetworkConnectionsCsvComputers.Count
                        Computers   = $script:AutoChart03NetworkConnectionsCsvComputers 
                    }           
                    $script:AutoChart03NetworkConnectionsOverallDataResults += $script:AutoChart03NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart03NetworkConnectionsSortButton.text = "View: Count"
                $script:AutoChart03NetworkConnectionsOverallDataResultsSortAlphaNum = $script:AutoChart03NetworkConnectionsOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart03NetworkConnectionsOverallDataResultsSortCount    = $script:AutoChart03NetworkConnectionsOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart03NetworkConnectionsOverallDataResults = $script:AutoChart03NetworkConnectionsOverallDataResultsSortAlphaNum

                $script:AutoChart03NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount) }
                $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03NetworkConnectionsOverallDataResults.count))
                $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart03NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart03NetworkConnectionsTitle.Text = "Duration in Minutes`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsOptionsButton
$script:AutoChart03NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart03NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart03NetworkConnections.Controls.Add($script:AutoChart03NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart03NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart03NetworkConnections.Controls.Remove($script:AutoChart03NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03NetworkConnections)


$script:AutoChart03NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.Clear()
        $script:AutoChart03NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
    })
    $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart03NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03NetworkConnectionsOverallDataResults.count))
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart03NetworkConnectionsOverallDataResults.count)
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart03NetworkConnectionsOverallDataResults.count) - $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart03NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03NetworkConnectionsOverallDataResults.count) - $script:AutoChart03NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.Clear()
        $script:AutoChart03NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
    })
$script:AutoChart03NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart03NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart03NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].ChartType = $script:AutoChart03NetworkConnectionsChartTypeComboBox.SelectedItem
})
$script:AutoChart03NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03NetworkConnectionsChartTypesAvailable) { $script:AutoChart03NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnectionsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart03NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnections3DToggleButton
$script:AutoChart03NetworkConnections3DInclination = 0
$script:AutoChart03NetworkConnections3DToggleButton.Add_Click({
    
    $script:AutoChart03NetworkConnections3DInclination += 10
    if ( $script:AutoChart03NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart03NetworkConnections3DInclination
        $script:AutoChart03NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart03NetworkConnections3DInclination)"
    }
    elseif ( $script:AutoChart03NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart03NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart03NetworkConnections3DInclination
        $script:AutoChart03NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart03NetworkConnections3DInclination)" 
    }
    else { 
        $script:AutoChart03NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart03NetworkConnections3DInclination = 0
        $script:AutoChart03NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart03NetworkConnections3DInclination
        $script:AutoChart03NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart03NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03NetworkConnections3DToggleButton.Location.X + $script:AutoChart03NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03NetworkConnectionsColorsAvailable) { $script:AutoChart03NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Color = $script:AutoChart03NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Duration' -eq $($script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03NetworkConnectionsImportCsvPosResults) { $script:AutoChart03NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart03NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart03NetworkConnectionsImportCsvPosResults) { $script:AutoChart03NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03NetworkConnectionsImportCsvNegResults) { $script:AutoChart03NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart03NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsCheckDiffButton
$script:AutoChart03NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart03NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Duration' -ExpandProperty 'Duration' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart03NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03NetworkConnections }})
    $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03NetworkConnections }})
    $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart03NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart03NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart03NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart03NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart03NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart03NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart03NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart03NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart03NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart03NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart03NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart03NetworkConnectionsCheckDiffButton)


$AutoChart03NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart03NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Duration in Minutes" -PropertyX "Duration" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart03NetworkConnectionsExpandChartButton
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($AutoChart03NetworkConnectionsExpandChartButton)


$script:AutoChart03NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart03NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart03NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsOpenInShell
$script:AutoChart03NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart03NetworkConnectionsOpenInShell)


$script:AutoChart03NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart03NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart03NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart03NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsSortButton
$script:AutoChart03NetworkConnectionsSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart03NetworkConnectionsOverallDataResults = $script:AutoChart03NetworkConnectionsOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart03NetworkConnectionsOverallDataResults = $script:AutoChart03NetworkConnectionsOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.Clear()
    $script:AutoChart03NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart03NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03NetworkConnections.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
})
$script:AutoChart03NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart03NetworkConnectionsSortButton)


$script:AutoChart03NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03NetworkConnectionsOpenInShell.Location.X + $script:AutoChart03NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsViewResults
$script:AutoChart03NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart03NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart03NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart03NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart03NetworkConnectionsViewResults.Location.Y + $script:AutoChart03NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03NetworkConnections -Title $script:AutoChart03NetworkConnectionsTitle
})
$script:AutoChart03NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart03NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03NetworkConnectionsSortButton.Location.X 
                        Y = $script:AutoChart03NetworkConnectionsSortButton.Location.Y + $script:AutoChart03NetworkConnectionsSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart03NetworkConnectionsNoticeTextbox)





























##############################################################################################
# AutoChart04NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02NetworkConnections.Location.X
                  Y = $script:AutoChart02NetworkConnections.Location.Y + $script:AutoChart02NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart04NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04NetworkConnections.Titles.Add($script:AutoChart04NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart04NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart04NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart04NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart04NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart04NetworkConnections.ChartAreas.Add($script:AutoChart04NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04NetworkConnections.Series.Add("Connections to Class C Networks")
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Enabled           = $True
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].BorderWidth       = 1
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].IsVisibleInLegend = $false
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Chartarea         = 'Chart Area'
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Legend            = 'Legend'
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"]['PieLineColor']   = 'Black'
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].ChartType         = 'Column'
$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Color             = 'Red'

function Generate-AutoChart04NetworkConnections {
            $script:AutoChart04NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart04NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart04NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Where-Object {$_.LocalAddress -notmatch ':'} `
            | Select-Object @{n="ClassC";e={($_.RemoteAddress.split('.')[0..2] -join '.') + '.x'}} `
            | Sort-Object {[string]$_.ClassC} -Unique


            $script:AutoChart04NetworkConnectionsUniqueDataFields = $script:AutoChart04NetworkConnectionsUniqueDataFields `
            | Select-Object 'ClassC'  | Sort-Object -Property 'ClassC' -Unique
            
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.Clear()

            if ($script:AutoChart04NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart04NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart04NetworkConnectionsTitle.Text = "Connections to Class C Networks"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04NetworkConnectionsOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04NetworkConnectionsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart04NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.ClassC -eq $DataField.ClassC) {
                            $Count += 1
                            if ( $script:AutoChart04NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04NetworkConnectionsCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04NetworkConnectionsCsvComputers.Count
                        Computers   = $script:AutoChart04NetworkConnectionsCsvComputers 
                    }           
                    $script:AutoChart04NetworkConnectionsOverallDataResults += $script:AutoChart04NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart04NetworkConnectionsSortButton.text = "View: Count"
                $script:AutoChart04NetworkConnectionsOverallDataResultsSortAlphaNum = $script:AutoChart04NetworkConnectionsOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart04NetworkConnectionsOverallDataResultsSortCount    = $script:AutoChart04NetworkConnectionsOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart04NetworkConnectionsOverallDataResults = $script:AutoChart04NetworkConnectionsOverallDataResultsSortAlphaNum

                $script:AutoChart04NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount) }
                $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04NetworkConnectionsOverallDataResults.count))
                $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart04NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart04NetworkConnectionsTitle.Text = "Connections to Class C Networks`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsOptionsButton
$script:AutoChart04NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart04NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart04NetworkConnections.Controls.Add($script:AutoChart04NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart04NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart04NetworkConnections.Controls.Remove($script:AutoChart04NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04NetworkConnections)


$script:AutoChart04NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.Clear()
        $script:AutoChart04NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
    })
    $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart04NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04NetworkConnectionsOverallDataResults.count))
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart04NetworkConnectionsOverallDataResults.count)
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart04NetworkConnectionsOverallDataResults.count) - $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart04NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04NetworkConnectionsOverallDataResults.count) - $script:AutoChart04NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.Clear()
        $script:AutoChart04NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
    })
$script:AutoChart04NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart04NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart04NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].ChartType = $script:AutoChart04NetworkConnectionsChartTypeComboBox.SelectedItem
})
$script:AutoChart04NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04NetworkConnectionsChartTypesAvailable) { $script:AutoChart04NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnectionsChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart04NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnections3DToggleButton
$script:AutoChart04NetworkConnections3DInclination = 0
$script:AutoChart04NetworkConnections3DToggleButton.Add_Click({
    
    $script:AutoChart04NetworkConnections3DInclination += 10
    if ( $script:AutoChart04NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart04NetworkConnections3DInclination
        $script:AutoChart04NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart04NetworkConnections3DInclination)"
    }
    elseif ( $script:AutoChart04NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart04NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart04NetworkConnections3DInclination
        $script:AutoChart04NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart04NetworkConnections3DInclination)" 
    }
    else { 
        $script:AutoChart04NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart04NetworkConnections3DInclination = 0
        $script:AutoChart04NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart04NetworkConnections3DInclination
        $script:AutoChart04NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart04NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04NetworkConnections3DToggleButton.Location.X + $script:AutoChart04NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04NetworkConnectionsColorsAvailable) { $script:AutoChart04NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Color = $script:AutoChart04NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ClassC' -eq $($script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04NetworkConnectionsImportCsvPosResults) { $script:AutoChart04NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart04NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart04NetworkConnectionsImportCsvPosResults) { $script:AutoChart04NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04NetworkConnectionsImportCsvNegResults) { $script:AutoChart04NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart04NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsCheckDiffButton
$script:AutoChart04NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart04NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'ClassC' -ExpandProperty 'ClassC' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart04NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04NetworkConnections }})
    $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04NetworkConnections }})
    $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart04NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart04NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart04NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart04NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart04NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart04NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart04NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart04NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart04NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart04NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart04NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart04NetworkConnectionsCheckDiffButton)


$AutoChart04NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart04NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Connections to Class C Networks" -PropertyX "ClassC" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart04NetworkConnectionsExpandChartButton
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($AutoChart04NetworkConnectionsExpandChartButton)


$script:AutoChart04NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart04NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart04NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsOpenInShell
$script:AutoChart04NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart04NetworkConnectionsOpenInShell)


$script:AutoChart04NetworkConnectionsSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart04NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart04NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart04NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsSortButton
$script:AutoChart04NetworkConnectionsSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart04NetworkConnectionsOverallDataResults = $script:AutoChart04NetworkConnectionsOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart04NetworkConnectionsOverallDataResults = $script:AutoChart04NetworkConnectionsOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.Clear()
    $script:AutoChart04NetworkConnectionsOverallDataResults | Select-Object -skip $script:AutoChart04NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04NetworkConnections.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
})
$script:AutoChart04NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart04NetworkConnectionsSortButton)


$script:AutoChart04NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04NetworkConnectionsOpenInShell.Location.X + $script:AutoChart04NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsViewResults
$script:AutoChart04NetworkConnectionsViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart04NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart04NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart04NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04NetworkConnectionsViewResults.Location.X
                  Y = $script:AutoChart04NetworkConnectionsViewResults.Location.Y + $script:AutoChart04NetworkConnectionsViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04NetworkConnections -Title $script:AutoChart04NetworkConnectionsTitle
})
$script:AutoChart04NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart04NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04NetworkConnectionsSortButton.Location.X 
                        Y = $script:AutoChart04NetworkConnectionsSortButton.Location.Y + $script:AutoChart04NetworkConnectionsSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart04NetworkConnectionsNoticeTextbox)




























##############################################################################################
# AutoChart05NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03NetworkConnections.Location.X
                  Y = $script:AutoChart03NetworkConnections.Location.Y + $script:AutoChart03NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart05NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart05NetworkConnections.Titles.Add($script:AutoChart05NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart05NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart05NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart05NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart05NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart05NetworkConnections.ChartAreas.Add($script:AutoChart05NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05NetworkConnections.Series.Add("IPs (Manual) Per Host")  
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Enabled           = $True
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].BorderWidth       = 1
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].IsVisibleInLegend = $false
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Legend            = 'Legend'
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].ChartType         = 'Column'
$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Color             = 'Brown'

        function Generate-AutoChart05NetworkConnections {
            $script:AutoChart05NetworkConnectionsCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart05NetworkConnectionsUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart05NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart05NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart05NetworkConnectionsTitle.Text = "IPs (Manual) Per Host"

                $AutoChart05NetworkConnectionsCurrentComputer  = ''
                $AutoChart05NetworkConnectionsCheckIfFirstLine = $false
                $AutoChart05NetworkConnectionsResultsCount     = 0
                $AutoChart05NetworkConnectionsComputer         = @()
                $AutoChart05NetworkConnectionsYResults         = @()
                $script:AutoChart05NetworkConnectionsOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'Manual'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart05NetworkConnectionsCheckIfFirstLine -eq $false ) { $AutoChart05NetworkConnectionsCurrentComputer  = $Line.PSComputerName ; $AutoChart05NetworkConnectionsCheckIfFirstLine = $true }
                    if ( $AutoChart05NetworkConnectionsCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart05NetworkConnectionsCurrentComputer ) {
                            if ( $AutoChart05NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart05NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart05NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart05NetworkConnectionsComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart05NetworkConnectionsCurrentComputer ) { 
                            $AutoChart05NetworkConnectionsCurrentComputer = $Line.PSComputerName
                            $AutoChart05NetworkConnectionsYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart05NetworkConnectionsResultsCount
                                Computer     = $AutoChart05NetworkConnectionsComputer 
                            }
                            $script:AutoChart05NetworkConnectionsOverallDataResults += $AutoChart05NetworkConnectionsYDataResults
                            $AutoChart05NetworkConnectionsYResults     = @()
                            $AutoChart05NetworkConnectionsResultsCount = 0
                            $AutoChart05NetworkConnectionsComputer     = @()
                            if ( $AutoChart05NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart05NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart05NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart05NetworkConnectionsComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart05NetworkConnectionsYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart05NetworkConnectionsResultsCount ; Computer = $AutoChart05NetworkConnectionsComputer }    
                $script:AutoChart05NetworkConnectionsOverallDataResults += $AutoChart05NetworkConnectionsYDataResults
                $script:AutoChart05NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05NetworkConnectionsOverallDataResults.count))
                $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart05NetworkConnectionsTitle.Text = "IPs (Manual) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart05NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsOptionsButton
$script:AutoChart05NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart05NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart05NetworkConnections.Controls.Add($script:AutoChart05NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart05NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart05NetworkConnections.Controls.Remove($script:AutoChart05NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05NetworkConnections)

$script:AutoChart05NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart05NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05NetworkConnectionsOverallDataResults.count))
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart05NetworkConnectionsOverallDataResults.count)
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart05NetworkConnectionsOverallDataResults.count) - $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart05NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05NetworkConnectionsOverallDataResults.count) - $script:AutoChart05NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart05NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart05NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart05NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].ChartType = $script:AutoChart05NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
#    $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart05NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05NetworkConnectionsChartTypesAvailable) { $script:AutoChart05NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart05NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnections3DToggleButton
$script:AutoChart05NetworkConnections3DInclination = 0
$script:AutoChart05NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart05NetworkConnections3DInclination += 10
    if ( $script:AutoChart05NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart05NetworkConnections3DInclination
        $script:AutoChart05NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart05NetworkConnections3DInclination)"
#        $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart05NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart05NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart05NetworkConnections3DInclination
        $script:AutoChart05NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart05NetworkConnections3DInclination)" 
#        $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart05NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart05NetworkConnections3DInclination = 0
        $script:AutoChart05NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart05NetworkConnections3DInclination
        $script:AutoChart05NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart05NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05NetworkConnections3DToggleButton.Location.X + $script:AutoChart05NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05NetworkConnectionsColorsAvailable) { $script:AutoChart05NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Color = $script:AutoChart05NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnectionsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05NetworkConnectionsImportCsvPosResults) { $script:AutoChart05NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart05NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart05NetworkConnectionsImportCsvPosResults) { $script:AutoChart05NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05NetworkConnectionsImportCsvNegResults) { $script:AutoChart05NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart05NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsCheckDiffButton
$script:AutoChart05NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart05NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart05NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05NetworkConnections }})
    $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05NetworkConnections }})
    $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart05NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart05NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart05NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart05NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart05NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart05NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart05NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart05NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart05NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart05NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart05NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart05NetworkConnectionsCheckDiffButton)


$AutoChart05NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart05NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Manual) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart05NetworkConnectionsExpandChartButton
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($AutoChart05NetworkConnectionsExpandChartButton)


$script:AutoChart05NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart05NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart05NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsOpenInShell
$script:AutoChart05NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart05NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart05NetworkConnectionsOpenInShell)


$script:AutoChart05NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05NetworkConnectionsOpenInShell.Location.X + $script:AutoChart05NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsViewResults
$script:AutoChart05NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart05NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart05NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart05NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart05NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart05NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05NetworkConnections -Title $script:AutoChart05NetworkConnectionsTitle
})
$script:AutoChart05NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart05NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart05NetworkConnectionsSaveButton.Location.Y + $script:AutoChart05NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart05NetworkConnectionsNoticeTextbox)

$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.Clear()
$script:AutoChart05NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05NetworkConnections.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

























##############################################################################################
# AutoChart06NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04NetworkConnections.Location.X
                  Y = $script:AutoChart04NetworkConnections.Location.Y + $script:AutoChart04NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart06NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06NetworkConnections.Titles.Add($script:AutoChart06NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart06NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart06NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart06NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart06NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart06NetworkConnections.ChartAreas.Add($script:AutoChart06NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06NetworkConnections.Series.Add("IPs (DHCP) Per Host")  
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Enabled           = $True
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].BorderWidth       = 1
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].IsVisibleInLegend = $false
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Legend            = 'Legend'
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].ChartType         = 'Column'
$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Color             = 'Gray'

        function Generate-AutoChart06NetworkConnections {
            $script:AutoChart06NetworkConnectionsCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart06NetworkConnectionsUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart06NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart06NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart06NetworkConnectionsTitle.Text = "IPs (DHCP) Per Host"

                $AutoChart06NetworkConnectionsCurrentComputer  = ''
                $AutoChart06NetworkConnectionsCheckIfFirstLine = $false
                $AutoChart06NetworkConnectionsResultsCount     = 0
                $AutoChart06NetworkConnectionsComputer         = @()
                $AutoChart06NetworkConnectionsYResults         = @()
                $script:AutoChart06NetworkConnectionsOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'DHCP'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart06NetworkConnectionsCheckIfFirstLine -eq $false ) { $AutoChart06NetworkConnectionsCurrentComputer  = $Line.PSComputerName ; $AutoChart06NetworkConnectionsCheckIfFirstLine = $true }
                    if ( $AutoChart06NetworkConnectionsCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart06NetworkConnectionsCurrentComputer ) {
                            if ( $AutoChart06NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart06NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart06NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart06NetworkConnectionsComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart06NetworkConnectionsCurrentComputer ) { 
                            $AutoChart06NetworkConnectionsCurrentComputer = $Line.PSComputerName
                            $AutoChart06NetworkConnectionsYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart06NetworkConnectionsResultsCount
                                Computer     = $AutoChart06NetworkConnectionsComputer 
                            }
                            $script:AutoChart06NetworkConnectionsOverallDataResults += $AutoChart06NetworkConnectionsYDataResults
                            $AutoChart06NetworkConnectionsYResults     = @()
                            $AutoChart06NetworkConnectionsResultsCount = 0
                            $AutoChart06NetworkConnectionsComputer     = @()
                            if ( $AutoChart06NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart06NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart06NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart06NetworkConnectionsComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart06NetworkConnectionsYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart06NetworkConnectionsResultsCount ; Computer = $AutoChart06NetworkConnectionsComputer }    
                $script:AutoChart06NetworkConnectionsOverallDataResults += $AutoChart06NetworkConnectionsYDataResults
                $script:AutoChart06NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06NetworkConnectionsOverallDataResults.count))
                $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart06NetworkConnectionsTitle.Text = "IPs (DHCP) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart06NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsOptionsButton
$script:AutoChart06NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart06NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart06NetworkConnections.Controls.Add($script:AutoChart06NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart06NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart06NetworkConnections.Controls.Remove($script:AutoChart06NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06NetworkConnections)

$script:AutoChart06NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart06NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06NetworkConnectionsOverallDataResults.count))
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart06NetworkConnectionsOverallDataResults.count)
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart06NetworkConnectionsOverallDataResults.count) - $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart06NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06NetworkConnectionsOverallDataResults.count) - $script:AutoChart06NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart06NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart06NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart06NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].ChartType = $script:AutoChart06NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
#    $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06NetworkConnectionsChartTypesAvailable) { $script:AutoChart06NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart06NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnections3DToggleButton
$script:AutoChart06NetworkConnections3DInclination = 0
$script:AutoChart06NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart06NetworkConnections3DInclination += 10
    if ( $script:AutoChart06NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart06NetworkConnections3DInclination
        $script:AutoChart06NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart06NetworkConnections3DInclination)"
#        $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart06NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart06NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart06NetworkConnections3DInclination
        $script:AutoChart06NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart06NetworkConnections3DInclination)" 
#        $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart06NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart06NetworkConnections3DInclination = 0
        $script:AutoChart06NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart06NetworkConnections3DInclination
        $script:AutoChart06NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart06NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06NetworkConnections3DToggleButton.Location.X + $script:AutoChart06NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06NetworkConnectionsColorsAvailable) { $script:AutoChart06NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Color = $script:AutoChart06NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnectionsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06NetworkConnectionsImportCsvPosResults) { $script:AutoChart06NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart06NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart06NetworkConnectionsImportCsvPosResults) { $script:AutoChart06NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06NetworkConnectionsImportCsvNegResults) { $script:AutoChart06NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart06NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsCheckDiffButton
$script:AutoChart06NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart06NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart06NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06NetworkConnections }})
    $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06NetworkConnections }})
    $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart06NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart06NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart06NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart06NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart06NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart06NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart06NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart06NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart06NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart06NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart06NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart06NetworkConnectionsCheckDiffButton)


$AutoChart06NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart06NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (DHCP) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart06NetworkConnectionsExpandChartButton
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($AutoChart06NetworkConnectionsExpandChartButton)


$script:AutoChart06NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart06NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart06NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsOpenInShell
$script:AutoChart06NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart06NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart06NetworkConnectionsOpenInShell)


$script:AutoChart06NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06NetworkConnectionsOpenInShell.Location.X + $script:AutoChart06NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsViewResults
$script:AutoChart06NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart06NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart06NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart06NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart06NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart06NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06NetworkConnections -Title $script:AutoChart06NetworkConnectionsTitle
})
$script:AutoChart06NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart06NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart06NetworkConnectionsSaveButton.Location.Y + $script:AutoChart06NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart06NetworkConnectionsNoticeTextbox)

$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.Clear()
$script:AutoChart06NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06NetworkConnections.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}





















##############################################################################################
# AutoChart07NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05NetworkConnections.Location.X
                  Y = $script:AutoChart05NetworkConnections.Location.Y + $script:AutoChart05NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart07NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart07NetworkConnections.Titles.Add($script:AutoChart07NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart07NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart07NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart07NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart07NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart07NetworkConnections.ChartAreas.Add($script:AutoChart07NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07NetworkConnections.Series.Add("IPs (Well Known) Per Host")  
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Enabled           = $True
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].BorderWidth       = 1
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].IsVisibleInLegend = $false
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Legend            = 'Legend'
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].ChartType         = 'Column'
$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Color             = 'SlateBLue'

        function Generate-AutoChart07NetworkConnections {
            $script:AutoChart07NetworkConnectionsCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart07NetworkConnectionsUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart07NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart07NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart07NetworkConnectionsTitle.Text = "IPs (Well Known) Per Host"

                $AutoChart07NetworkConnectionsCurrentComputer  = ''
                $AutoChart07NetworkConnectionsCheckIfFirstLine = $false
                $AutoChart07NetworkConnectionsResultsCount     = 0
                $AutoChart07NetworkConnectionsComputer         = @()
                $AutoChart07NetworkConnectionsYResults         = @()
                $script:AutoChart07NetworkConnectionsOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'WellKnown'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart07NetworkConnectionsCheckIfFirstLine -eq $false ) { $AutoChart07NetworkConnectionsCurrentComputer  = $Line.PSComputerName ; $AutoChart07NetworkConnectionsCheckIfFirstLine = $true }
                    if ( $AutoChart07NetworkConnectionsCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart07NetworkConnectionsCurrentComputer ) {
                            if ( $AutoChart07NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart07NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart07NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart07NetworkConnectionsComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart07NetworkConnectionsCurrentComputer ) { 
                            $AutoChart07NetworkConnectionsCurrentComputer = $Line.PSComputerName
                            $AutoChart07NetworkConnectionsYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart07NetworkConnectionsResultsCount
                                Computer     = $AutoChart07NetworkConnectionsComputer 
                            }
                            $script:AutoChart07NetworkConnectionsOverallDataResults += $AutoChart07NetworkConnectionsYDataResults
                            $AutoChart07NetworkConnectionsYResults     = @()
                            $AutoChart07NetworkConnectionsResultsCount = 0
                            $AutoChart07NetworkConnectionsComputer     = @()
                            if ( $AutoChart07NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart07NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart07NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart07NetworkConnectionsComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart07NetworkConnectionsYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart07NetworkConnectionsResultsCount ; Computer = $AutoChart07NetworkConnectionsComputer }    
                $script:AutoChart07NetworkConnectionsOverallDataResults += $AutoChart07NetworkConnectionsYDataResults
                $script:AutoChart07NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07NetworkConnectionsOverallDataResults.count))
                $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart07NetworkConnectionsTitle.Text = "IPs (Well Known) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart07NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart07NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsOptionsButton
$script:AutoChart07NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart07NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart07NetworkConnections.Controls.Add($script:AutoChart07NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart07NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart07NetworkConnections.Controls.Remove($script:AutoChart07NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07NetworkConnections)

$script:AutoChart07NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart07NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07NetworkConnectionsOverallDataResults.count))
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart07NetworkConnectionsOverallDataResults.count)
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart07NetworkConnectionsOverallDataResults.count) - $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart07NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07NetworkConnectionsOverallDataResults.count) - $script:AutoChart07NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart07NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart07NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart07NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].ChartType = $script:AutoChart07NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
#    $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart07NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07NetworkConnectionsChartTypesAvailable) { $script:AutoChart07NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart07NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnections3DToggleButton
$script:AutoChart07NetworkConnections3DInclination = 0
$script:AutoChart07NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart07NetworkConnections3DInclination += 10
    if ( $script:AutoChart07NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart07NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart07NetworkConnections3DInclination
        $script:AutoChart07NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart07NetworkConnections3DInclination)"
#        $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart07NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart07NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart07NetworkConnections3DInclination
        $script:AutoChart07NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart07NetworkConnections3DInclination)" 
#        $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart07NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart07NetworkConnections3DInclination = 0
        $script:AutoChart07NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart07NetworkConnections3DInclination
        $script:AutoChart07NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart07NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07NetworkConnections3DToggleButton.Location.X + $script:AutoChart07NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07NetworkConnectionsColorsAvailable) { $script:AutoChart07NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Color = $script:AutoChart07NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnectionsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart07NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart07NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07NetworkConnectionsImportCsvPosResults) { $script:AutoChart07NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart07NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart07NetworkConnectionsImportCsvPosResults) { $script:AutoChart07NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07NetworkConnectionsImportCsvNegResults) { $script:AutoChart07NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart07NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsCheckDiffButton
$script:AutoChart07NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart07NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart07NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07NetworkConnections }})
    $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07NetworkConnections }})
    $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart07NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart07NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart07NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart07NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart07NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart07NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart07NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart07NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart07NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart07NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart07NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart07NetworkConnectionsCheckDiffButton)


$AutoChart07NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart07NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Well Known) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart07NetworkConnectionsExpandChartButton
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($AutoChart07NetworkConnectionsExpandChartButton)


$script:AutoChart07NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart07NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart07NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsOpenInShell
$script:AutoChart07NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart07NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart07NetworkConnectionsOpenInShell)


$script:AutoChart07NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07NetworkConnectionsOpenInShell.Location.X + $script:AutoChart07NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsViewResults
$script:AutoChart07NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart07NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart07NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart07NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart07NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart07NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07NetworkConnections -Title $script:AutoChart07NetworkConnectionsTitle
})
$script:AutoChart07NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart07NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart07NetworkConnectionsSaveButton.Location.Y + $script:AutoChart07NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart07NetworkConnectionsNoticeTextbox)

$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.Clear()
$script:AutoChart07NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07NetworkConnections.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}


























##############################################################################################
# AutoChart08NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06NetworkConnections.Location.X
                  Y = $script:AutoChart06NetworkConnections.Location.Y + $script:AutoChart06NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart08NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart08NetworkConnections.Titles.Add($script:AutoChart08NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart08NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart08NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart08NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart08NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart08NetworkConnections.ChartAreas.Add($script:AutoChart08NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08NetworkConnections.Series.Add("IPs (Router Advertisement) Per Host")  
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Enabled           = $True
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].BorderWidth       = 1
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].IsVisibleInLegend = $false
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Legend            = 'Legend'
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].ChartType         = 'Column'
$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Color             = 'Purple'

        function Generate-AutoChart08NetworkConnections {
            $script:AutoChart08NetworkConnectionsCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart08NetworkConnectionsUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart08NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart08NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart08NetworkConnectionsTitle.Text = "IPs (Router Advertisement) Per Host"

                $AutoChart08NetworkConnectionsCurrentComputer  = ''
                $AutoChart08NetworkConnectionsCheckIfFirstLine = $false
                $AutoChart08NetworkConnectionsResultsCount     = 0
                $AutoChart08NetworkConnectionsComputer         = @()
                $AutoChart08NetworkConnectionsYResults         = @()
                $script:AutoChart08NetworkConnectionsOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'RouterAdvertisement'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart08NetworkConnectionsCheckIfFirstLine -eq $false ) { $AutoChart08NetworkConnectionsCurrentComputer  = $Line.PSComputerName ; $AutoChart08NetworkConnectionsCheckIfFirstLine = $true }
                    if ( $AutoChart08NetworkConnectionsCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart08NetworkConnectionsCurrentComputer ) {
                            if ( $AutoChart08NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart08NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart08NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart08NetworkConnectionsComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart08NetworkConnectionsCurrentComputer ) { 
                            $AutoChart08NetworkConnectionsCurrentComputer = $Line.PSComputerName
                            $AutoChart08NetworkConnectionsYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart08NetworkConnectionsResultsCount
                                Computer     = $AutoChart08NetworkConnectionsComputer 
                            }
                            $script:AutoChart08NetworkConnectionsOverallDataResults += $AutoChart08NetworkConnectionsYDataResults
                            $AutoChart08NetworkConnectionsYResults     = @()
                            $AutoChart08NetworkConnectionsResultsCount = 0
                            $AutoChart08NetworkConnectionsComputer     = @()
                            if ( $AutoChart08NetworkConnectionsYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08NetworkConnectionsYResults += $Line.IPAddress ; $AutoChart08NetworkConnectionsResultsCount += 1 }
                                if ( $AutoChart08NetworkConnectionsComputer -notcontains $Line.PSComputerName ) { $AutoChart08NetworkConnectionsComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart08NetworkConnectionsYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart08NetworkConnectionsResultsCount ; Computer = $AutoChart08NetworkConnectionsComputer }    
                $script:AutoChart08NetworkConnectionsOverallDataResults += $AutoChart08NetworkConnectionsYDataResults
                $script:AutoChart08NetworkConnectionsOverallDataResults | ForEach-Object { $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08NetworkConnectionsOverallDataResults.count))
                $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart08NetworkConnectionsTitle.Text = "IPs (Router Advertisement) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart08NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart08NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsOptionsButton
$script:AutoChart08NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart08NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart08NetworkConnections.Controls.Add($script:AutoChart08NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart08NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart08NetworkConnections.Controls.Remove($script:AutoChart08NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08NetworkConnections)

$script:AutoChart08NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart08NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08NetworkConnectionsOverallDataResults.count))
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart08NetworkConnectionsOverallDataResults.count)
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart08NetworkConnectionsOverallDataResults.count) - $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart08NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08NetworkConnectionsOverallDataResults.count) - $script:AutoChart08NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart08NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart08NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart08NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].ChartType = $script:AutoChart08NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#    $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart08NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08NetworkConnectionsChartTypesAvailable) { $script:AutoChart08NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart08NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnections3DToggleButton
$script:AutoChart08NetworkConnections3DInclination = 0
$script:AutoChart08NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart08NetworkConnections3DInclination += 10
    if ( $script:AutoChart08NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart08NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart08NetworkConnections3DInclination
        $script:AutoChart08NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart08NetworkConnections3DInclination)"
#        $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart08NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart08NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart08NetworkConnections3DInclination
        $script:AutoChart08NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart08NetworkConnections3DInclination)" 
#        $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart08NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart08NetworkConnections3DInclination = 0
        $script:AutoChart08NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart08NetworkConnections3DInclination
        $script:AutoChart08NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart08NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08NetworkConnections3DToggleButton.Location.X + $script:AutoChart08NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08NetworkConnectionsColorsAvailable) { $script:AutoChart08NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Color = $script:AutoChart08NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnectionsChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart08NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart08NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08NetworkConnectionsImportCsvPosResults) { $script:AutoChart08NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart08NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart08NetworkConnectionsImportCsvPosResults) { $script:AutoChart08NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08NetworkConnectionsImportCsvNegResults) { $script:AutoChart08NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart08NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsCheckDiffButton
$script:AutoChart08NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart08NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart08NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08NetworkConnections }})
    $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08NetworkConnections }})
    $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart08NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart08NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart08NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart08NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart08NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart08NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart08NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart08NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart08NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart08NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart08NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart08NetworkConnectionsCheckDiffButton)


$AutoChart08NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart08NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Router Advertisement) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart08NetworkConnectionsExpandChartButton
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($AutoChart08NetworkConnectionsExpandChartButton)


$script:AutoChart08NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart08NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart08NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsOpenInShell
$script:AutoChart08NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart08NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart08NetworkConnectionsOpenInShell)


$script:AutoChart08NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08NetworkConnectionsOpenInShell.Location.X + $script:AutoChart08NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsViewResults
$script:AutoChart08NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart08NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart08NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart08NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart08NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart08NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08NetworkConnections -Title $script:AutoChart08NetworkConnectionsTitle
})
$script:AutoChart08NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart08NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart08NetworkConnectionsSaveButton.Location.Y + $script:AutoChart08NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart08NetworkConnectionsNoticeTextbox)

$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
$script:AutoChart08NetworkConnectionsOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08NetworkConnections.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}



























##############################################################################################
# AutoChart09NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07NetworkConnections.Location.X
                  Y = $script:AutoChart07NetworkConnections.Location.Y + $script:AutoChart07NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart09NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09NetworkConnections.Titles.Add($script:AutoChart09NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart09NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart09NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart09NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart09NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart09NetworkConnections.ChartAreas.Add($script:AutoChart09NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09NetworkConnections.Series.Add("Address State")  
$script:AutoChart09NetworkConnections.Series["Address State"].Enabled           = $True
$script:AutoChart09NetworkConnections.Series["Address State"].BorderWidth       = 1
$script:AutoChart09NetworkConnections.Series["Address State"].IsVisibleInLegend = $false
$script:AutoChart09NetworkConnections.Series["Address State"].Chartarea         = 'Chart Area'
$script:AutoChart09NetworkConnections.Series["Address State"].Legend            = 'Legend'
$script:AutoChart09NetworkConnections.Series["Address State"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09NetworkConnections.Series["Address State"]['PieLineColor']   = 'Black'
$script:AutoChart09NetworkConnections.Series["Address State"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09NetworkConnections.Series["Address State"].ChartType         = 'Column'
$script:AutoChart09NetworkConnections.Series["Address State"].Color             = 'Yellow'

        function Generate-AutoChart09NetworkConnections {
            $script:AutoChart09NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart09NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' | Sort-Object -Property 'AddressState' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()

            if ($script:AutoChart09NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart09NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart09NetworkConnectionsTitle.Text = "Address State"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart09NetworkConnectionsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09NetworkConnectionsUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressState) -eq $DataField.AddressState) {
                            $Count += 1
                            if ( $script:AutoChart09NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart09NetworkConnectionsCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart09NetworkConnectionsUniqueCount = $script:AutoChart09NetworkConnectionsCsvComputers.Count
                    $script:AutoChart09NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09NetworkConnectionsUniqueCount
                        Computers   = $script:AutoChart09NetworkConnectionsCsvComputers 
                    }
                    $script:AutoChart09NetworkConnectionsOverallDataResults += $script:AutoChart09NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount) }

                $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09NetworkConnectionsOverallDataResults.count))
                $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart09NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart09NetworkConnectionsTitle.Text = "Address State`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart09NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart09NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsOptionsButton
$script:AutoChart09NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart09NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart09NetworkConnections.Controls.Add($script:AutoChart09NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart09NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart09NetworkConnections.Controls.Remove($script:AutoChart09NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09NetworkConnections)

$script:AutoChart09NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
        $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}    
    })
    $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart09NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09NetworkConnectionsOverallDataResults.count))
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart09NetworkConnectionsOverallDataResults.count)
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart09NetworkConnectionsOverallDataResults.count) - $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart09NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09NetworkConnectionsOverallDataResults.count) - $script:AutoChart09NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
        $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    })
$script:AutoChart09NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart09NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart09NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09NetworkConnections.Series["Address State"].ChartType = $script:AutoChart09NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
#    $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
})
$script:AutoChart09NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09NetworkConnectionsChartTypesAvailable) { $script:AutoChart09NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart09NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnections3DToggleButton
$script:AutoChart09NetworkConnections3DInclination = 0
$script:AutoChart09NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart09NetworkConnections3DInclination += 10
    if ( $script:AutoChart09NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart09NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart09NetworkConnections3DInclination
        $script:AutoChart09NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart09NetworkConnections3DInclination)"
#        $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart09NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart09NetworkConnections3DInclination
        $script:AutoChart09NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart09NetworkConnections3DInclination)" 
#        $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart09NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart09NetworkConnections3DInclination = 0
        $script:AutoChart09NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart09NetworkConnections3DInclination
        $script:AutoChart09NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
#        $script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
})
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart09NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09NetworkConnections3DToggleButton.Location.X + $script:AutoChart09NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09NetworkConnectionsColorsAvailable) { $script:AutoChart09NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09NetworkConnections.Series["Address State"].Color = $script:AutoChart09NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart09NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressState' -eq $($script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart09NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09NetworkConnectionsImportCsvPosResults) { $script:AutoChart09NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart09NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart09NetworkConnectionsImportCsvPosResults) { $script:AutoChart09NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09NetworkConnectionsImportCsvNegResults) { $script:AutoChart09NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart09NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsCheckDiffButton
$script:AutoChart09NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart09NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' -ExpandProperty 'AddressState' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart09NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09NetworkConnections }})
    $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09NetworkConnections }})
    $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart09NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart09NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart09NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart09NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart09NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart09NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart09NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart09NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart09NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart09NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart09NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart09NetworkConnectionsCheckDiffButton)
    

$AutoChart09NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart09NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address States" -PropertyX "AddressState" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart09NetworkConnectionsExpandChartButton
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($AutoChart09NetworkConnectionsExpandChartButton)


$script:AutoChart09NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart09NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart09NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsOpenInShell
$script:AutoChart09NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart09NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart09NetworkConnectionsOpenInShell)


$script:AutoChart09NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09NetworkConnectionsOpenInShell.Location.X + $script:AutoChart09NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsViewResults
$script:AutoChart09NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart09NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart09NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart09NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart09NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart09NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09NetworkConnections -Title $script:AutoChart09NetworkConnectionsTitle
})
$script:AutoChart09NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart09NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart09NetworkConnectionsSaveButton.Location.Y + $script:AutoChart09NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart09NetworkConnectionsNoticeTextbox)

$script:AutoChart09NetworkConnections.Series["Address State"].Points.Clear()
$script:AutoChart09NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09NetworkConnections.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}    






















##############################################################################################
# AutoChart10NetworkConnections
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10NetworkConnections = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08NetworkConnections.Location.X
                  Y = $script:AutoChart08NetworkConnections.Location.Y + $script:AutoChart08NetworkConnections.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10NetworkConnections.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart10NetworkConnectionsTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10NetworkConnections.Titles.Add($script:AutoChart10NetworkConnectionsTitle)

### Create Charts Area
$script:AutoChart10NetworkConnectionsArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10NetworkConnectionsArea.Name        = 'Chart Area'
$script:AutoChart10NetworkConnectionsArea.AxisX.Title = 'Hosts'
$script:AutoChart10NetworkConnectionsArea.AxisX.Interval          = 1
$script:AutoChart10NetworkConnectionsArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10NetworkConnectionsArea.Area3DStyle.Inclination = 75
$script:AutoChart10NetworkConnections.ChartAreas.Add($script:AutoChart10NetworkConnectionsArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10NetworkConnections.Series.Add("Address Family")  
$script:AutoChart10NetworkConnections.Series["Address Family"].Enabled           = $True
$script:AutoChart10NetworkConnections.Series["Address Family"].BorderWidth       = 1
$script:AutoChart10NetworkConnections.Series["Address Family"].IsVisibleInLegend = $false
$script:AutoChart10NetworkConnections.Series["Address Family"].Chartarea         = 'Chart Area'
$script:AutoChart10NetworkConnections.Series["Address Family"].Legend            = 'Legend'
$script:AutoChart10NetworkConnections.Series["Address Family"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10NetworkConnections.Series["Address Family"]['PieLineColor']   = 'Black'
$script:AutoChart10NetworkConnections.Series["Address Family"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10NetworkConnections.Series["Address Family"].ChartType         = 'Column'
$script:AutoChart10NetworkConnections.Series["Address Family"].Color             = 'Red'

        function Generate-AutoChart10NetworkConnections {
            $script:AutoChart10NetworkConnectionsCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart10NetworkConnectionsUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' | Sort-Object -Property 'AddressFamily' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10NetworkConnectionsUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()

            if ($script:AutoChart10NetworkConnectionsUniqueDataFields.count -gt 0){
                $script:AutoChart10NetworkConnectionsTitle.ForeColor = 'Black'
                $script:AutoChart10NetworkConnectionsTitle.Text = "Address Family"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart10NetworkConnectionsOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10NetworkConnectionsUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10NetworkConnectionsCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressFamily) -eq $DataField.AddressFamily) {
                            $Count += 1
                            if ( $script:AutoChart10NetworkConnectionsCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart10NetworkConnectionsCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart10NetworkConnectionsUniqueCount = $script:AutoChart10NetworkConnectionsCsvComputers.Count
                    $script:AutoChart10NetworkConnectionsDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10NetworkConnectionsUniqueCount
                        Computers   = $script:AutoChart10NetworkConnectionsCsvComputers 
                    }
                    $script:AutoChart10NetworkConnectionsOverallDataResults += $script:AutoChart10NetworkConnectionsDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount) }

                $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10NetworkConnectionsOverallDataResults.count))
                $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10NetworkConnectionsOverallDataResults.count))
            }
            else {
                $script:AutoChart10NetworkConnectionsTitle.ForeColor = 'Red'
                $script:AutoChart10NetworkConnectionsTitle.Text = "Address Family`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart10NetworkConnections

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart10NetworkConnectionsOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10NetworkConnections.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkConnections.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsOptionsButton
$script:AutoChart10NetworkConnectionsOptionsButton.Add_Click({  
    if ($script:AutoChart10NetworkConnectionsOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10NetworkConnectionsOptionsButton.Text = 'Options ^'
        $script:AutoChart10NetworkConnections.Controls.Add($script:AutoChart10NetworkConnectionsManipulationPanel)
    }
    elseif ($script:AutoChart10NetworkConnectionsOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10NetworkConnectionsOptionsButton.Text = 'Options v'
        $script:AutoChart10NetworkConnections.Controls.Remove($script:AutoChart10NetworkConnectionsManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10NetworkConnectionsOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10NetworkConnections)

$script:AutoChart10NetworkConnectionsManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10NetworkConnections.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10NetworkConnections.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10NetworkConnectionsTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10NetworkConnectionsOverallDataResults.count))                
    $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue = $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar.Value
        $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar.Value)"
        $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
        $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}    
    })
    $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Controls.Add($script:AutoChart10NetworkConnectionsTrimOffFirstTrackBar)
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10NetworkConnectionsTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Location.X + $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10NetworkConnectionsOverallDataResults.count))
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.Value         = $($script:AutoChart10NetworkConnectionsOverallDataResults.count)
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue   = 0
    $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue = $($script:AutoChart10NetworkConnectionsOverallDataResults.count) - $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.Value
        $script:AutoChart10NetworkConnectionsTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10NetworkConnectionsOverallDataResults.count) - $script:AutoChart10NetworkConnectionsTrimOffLastTrackBar.Value)"
        $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
        $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    })
$script:AutoChart10NetworkConnectionsTrimOffLastGroupBox.Controls.Add($script:AutoChart10NetworkConnectionsTrimOffLastTrackBar)
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnectionsTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10NetworkConnectionsChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Location.Y + $script:AutoChart10NetworkConnectionsTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10NetworkConnectionsChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10NetworkConnections.Series["Address Family"].ChartType = $script:AutoChart10NetworkConnectionsChartTypeComboBox.SelectedItem
#    $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
#    $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
})
$script:AutoChart10NetworkConnectionsChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10NetworkConnectionsChartTypesAvailable) { $script:AutoChart10NetworkConnectionsChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnectionsChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10NetworkConnections3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10NetworkConnectionsChartTypeComboBox.Location.X + $script:AutoChart10NetworkConnectionsChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10NetworkConnectionsChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnections3DToggleButton
$script:AutoChart10NetworkConnections3DInclination = 0
$script:AutoChart10NetworkConnections3DToggleButton.Add_Click({
    $script:AutoChart10NetworkConnections3DInclination += 10
    if ( $script:AutoChart10NetworkConnections3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart10NetworkConnectionsArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart10NetworkConnections3DInclination
        $script:AutoChart10NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart10NetworkConnections3DInclination)"
#        $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10NetworkConnections3DInclination -le 90 ) {
        $script:AutoChart10NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart10NetworkConnections3DInclination
        $script:AutoChart10NetworkConnections3DToggleButton.Text  = "3D On ($script:AutoChart10NetworkConnections3DInclination)" 
#        $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart10NetworkConnections3DToggleButton.Text  = "3D Off" 
        $script:AutoChart10NetworkConnections3DInclination = 0
        $script:AutoChart10NetworkConnectionsArea.Area3DStyle.Inclination = $script:AutoChart10NetworkConnections3DInclination
        $script:AutoChart10NetworkConnectionsArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
#        $script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
})
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnections3DToggleButton)

### Change the color of the chart
$script:AutoChart10NetworkConnectionsChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10NetworkConnections3DToggleButton.Location.X + $script:AutoChart10NetworkConnections3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkConnections3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10NetworkConnectionsColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10NetworkConnectionsColorsAvailable) { $script:AutoChart10NetworkConnectionsChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10NetworkConnectionsChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10NetworkConnections.Series["Address Family"].Color = $script:AutoChart10NetworkConnectionsChangeColorComboBox.SelectedItem
})
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnectionsChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10NetworkConnections {    
    # List of Positive Endpoints that positively match
    $script:AutoChart10NetworkConnectionsImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressFamily' -eq $($script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart10NetworkConnectionsInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10NetworkConnectionsImportCsvPosResults) { $script:AutoChart10NetworkConnectionsInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10NetworkConnectionsImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart10NetworkConnectionsImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10NetworkConnectionsImportCsvAll) { if ($Endpoint -notin $script:AutoChart10NetworkConnectionsImportCsvPosResults) { $script:AutoChart10NetworkConnectionsImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10NetworkConnectionsInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10NetworkConnectionsImportCsvNegResults) { $script:AutoChart10NetworkConnectionsInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10NetworkConnectionsImportCsvPosResults.count))"
    $script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10NetworkConnectionsImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10NetworkConnectionsCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10NetworkConnectionsTrimOffLastGroupBox.Location.X + $script:AutoChart10NetworkConnectionsTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkConnectionsTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsCheckDiffButton
$script:AutoChart10NetworkConnectionsCheckDiffButton.Add_Click({
    $script:AutoChart10NetworkConnectionsInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' -ExpandProperty 'AddressFamily' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10NetworkConnectionsInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10NetworkConnectionsInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffDropDownLabel.Location.y + $script:AutoChart10NetworkConnectionsInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10NetworkConnectionsInvestDiffDropDownArray) { $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10NetworkConnections }})
    $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10NetworkConnections })

    ### Investigate Difference Execute Button
    $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Location.y + $script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton
    $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10NetworkConnections }})
    $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10NetworkConnections })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton.Location.y + $script:AutoChart10NetworkConnectionsInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart10NetworkConnectionsInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Location.y + $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Location.x + $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10NetworkConnectionsInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel.Location.y + $script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10NetworkConnectionsInvestDiffForm.Controls.AddRange(@($script:AutoChart10NetworkConnectionsInvestDiffDropDownLabel,$script:AutoChart10NetworkConnectionsInvestDiffDropDownComboBox,$script:AutoChart10NetworkConnectionsInvestDiffExecuteButton,$script:AutoChart10NetworkConnectionsInvestDiffPosResultsLabel,$script:AutoChart10NetworkConnectionsInvestDiffPosResultsTextBox,$script:AutoChart10NetworkConnectionsInvestDiffNegResultsLabel,$script:AutoChart10NetworkConnectionsInvestDiffNegResultsTextBox))
    $script:AutoChart10NetworkConnectionsInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10NetworkConnectionsInvestDiffForm.ShowDialog()
})
$script:AutoChart10NetworkConnectionsCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart10NetworkConnectionsCheckDiffButton)
    

$AutoChart10NetworkConnectionsExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10NetworkConnectionsCheckDiffButton.Location.X + $script:AutoChart10NetworkConnectionsCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10NetworkConnectionsCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address Family" -PropertyX "AddressFamily" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart10NetworkConnectionsExpandChartButton
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($AutoChart10NetworkConnectionsExpandChartButton)


$script:AutoChart10NetworkConnectionsOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10NetworkConnectionsCheckDiffButton.Location.X
                   Y = $script:AutoChart10NetworkConnectionsCheckDiffButton.Location.Y + $script:AutoChart10NetworkConnectionsCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsOpenInShell
$script:AutoChart10NetworkConnectionsOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart10NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart10NetworkConnectionsOpenInShell)


$script:AutoChart10NetworkConnectionsViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10NetworkConnectionsOpenInShell.Location.X + $script:AutoChart10NetworkConnectionsOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10NetworkConnectionsOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsViewResults
$script:AutoChart10NetworkConnectionsViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart10NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart10NetworkConnectionsViewResults)


### Save the chart to file
$script:AutoChart10NetworkConnectionsSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10NetworkConnectionsOpenInShell.Location.X
                  Y = $script:AutoChart10NetworkConnectionsOpenInShell.Location.Y + $script:AutoChart10NetworkConnectionsOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10NetworkConnectionsSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10NetworkConnectionsSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10NetworkConnections -Title $script:AutoChart10NetworkConnectionsTitle
})
$script:AutoChart10NetworkConnectionsManipulationPanel.controls.Add($script:AutoChart10NetworkConnectionsSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10NetworkConnectionsNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10NetworkConnectionsSaveButton.Location.X 
                        Y = $script:AutoChart10NetworkConnectionsSaveButton.Location.Y + $script:AutoChart10NetworkConnectionsSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10NetworkConnectionsCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10NetworkConnectionsManipulationPanel.Controls.Add($script:AutoChart10NetworkConnectionsNoticeTextbox)

$script:AutoChart10NetworkConnections.Series["Address Family"].Points.Clear()
$script:AutoChart10NetworkConnectionsOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10NetworkConnectionsTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10NetworkConnectionsTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10NetworkConnections.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}    
#>



