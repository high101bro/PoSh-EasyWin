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

$script:AutoChart01ApplicationCrashesCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Network Connections' -or $CSVFile -match 'NetworkConnections') { $script:AutoChart01ApplicationCrashesCSVFileMatch += $CSVFile } }
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
    $script:AutoChart03ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart03ApplicationCrashes.Controls.Remove($script:AutoChart03ApplicationCrashesManipulationPanel)
    $script:AutoChart04ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart04ApplicationCrashes.Controls.Remove($script:AutoChart04ApplicationCrashesManipulationPanel)
    $script:AutoChart05ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart05ApplicationCrashes.Controls.Remove($script:AutoChart05ApplicationCrashesManipulationPanel)
    $script:AutoChart06ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart06ApplicationCrashes.Controls.Remove($script:AutoChart06ApplicationCrashesManipulationPanel)
    $script:AutoChart07ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart07ApplicationCrashes.Controls.Remove($script:AutoChart07ApplicationCrashesManipulationPanel)
    $script:AutoChart08ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart08ApplicationCrashes.Controls.Remove($script:AutoChart08ApplicationCrashesManipulationPanel)
    $script:AutoChart09ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart09ApplicationCrashes.Controls.Remove($script:AutoChart09ApplicationCrashesManipulationPanel)
    $script:AutoChart10ApplicationCrashesOptionsButton.Text = 'Options v'
    $script:AutoChart10ApplicationCrashes.Controls.Remove($script:AutoChart10ApplicationCrashesManipulationPanel)
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
            [System.Windows.MessageBox]::Show('There are no endpoints available within the charts.','PoSh-ACME')
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
    Generate-AutoChart03ApplicationCrashes
    Generate-AutoChart04ApplicationCrashes
    Generate-AutoChart05ApplicationCrashes
    Generate-AutoChart06ApplicationCrashes
    Generate-AutoChart07ApplicationCrashes
    Generate-AutoChart08ApplicationCrashes
    Generate-AutoChart09ApplicationCrashes
    Generate-AutoChart10ApplicationCrashes
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
$script:AutoChart01ApplicationCrashes.Series["Application Name"].ChartType         = 'Column'
$script:AutoChart01ApplicationCrashes.Series["Application Name"].Color             = 'Red'

function Generate-AutoChart01ApplicationCrashes {
            $script:AutoChart01ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart01ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart01ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Select-Object -Property @{n='Application Name';e={$_.Message.split(':')[1].split(',')[0].trim() } } | Sort-Object -Unique

#            | Where-Object {$_.State -match 'Listen' -and $_.LocalAddress -notmatch ':'} `
#            | ForEach-Object {
#                if ($_.LocalAddress -eq '0.0.0.0' -or $_.LocalAddress -match "127.[\d]{1,3}.[\d]{1,3}.[\d]{1,3}"){
#                    $_ | Select-Object @{n='Message';e={$_.LocalAddress + ':' + $_.LocalPort}}
#                }
#                else {
#                    $_ | Select-Object @{n="Message";e={($_.LocalAddress.split('.')[0..2] -join '.') + '.x:' + $_.LocalPort}}
#                }
#            }
#            $script:AutoChart01ApplicationCrashesUniqueDataFields = $script:AutoChart01ApplicationCrashesUniqueDataFields `
#            | Select-Object -Property 'Message' | Sort-Object {[string]$_.Message} -Unique
            
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()

            if ($script:AutoChart01ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart01ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart01ApplicationCrashesTitle.Text = "Application Name"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart01ApplicationCrashesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ApplicationCrashesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart01ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ( 
                            ($Line.LocalAddress.split('.')[0..2] -join '.') -eq (($DataField.Message).split(':')[0].split('.')[0..2] -join '.') -and
                            $Line.LocalPort -eq (($DataField.Message).split(':')[1])
                            ) {
                            $Count += 1
                            if ( $script:AutoChart01ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01ApplicationCrashesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart01ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ApplicationCrashesCsvComputers.Count
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

                $script:AutoChart01ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount) }
                $script:AutoChart01ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))
                $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart01ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart01ApplicationCrashesTitle.Text = "Application Name`n
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
        $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount)}
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
        $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount)}
    })
$script:AutoChart01ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart01ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart01ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
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
    $script:AutoChart01ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Message' -eq $($script:AutoChart01ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
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
    $script:AutoChart01ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Message' -ExpandProperty 'Message' | Sort-Object -Unique

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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Application Name" -PropertyX "Message" -PropertyY "PSComputerName" }
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
    $script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount)}
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

#$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.Clear()
#$script:AutoChart01ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart01ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ApplicationCrashes.Series["Application Name"].Points.AddXY($_.DataField.Message,$_.UniqueCount)}























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
$script:AutoChart02ApplicationCrashes.Series.Add("Connections to Private Network Endpoints")
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Enabled           = $True
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].BorderWidth       = 1
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].IsVisibleInLegend = $false
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Chartarea         = 'Chart Area'
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Legend            = 'Legend'
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"]['PieLineColor']   = 'Black'
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].ChartType         = 'Column'
$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Color             = 'Blue'

function Generate-AutoChart02ApplicationCrashes {
            $script:AutoChart02ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart02ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $LocalNetworkArray = @(10,172.16,172.17,172.18,172.19,172.20,172.21,172.22,172.23,172.24,172.25,172.26,172.27,172.28,172.29,172.30,172.31,192.168)

            $script:AutoChart02ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Where-Object {$_.LocalAddress -notmatch ':' -and `
                (
                    $_.RemoteAddress                             -in $LocalNetworkArray -or
                    $_.RemoteAddress.split('.')[0]               -in $LocalNetworkArray -or
                   ($_.RemoteAddress.split('.')[0..1] -join '.') -in $LocalNetworkArray
                )
            }            

            $script:AutoChart02ApplicationCrashesUniqueDataFields = $script:AutoChart02ApplicationCrashesUniqueDataFields `
            | Select-Object 'RemoteAddress'  | Sort-Object -Property 'RemoteAddress' -Unique
            
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.Clear()

            if ($script:AutoChart02ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart02ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart02ApplicationCrashesTitle.Text = "Connections to Private Network Endpoints"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart02ApplicationCrashesOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02ApplicationCrashesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart02ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.RemoteAddress -eq $DataField.RemoteAddress) {
                            $Count += 1
                            if ( $script:AutoChart02ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart02ApplicationCrashesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart02ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02ApplicationCrashesCsvComputers.Count
                        Computers   = $script:AutoChart02ApplicationCrashesCsvComputers 
                    }           
                    $script:AutoChart02ApplicationCrashesOverallDataResults += $script:AutoChart02ApplicationCrashesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart02ApplicationCrashesSortButton.text = "View: Count"
                $script:AutoChart02ApplicationCrashesOverallDataResultsSortAlphaNum = $script:AutoChart02ApplicationCrashesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart02ApplicationCrashesOverallDataResultsSortCount    = $script:AutoChart02ApplicationCrashesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart02ApplicationCrashesOverallDataResults = $script:AutoChart02ApplicationCrashesOverallDataResultsSortAlphaNum

                $script:AutoChart02ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount) }
                $script:AutoChart02ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))
                $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart02ApplicationCrashesTitle.ForeColor = 'Blue'
                $script:AutoChart02ApplicationCrashesTitle.Text = "Connections to Private Network Endpoints`n
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
        $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.Clear()
        $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
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
        $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.Clear()
        $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
    })
$script:AutoChart02ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].ChartType = $script:AutoChart02ApplicationCrashesChartTypeComboBox.SelectedItem
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
    $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Color = $script:AutoChart02ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart02ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart02ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'RemoteAddress' -eq $($script:AutoChart02ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
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
    $script:AutoChart02ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'RemoteAddress' -ExpandProperty 'RemoteAddress' | Sort-Object -Unique

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
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Connections to Private Network Endpoints" -PropertyX "RemoteAddress" -PropertyY "PSComputerName" }
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
    $script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.Clear()
    $script:AutoChart02ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart02ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ApplicationCrashes.Series["Connections to Private Network Endpoints"].Points.AddXY($_.DataField.RemoteAddress,$_.UniqueCount)}
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























<#
##############################################################################################
# AutoChart03ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ApplicationCrashes.Location.X
                  Y = $script:AutoChart01ApplicationCrashes.Location.Y + $script:AutoChart01ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03ApplicationCrashes.Add_MouseHover({ Close-AllOptions })


### Auto Create Charts Title 
$script:AutoChart03ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03ApplicationCrashes.Titles.Add($script:AutoChart03ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart03ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart03ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart03ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart03ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart03ApplicationCrashes.ChartAreas.Add($script:AutoChart03ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03ApplicationCrashes.Series.Add("Duration in Minutes")
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Enabled           = $True
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].BorderWidth       = 1
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].IsVisibleInLegend = $false
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Chartarea         = 'Chart Area'
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Legend            = 'Legend'
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"]['PieLineColor']   = 'Black'
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].ChartType         = 'Column'
$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Color             = 'Red'

function Generate-AutoChart03ApplicationCrashes {
            $script:AutoChart03ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart03ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart03ApplicationCrashesUniqueDataFields = $script:AutoChartDataSourceCsv `
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
            $script:AutoChart03ApplicationCrashesUniqueDataFields | ogv
            
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.Clear()

            if ($script:AutoChart03ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart03ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart03ApplicationCrashesTitle.Text = "Duration in Minutes (DD:HH:MM)"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart03ApplicationCrashesOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ApplicationCrashesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart03ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.Duration -eq $DataField.Duration) {
                            $Count += 1
                            if ( $script:AutoChart03ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03ApplicationCrashesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart03ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ApplicationCrashesCsvComputers.Count
                        Computers   = $script:AutoChart03ApplicationCrashesCsvComputers 
                    }           
                    $script:AutoChart03ApplicationCrashesOverallDataResults += $script:AutoChart03ApplicationCrashesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart03ApplicationCrashesSortButton.text = "View: Count"
                $script:AutoChart03ApplicationCrashesOverallDataResultsSortAlphaNum = $script:AutoChart03ApplicationCrashesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart03ApplicationCrashesOverallDataResultsSortCount    = $script:AutoChart03ApplicationCrashesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart03ApplicationCrashesOverallDataResults = $script:AutoChart03ApplicationCrashesOverallDataResultsSortAlphaNum

                $script:AutoChart03ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount) }
                $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ApplicationCrashesOverallDataResults.count))
                $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart03ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart03ApplicationCrashesTitle.Text = "Duration in Minutes`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesOptionsButton
$script:AutoChart03ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart03ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart03ApplicationCrashes.Controls.Add($script:AutoChart03ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart03ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart03ApplicationCrashes.Controls.Remove($script:AutoChart03ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ApplicationCrashes)


$script:AutoChart03ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.Clear()
        $script:AutoChart03ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
    })
    $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ApplicationCrashesOverallDataResults.count))
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart03ApplicationCrashesOverallDataResults.count)
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart03ApplicationCrashesOverallDataResults.count) - $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart03ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ApplicationCrashesOverallDataResults.count) - $script:AutoChart03ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.Clear()
        $script:AutoChart03ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
    })
$script:AutoChart03ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart03ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].ChartType = $script:AutoChart03ApplicationCrashesChartTypeComboBox.SelectedItem
})
$script:AutoChart03ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ApplicationCrashesChartTypesAvailable) { $script:AutoChart03ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart03ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashes3DToggleButton
$script:AutoChart03ApplicationCrashes3DInclination = 0
$script:AutoChart03ApplicationCrashes3DToggleButton.Add_Click({
    
    $script:AutoChart03ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart03ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart03ApplicationCrashes3DInclination
        $script:AutoChart03ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart03ApplicationCrashes3DInclination)"
    }
    elseif ( $script:AutoChart03ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart03ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart03ApplicationCrashes3DInclination
        $script:AutoChart03ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart03ApplicationCrashes3DInclination)" 
    }
    else { 
        $script:AutoChart03ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart03ApplicationCrashes3DInclination = 0
        $script:AutoChart03ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart03ApplicationCrashes3DInclination
        $script:AutoChart03ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart03ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart03ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ApplicationCrashesColorsAvailable) { $script:AutoChart03ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Color = $script:AutoChart03ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Duration' -eq $($script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ApplicationCrashesImportCsvPosResults) { $script:AutoChart03ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart03ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ApplicationCrashesImportCsvPosResults) { $script:AutoChart03ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ApplicationCrashesImportCsvNegResults) { $script:AutoChart03ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart03ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesCheckDiffButton
$script:AutoChart03ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart03ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Duration' -ExpandProperty 'Duration' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart03ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ApplicationCrashes }})
    $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ApplicationCrashes }})
    $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart03ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart03ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart03ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart03ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart03ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart03ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart03ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart03ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart03ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart03ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart03ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart03ApplicationCrashesCheckDiffButton)


$AutoChart03ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart03ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Duration in Minutes" -PropertyX "Duration" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart03ApplicationCrashesExpandChartButton
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($AutoChart03ApplicationCrashesExpandChartButton)


$script:AutoChart03ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart03ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart03ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesOpenInShell
$script:AutoChart03ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart03ApplicationCrashesOpenInShell)


$script:AutoChart03ApplicationCrashesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart03ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart03ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart03ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesSortButton
$script:AutoChart03ApplicationCrashesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart03ApplicationCrashesOverallDataResults = $script:AutoChart03ApplicationCrashesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart03ApplicationCrashesOverallDataResults = $script:AutoChart03ApplicationCrashesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.Clear()
    $script:AutoChart03ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart03ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ApplicationCrashes.Series["Duration in Minutes"].Points.AddXY($_.DataField.Duration,$_.UniqueCount)}
})
$script:AutoChart03ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart03ApplicationCrashesSortButton)


$script:AutoChart03ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ApplicationCrashesOpenInShell.Location.X + $script:AutoChart03ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesViewResults
$script:AutoChart03ApplicationCrashesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart03ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart03ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart03ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ApplicationCrashesViewResults.Location.X
                  Y = $script:AutoChart03ApplicationCrashesViewResults.Location.Y + $script:AutoChart03ApplicationCrashesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03ApplicationCrashes -Title $script:AutoChart03ApplicationCrashesTitle
})
$script:AutoChart03ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart03ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ApplicationCrashesSortButton.Location.X 
                        Y = $script:AutoChart03ApplicationCrashesSortButton.Location.Y + $script:AutoChart03ApplicationCrashesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart03ApplicationCrashesNoticeTextbox)





























##############################################################################################
# AutoChart04ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02ApplicationCrashes.Location.X
                  Y = $script:AutoChart02ApplicationCrashes.Location.Y + $script:AutoChart02ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart04ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04ApplicationCrashes.Titles.Add($script:AutoChart04ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart04ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart04ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart04ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart04ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart04ApplicationCrashes.ChartAreas.Add($script:AutoChart04ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04ApplicationCrashes.Series.Add("Connections to Class C Networks")
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Enabled           = $True
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].BorderWidth       = 1
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].IsVisibleInLegend = $false
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Chartarea         = 'Chart Area'
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Legend            = 'Legend'
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"]['PieLineColor']   = 'Black'
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].ChartType         = 'Column'
$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Color             = 'Red'

function Generate-AutoChart04ApplicationCrashes {
            $script:AutoChart04ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            #$script:AutoChart04ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv| Select-Object -ExpandProperty 'LocalAddress' #| Sort-Object -Property 'LocalAddress' -Unique

            $script:AutoChart04ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv `
            | Where-Object {$_.LocalAddress -notmatch ':'} `
            | Select-Object @{n="ClassC";e={($_.RemoteAddress.split('.')[0..2] -join '.') + '.x'}} `
            | Sort-Object {[string]$_.ClassC} -Unique


            $script:AutoChart04ApplicationCrashesUniqueDataFields = $script:AutoChart04ApplicationCrashesUniqueDataFields `
            | Select-Object 'ClassC'  | Sort-Object -Property 'ClassC' -Unique
            
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.Clear()

            if ($script:AutoChart04ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart04ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart04ApplicationCrashesTitle.Text = "Connections to Class C Networks"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart04ApplicationCrashesOverallDataResults = @()
                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ApplicationCrashesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart04ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.ClassC -eq $DataField.ClassC) {
                            $Count += 1
                            if ( $script:AutoChart04ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04ApplicationCrashesCsvComputers += $($Line.PSComputerName) }
                        }
                    }
                    $script:AutoChart04ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ApplicationCrashesCsvComputers.Count
                        Computers   = $script:AutoChart04ApplicationCrashesCsvComputers 
                    }           
                    $script:AutoChart04ApplicationCrashesOverallDataResults += $script:AutoChart04ApplicationCrashesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }

                $script:AutoChart04ApplicationCrashesSortButton.text = "View: Count"
                $script:AutoChart04ApplicationCrashesOverallDataResultsSortAlphaNum = $script:AutoChart04ApplicationCrashesOverallDataResults | Sort-Object @{Expression='UniqueCount';Descending=$false}, @{Expression={[string]$_.DataField};Descending=$false}
                $script:AutoChart04ApplicationCrashesOverallDataResultsSortCount    = $script:AutoChart04ApplicationCrashesOverallDataResults | Sort-Object @{Expression={[string]$_.DataField};Descending=$false}, @{Expression='UniqueCount';Descending=$false}
                $script:AutoChart04ApplicationCrashesOverallDataResults = $script:AutoChart04ApplicationCrashesOverallDataResultsSortAlphaNum

                $script:AutoChart04ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount) }
                $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ApplicationCrashesOverallDataResults.count))
                $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart04ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart04ApplicationCrashesTitle.Text = "Connections to Class C Networks`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesOptionsButton
$script:AutoChart04ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart04ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart04ApplicationCrashes.Controls.Add($script:AutoChart04ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart04ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart04ApplicationCrashes.Controls.Remove($script:AutoChart04ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ApplicationCrashes)


$script:AutoChart04ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.Clear()
        $script:AutoChart04ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
    })
    $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ApplicationCrashesOverallDataResults.count))
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart04ApplicationCrashesOverallDataResults.count)
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart04ApplicationCrashesOverallDataResults.count) - $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart04ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ApplicationCrashesOverallDataResults.count) - $script:AutoChart04ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.Clear()
        $script:AutoChart04ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
    })
$script:AutoChart04ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart04ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].ChartType = $script:AutoChart04ApplicationCrashesChartTypeComboBox.SelectedItem
})
$script:AutoChart04ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ApplicationCrashesChartTypesAvailable) { $script:AutoChart04ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashesChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart04ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashes3DToggleButton
$script:AutoChart04ApplicationCrashes3DInclination = 0
$script:AutoChart04ApplicationCrashes3DToggleButton.Add_Click({
    
    $script:AutoChart04ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart04ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart04ApplicationCrashes3DInclination
        $script:AutoChart04ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart04ApplicationCrashes3DInclination)"
    }
    elseif ( $script:AutoChart04ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart04ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart04ApplicationCrashes3DInclination
        $script:AutoChart04ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart04ApplicationCrashes3DInclination)" 
    }
    else { 
        $script:AutoChart04ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart04ApplicationCrashes3DInclination = 0
        $script:AutoChart04ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart04ApplicationCrashes3DInclination
        $script:AutoChart04ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
    }
})
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart04ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart04ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ApplicationCrashesColorsAvailable) { $script:AutoChart04ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Color = $script:AutoChart04ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'ClassC' -eq $($script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ApplicationCrashesImportCsvPosResults) { $script:AutoChart04ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart04ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ApplicationCrashesImportCsvPosResults) { $script:AutoChart04ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ApplicationCrashesImportCsvNegResults) { $script:AutoChart04ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart04ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesCheckDiffButton
$script:AutoChart04ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart04ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'ClassC' -ExpandProperty 'ClassC' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart04ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ApplicationCrashes }})
    $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ApplicationCrashes }})
    $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart04ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart04ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart04ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart04ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart04ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart04ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart04ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart04ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart04ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart04ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart04ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart04ApplicationCrashesCheckDiffButton)


$AutoChart04ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart04ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Connections to Class C Networks" -PropertyX "ClassC" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart04ApplicationCrashesExpandChartButton
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($AutoChart04ApplicationCrashesExpandChartButton)


$script:AutoChart04ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart04ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart04ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesOpenInShell
$script:AutoChart04ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart04ApplicationCrashesOpenInShell)


$script:AutoChart04ApplicationCrashesSortButton = New-Object Windows.Forms.Button -Property @{
    Text     = "View: Count"
    Location = @{ X = $script:AutoChart04ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart04ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart04ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesSortButton
$script:AutoChart04ApplicationCrashesSortButton.Add_Click({
    if ($this.Text -eq "View: Count") {
        $script:AutoChart04ApplicationCrashesOverallDataResults = $script:AutoChart04ApplicationCrashesOverallDataResultsSortCount
        $this.Text = "View: AlphaNum"
    }
    elseif (($this.Text -eq "View: AlphaNum")) {
        $script:AutoChart04ApplicationCrashesOverallDataResults = $script:AutoChart04ApplicationCrashesOverallDataResultsSortAlphaNum
        $this.Text = "View: Count"
    }
    $script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.Clear()
    $script:AutoChart04ApplicationCrashesOverallDataResults | Select-Object -skip $script:AutoChart04ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ApplicationCrashes.Series["Connections to Class C Networks"].Points.AddXY($_.DataField.ClassC,$_.UniqueCount)}
})
$script:AutoChart04ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart04ApplicationCrashesSortButton)


$script:AutoChart04ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ApplicationCrashesOpenInShell.Location.X + $script:AutoChart04ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesViewResults
$script:AutoChart04ApplicationCrashesViewResults.Add_Click({
    $script:AutoChartDataSourceCsv | Out-GridView }) 
$script:AutoChart04ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart04ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart04ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ApplicationCrashesViewResults.Location.X
                  Y = $script:AutoChart04ApplicationCrashesViewResults.Location.Y + $script:AutoChart04ApplicationCrashesViewResults.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04ApplicationCrashes -Title $script:AutoChart04ApplicationCrashesTitle
})
$script:AutoChart04ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart04ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ApplicationCrashesSortButton.Location.X 
                        Y = $script:AutoChart04ApplicationCrashesSortButton.Location.Y + $script:AutoChart04ApplicationCrashesSortButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart04ApplicationCrashesNoticeTextbox)




























##############################################################################################
# AutoChart05ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03ApplicationCrashes.Location.X
                  Y = $script:AutoChart03ApplicationCrashes.Location.Y + $script:AutoChart03ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart05ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart05ApplicationCrashes.Titles.Add($script:AutoChart05ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart05ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart05ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart05ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart05ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart05ApplicationCrashes.ChartAreas.Add($script:AutoChart05ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05ApplicationCrashes.Series.Add("IPs (Manual) Per Host")  
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Enabled           = $True
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].BorderWidth       = 1
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].IsVisibleInLegend = $false
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Legend            = 'Legend'
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].ChartType         = 'Column'
$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Color             = 'Brown'

        function Generate-AutoChart05ApplicationCrashes {
            $script:AutoChart05ApplicationCrashesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart05ApplicationCrashesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart05ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart05ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart05ApplicationCrashesTitle.Text = "IPs (Manual) Per Host"

                $AutoChart05ApplicationCrashesCurrentComputer  = ''
                $AutoChart05ApplicationCrashesCheckIfFirstLine = $false
                $AutoChart05ApplicationCrashesResultsCount     = 0
                $AutoChart05ApplicationCrashesComputer         = @()
                $AutoChart05ApplicationCrashesYResults         = @()
                $script:AutoChart05ApplicationCrashesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'Manual'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart05ApplicationCrashesCheckIfFirstLine -eq $false ) { $AutoChart05ApplicationCrashesCurrentComputer  = $Line.PSComputerName ; $AutoChart05ApplicationCrashesCheckIfFirstLine = $true }
                    if ( $AutoChart05ApplicationCrashesCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart05ApplicationCrashesCurrentComputer ) {
                            if ( $AutoChart05ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart05ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart05ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart05ApplicationCrashesComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart05ApplicationCrashesCurrentComputer ) { 
                            $AutoChart05ApplicationCrashesCurrentComputer = $Line.PSComputerName
                            $AutoChart05ApplicationCrashesYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart05ApplicationCrashesResultsCount
                                Computer     = $AutoChart05ApplicationCrashesComputer 
                            }
                            $script:AutoChart05ApplicationCrashesOverallDataResults += $AutoChart05ApplicationCrashesYDataResults
                            $AutoChart05ApplicationCrashesYResults     = @()
                            $AutoChart05ApplicationCrashesResultsCount = 0
                            $AutoChart05ApplicationCrashesComputer     = @()
                            if ( $AutoChart05ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart05ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart05ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart05ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart05ApplicationCrashesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart05ApplicationCrashesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart05ApplicationCrashesResultsCount ; Computer = $AutoChart05ApplicationCrashesComputer }    
                $script:AutoChart05ApplicationCrashesOverallDataResults += $AutoChart05ApplicationCrashesYDataResults
                $script:AutoChart05ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ApplicationCrashesOverallDataResults.count))
                $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
                $script:AutoChart05ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart05ApplicationCrashesTitle.Text = "IPs (Manual) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart05ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesOptionsButton
$script:AutoChart05ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart05ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart05ApplicationCrashes.Controls.Add($script:AutoChart05ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart05ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart05ApplicationCrashes.Controls.Remove($script:AutoChart05ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ApplicationCrashes)

$script:AutoChart05ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ApplicationCrashesOverallDataResults.count))
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart05ApplicationCrashesOverallDataResults.count)
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart05ApplicationCrashesOverallDataResults.count) - $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart05ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ApplicationCrashesOverallDataResults.count) - $script:AutoChart05ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
        $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart05ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart05ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].ChartType = $script:AutoChart05ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
#    $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart05ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ApplicationCrashesChartTypesAvailable) { $script:AutoChart05ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart05ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashes3DToggleButton
$script:AutoChart05ApplicationCrashes3DInclination = 0
$script:AutoChart05ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart05ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart05ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart05ApplicationCrashes3DInclination
        $script:AutoChart05ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart05ApplicationCrashes3DInclination)"
#        $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart05ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart05ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart05ApplicationCrashes3DInclination
        $script:AutoChart05ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart05ApplicationCrashes3DInclination)" 
#        $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart05ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart05ApplicationCrashes3DInclination = 0
        $script:AutoChart05ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart05ApplicationCrashes3DInclination
        $script:AutoChart05ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
#        $script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart05ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart05ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ApplicationCrashesColorsAvailable) { $script:AutoChart05ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Color = $script:AutoChart05ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ApplicationCrashesImportCsvPosResults) { $script:AutoChart05ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart05ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ApplicationCrashesImportCsvPosResults) { $script:AutoChart05ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ApplicationCrashesImportCsvNegResults) { $script:AutoChart05ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart05ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesCheckDiffButton
$script:AutoChart05ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart05ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart05ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ApplicationCrashes }})
    $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ApplicationCrashes }})
    $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart05ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart05ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart05ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart05ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart05ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart05ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart05ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart05ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart05ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart05ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart05ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart05ApplicationCrashesCheckDiffButton)


$AutoChart05ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart05ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Manual) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart05ApplicationCrashesExpandChartButton
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($AutoChart05ApplicationCrashesExpandChartButton)


$script:AutoChart05ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart05ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart05ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesOpenInShell
$script:AutoChart05ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart05ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart05ApplicationCrashesOpenInShell)


$script:AutoChart05ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ApplicationCrashesOpenInShell.Location.X + $script:AutoChart05ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesViewResults
$script:AutoChart05ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart05ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart05ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart05ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart05ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart05ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05ApplicationCrashes -Title $script:AutoChart05ApplicationCrashesTitle
})
$script:AutoChart05ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart05ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart05ApplicationCrashesSaveButton.Location.Y + $script:AutoChart05ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart05ApplicationCrashesNoticeTextbox)

$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.Clear()
$script:AutoChart05ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart05ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ApplicationCrashes.Series["IPs (Manual) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

























##############################################################################################
# AutoChart06ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04ApplicationCrashes.Location.X
                  Y = $script:AutoChart04ApplicationCrashes.Location.Y + $script:AutoChart04ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart06ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06ApplicationCrashes.Titles.Add($script:AutoChart06ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart06ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart06ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart06ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart06ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart06ApplicationCrashes.ChartAreas.Add($script:AutoChart06ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06ApplicationCrashes.Series.Add("IPs (DHCP) Per Host")  
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Enabled           = $True
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].BorderWidth       = 1
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].IsVisibleInLegend = $false
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Legend            = 'Legend'
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].ChartType         = 'Column'
$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Color             = 'Gray'

        function Generate-AutoChart06ApplicationCrashes {
            $script:AutoChart06ApplicationCrashesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart06ApplicationCrashesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart06ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart06ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart06ApplicationCrashesTitle.Text = "IPs (DHCP) Per Host"

                $AutoChart06ApplicationCrashesCurrentComputer  = ''
                $AutoChart06ApplicationCrashesCheckIfFirstLine = $false
                $AutoChart06ApplicationCrashesResultsCount     = 0
                $AutoChart06ApplicationCrashesComputer         = @()
                $AutoChart06ApplicationCrashesYResults         = @()
                $script:AutoChart06ApplicationCrashesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'DHCP'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart06ApplicationCrashesCheckIfFirstLine -eq $false ) { $AutoChart06ApplicationCrashesCurrentComputer  = $Line.PSComputerName ; $AutoChart06ApplicationCrashesCheckIfFirstLine = $true }
                    if ( $AutoChart06ApplicationCrashesCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart06ApplicationCrashesCurrentComputer ) {
                            if ( $AutoChart06ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart06ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart06ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart06ApplicationCrashesComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart06ApplicationCrashesCurrentComputer ) { 
                            $AutoChart06ApplicationCrashesCurrentComputer = $Line.PSComputerName
                            $AutoChart06ApplicationCrashesYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart06ApplicationCrashesResultsCount
                                Computer     = $AutoChart06ApplicationCrashesComputer 
                            }
                            $script:AutoChart06ApplicationCrashesOverallDataResults += $AutoChart06ApplicationCrashesYDataResults
                            $AutoChart06ApplicationCrashesYResults     = @()
                            $AutoChart06ApplicationCrashesResultsCount = 0
                            $AutoChart06ApplicationCrashesComputer     = @()
                            if ( $AutoChart06ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart06ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart06ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart06ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart06ApplicationCrashesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart06ApplicationCrashesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart06ApplicationCrashesResultsCount ; Computer = $AutoChart06ApplicationCrashesComputer }    
                $script:AutoChart06ApplicationCrashesOverallDataResults += $AutoChart06ApplicationCrashesYDataResults
                $script:AutoChart06ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ApplicationCrashesOverallDataResults.count))
                $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
                $script:AutoChart06ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart06ApplicationCrashesTitle.Text = "IPs (DHCP) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart06ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesOptionsButton
$script:AutoChart06ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart06ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart06ApplicationCrashes.Controls.Add($script:AutoChart06ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart06ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart06ApplicationCrashes.Controls.Remove($script:AutoChart06ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ApplicationCrashes)

$script:AutoChart06ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ApplicationCrashesOverallDataResults.count))
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart06ApplicationCrashesOverallDataResults.count)
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart06ApplicationCrashesOverallDataResults.count) - $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart06ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ApplicationCrashesOverallDataResults.count) - $script:AutoChart06ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
        $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart06ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart06ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].ChartType = $script:AutoChart06ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
#    $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart06ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ApplicationCrashesChartTypesAvailable) { $script:AutoChart06ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart06ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashes3DToggleButton
$script:AutoChart06ApplicationCrashes3DInclination = 0
$script:AutoChart06ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart06ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart06ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart06ApplicationCrashes3DInclination
        $script:AutoChart06ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart06ApplicationCrashes3DInclination)"
#        $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart06ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart06ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart06ApplicationCrashes3DInclination
        $script:AutoChart06ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart06ApplicationCrashes3DInclination)" 
#        $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart06ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart06ApplicationCrashes3DInclination = 0
        $script:AutoChart06ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart06ApplicationCrashes3DInclination
        $script:AutoChart06ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
#        $script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart06ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart06ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ApplicationCrashesColorsAvailable) { $script:AutoChart06ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Color = $script:AutoChart06ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ApplicationCrashesImportCsvPosResults) { $script:AutoChart06ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart06ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ApplicationCrashesImportCsvPosResults) { $script:AutoChart06ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ApplicationCrashesImportCsvNegResults) { $script:AutoChart06ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart06ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesCheckDiffButton
$script:AutoChart06ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart06ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart06ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ApplicationCrashes }})
    $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ApplicationCrashes }})
    $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart06ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart06ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart06ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart06ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart06ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart06ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart06ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart06ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart06ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart06ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart06ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart06ApplicationCrashesCheckDiffButton)


$AutoChart06ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart06ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (DHCP) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart06ApplicationCrashesExpandChartButton
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($AutoChart06ApplicationCrashesExpandChartButton)


$script:AutoChart06ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart06ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart06ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesOpenInShell
$script:AutoChart06ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart06ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart06ApplicationCrashesOpenInShell)


$script:AutoChart06ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ApplicationCrashesOpenInShell.Location.X + $script:AutoChart06ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesViewResults
$script:AutoChart06ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart06ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart06ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart06ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart06ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart06ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06ApplicationCrashes -Title $script:AutoChart06ApplicationCrashesTitle
})
$script:AutoChart06ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart06ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart06ApplicationCrashesSaveButton.Location.Y + $script:AutoChart06ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart06ApplicationCrashesNoticeTextbox)

$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.Clear()
$script:AutoChart06ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart06ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ApplicationCrashes.Series["IPs (DHCP) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}





















##############################################################################################
# AutoChart07ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05ApplicationCrashes.Location.X
                  Y = $script:AutoChart05ApplicationCrashes.Location.Y + $script:AutoChart05ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart07ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart07ApplicationCrashes.Titles.Add($script:AutoChart07ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart07ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart07ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart07ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart07ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart07ApplicationCrashes.ChartAreas.Add($script:AutoChart07ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07ApplicationCrashes.Series.Add("IPs (Well Known) Per Host")  
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Enabled           = $True
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].BorderWidth       = 1
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].IsVisibleInLegend = $false
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Legend            = 'Legend'
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].ChartType         = 'Column'
$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Color             = 'SlateBLue'

        function Generate-AutoChart07ApplicationCrashes {
            $script:AutoChart07ApplicationCrashesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart07ApplicationCrashesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart07ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart07ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart07ApplicationCrashesTitle.Text = "IPs (Well Known) Per Host"

                $AutoChart07ApplicationCrashesCurrentComputer  = ''
                $AutoChart07ApplicationCrashesCheckIfFirstLine = $false
                $AutoChart07ApplicationCrashesResultsCount     = 0
                $AutoChart07ApplicationCrashesComputer         = @()
                $AutoChart07ApplicationCrashesYResults         = @()
                $script:AutoChart07ApplicationCrashesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'WellKnown'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart07ApplicationCrashesCheckIfFirstLine -eq $false ) { $AutoChart07ApplicationCrashesCurrentComputer  = $Line.PSComputerName ; $AutoChart07ApplicationCrashesCheckIfFirstLine = $true }
                    if ( $AutoChart07ApplicationCrashesCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart07ApplicationCrashesCurrentComputer ) {
                            if ( $AutoChart07ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart07ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart07ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart07ApplicationCrashesComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart07ApplicationCrashesCurrentComputer ) { 
                            $AutoChart07ApplicationCrashesCurrentComputer = $Line.PSComputerName
                            $AutoChart07ApplicationCrashesYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart07ApplicationCrashesResultsCount
                                Computer     = $AutoChart07ApplicationCrashesComputer 
                            }
                            $script:AutoChart07ApplicationCrashesOverallDataResults += $AutoChart07ApplicationCrashesYDataResults
                            $AutoChart07ApplicationCrashesYResults     = @()
                            $AutoChart07ApplicationCrashesResultsCount = 0
                            $AutoChart07ApplicationCrashesComputer     = @()
                            if ( $AutoChart07ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart07ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart07ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart07ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart07ApplicationCrashesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart07ApplicationCrashesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart07ApplicationCrashesResultsCount ; Computer = $AutoChart07ApplicationCrashesComputer }    
                $script:AutoChart07ApplicationCrashesOverallDataResults += $AutoChart07ApplicationCrashesYDataResults
                $script:AutoChart07ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ApplicationCrashesOverallDataResults.count))
                $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
                $script:AutoChart07ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart07ApplicationCrashesTitle.Text = "IPs (Well Known) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart07ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart07ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesOptionsButton
$script:AutoChart07ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart07ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart07ApplicationCrashes.Controls.Add($script:AutoChart07ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart07ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart07ApplicationCrashes.Controls.Remove($script:AutoChart07ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ApplicationCrashes)

$script:AutoChart07ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart07ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ApplicationCrashesOverallDataResults.count))
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart07ApplicationCrashesOverallDataResults.count)
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart07ApplicationCrashesOverallDataResults.count) - $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart07ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07ApplicationCrashesOverallDataResults.count) - $script:AutoChart07ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
        $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart07ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart07ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart07ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].ChartType = $script:AutoChart07ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
#    $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart07ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ApplicationCrashesChartTypesAvailable) { $script:AutoChart07ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart07ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashes3DToggleButton
$script:AutoChart07ApplicationCrashes3DInclination = 0
$script:AutoChart07ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart07ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart07ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart07ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart07ApplicationCrashes3DInclination
        $script:AutoChart07ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart07ApplicationCrashes3DInclination)"
#        $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart07ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart07ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart07ApplicationCrashes3DInclination
        $script:AutoChart07ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart07ApplicationCrashes3DInclination)" 
#        $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart07ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart07ApplicationCrashes3DInclination = 0
        $script:AutoChart07ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart07ApplicationCrashes3DInclination
        $script:AutoChart07ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
#        $script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart07ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart07ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ApplicationCrashesColorsAvailable) { $script:AutoChart07ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Color = $script:AutoChart07ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart07ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart07ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ApplicationCrashesImportCsvPosResults) { $script:AutoChart07ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart07ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart07ApplicationCrashesImportCsvPosResults) { $script:AutoChart07ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ApplicationCrashesImportCsvNegResults) { $script:AutoChart07ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart07ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesCheckDiffButton
$script:AutoChart07ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart07ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart07ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ApplicationCrashes }})
    $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ApplicationCrashes }})
    $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart07ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart07ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart07ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart07ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart07ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart07ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart07ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart07ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart07ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart07ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart07ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart07ApplicationCrashesCheckDiffButton)


$AutoChart07ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart07ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Well Known) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart07ApplicationCrashesExpandChartButton
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($AutoChart07ApplicationCrashesExpandChartButton)


$script:AutoChart07ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart07ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart07ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesOpenInShell
$script:AutoChart07ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart07ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart07ApplicationCrashesOpenInShell)


$script:AutoChart07ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07ApplicationCrashesOpenInShell.Location.X + $script:AutoChart07ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesViewResults
$script:AutoChart07ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart07ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart07ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart07ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart07ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart07ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07ApplicationCrashes -Title $script:AutoChart07ApplicationCrashesTitle
})
$script:AutoChart07ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart07ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart07ApplicationCrashesSaveButton.Location.Y + $script:AutoChart07ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart07ApplicationCrashesNoticeTextbox)

$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.Clear()
$script:AutoChart07ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart07ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ApplicationCrashes.Series["IPs (Well Known) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}


























##############################################################################################
# AutoChart08ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06ApplicationCrashes.Location.X
                  Y = $script:AutoChart06ApplicationCrashes.Location.Y + $script:AutoChart06ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart08ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart08ApplicationCrashes.Titles.Add($script:AutoChart08ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart08ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart08ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart08ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart08ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart08ApplicationCrashes.ChartAreas.Add($script:AutoChart08ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08ApplicationCrashes.Series.Add("IPs (Router Advertisement) Per Host")  
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Enabled           = $True
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].BorderWidth       = 1
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].IsVisibleInLegend = $false
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Chartarea         = 'Chart Area'
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Legend            = 'Legend'
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"]['PieLineColor']   = 'Black'
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].ChartType         = 'Column'
$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Color             = 'Purple'

        function Generate-AutoChart08ApplicationCrashes {
            $script:AutoChart08ApplicationCrashesCsvFileHosts     = ($script:AutoChartDataSourceCsv).PSComputerName | Sort-Object -Unique
            $script:AutoChart08ApplicationCrashesUniqueDataFields = ($script:AutoChartDataSourceCsv).IPAddress | Sort-Object -Property 'IPAddress'

            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            if ($script:AutoChart08ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart08ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart08ApplicationCrashesTitle.Text = "IPs (Router Advertisement) Per Host"

                $AutoChart08ApplicationCrashesCurrentComputer  = ''
                $AutoChart08ApplicationCrashesCheckIfFirstLine = $false
                $AutoChart08ApplicationCrashesResultsCount     = 0
                $AutoChart08ApplicationCrashesComputer         = @()
                $AutoChart08ApplicationCrashesYResults         = @()
                $script:AutoChart08ApplicationCrashesOverallDataResults = @()

                foreach ( $Line in $($script:AutoChartDataSourceCsv | Where-Object {$_.PrefixOrigin -eq 'RouterAdvertisement'} | Sort-Object PSComputerName) ) {
                    if ( $AutoChart08ApplicationCrashesCheckIfFirstLine -eq $false ) { $AutoChart08ApplicationCrashesCurrentComputer  = $Line.PSComputerName ; $AutoChart08ApplicationCrashesCheckIfFirstLine = $true }
                    if ( $AutoChart08ApplicationCrashesCheckIfFirstLine -eq $true ) { 
                        if ( $Line.PSComputerName -eq $AutoChart08ApplicationCrashesCurrentComputer ) {
                            if ( $AutoChart08ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart08ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart08ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart08ApplicationCrashesComputer = $Line.PSComputerName }
                            }       
                        }
                        elseif ( $Line.PSComputerName -ne $AutoChart08ApplicationCrashesCurrentComputer ) { 
                            $AutoChart08ApplicationCrashesCurrentComputer = $Line.PSComputerName
                            $AutoChart08ApplicationCrashesYDataResults    = New-Object PSObject -Property @{ 
                                ResultsCount = $AutoChart08ApplicationCrashesResultsCount
                                Computer     = $AutoChart08ApplicationCrashesComputer 
                            }
                            $script:AutoChart08ApplicationCrashesOverallDataResults += $AutoChart08ApplicationCrashesYDataResults
                            $AutoChart08ApplicationCrashesYResults     = @()
                            $AutoChart08ApplicationCrashesResultsCount = 0
                            $AutoChart08ApplicationCrashesComputer     = @()
                            if ( $AutoChart08ApplicationCrashesYResults -notcontains $Line.IPAddress ) {
                                if ( $Line.IPAddress -ne "" ) { $AutoChart08ApplicationCrashesYResults += $Line.IPAddress ; $AutoChart08ApplicationCrashesResultsCount += 1 }
                                if ( $AutoChart08ApplicationCrashesComputer -notcontains $Line.PSComputerName ) { $AutoChart08ApplicationCrashesComputer = $Line.PSComputerName }
                            }
                        }
                    }
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $AutoChart08ApplicationCrashesYDataResults = New-Object PSObject -Property @{ ResultsCount = $AutoChart08ApplicationCrashesResultsCount ; Computer = $AutoChart08ApplicationCrashesComputer }    
                $script:AutoChart08ApplicationCrashesOverallDataResults += $AutoChart08ApplicationCrashesYDataResults
                $script:AutoChart08ApplicationCrashesOverallDataResults | ForEach-Object { $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount) }

                $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

                $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ApplicationCrashesOverallDataResults.count))
                $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
                $script:AutoChart08ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart08ApplicationCrashesTitle.Text = "IPs (Router Advertisement) Per Host`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart08ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart08ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesOptionsButton
$script:AutoChart08ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart08ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart08ApplicationCrashes.Controls.Add($script:AutoChart08ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart08ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart08ApplicationCrashes.Controls.Remove($script:AutoChart08ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ApplicationCrashes)

$script:AutoChart08ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}    
    })
    $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart08ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                        Y = $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                        Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ApplicationCrashesOverallDataResults.count))
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart08ApplicationCrashesOverallDataResults.count)
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart08ApplicationCrashesOverallDataResults.count) - $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart08ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08ApplicationCrashesOverallDataResults.count) - $script:AutoChart08ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
        $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    })
$script:AutoChart08ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart08ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart08ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].ChartType = $script:AutoChart08ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#    $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
})
$script:AutoChart08ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ApplicationCrashesChartTypesAvailable) { $script:AutoChart08ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart08ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashes3DToggleButton
$script:AutoChart08ApplicationCrashes3DInclination = 0
$script:AutoChart08ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart08ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart08ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart08ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart08ApplicationCrashes3DInclination
        $script:AutoChart08ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart08ApplicationCrashes3DInclination)"
#        $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}

    }
    elseif ( $script:AutoChart08ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart08ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart08ApplicationCrashes3DInclination
        $script:AutoChart08ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart08ApplicationCrashes3DInclination)" 
#        $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
    else { 
        $script:AutoChart08ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart08ApplicationCrashes3DInclination = 0
        $script:AutoChart08ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart08ApplicationCrashes3DInclination
        $script:AutoChart08ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
#        $script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}
    }
})
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart08ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart08ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ApplicationCrashesColorsAvailable) { $script:AutoChart08ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Color = $script:AutoChart08ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashesChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart08ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Name' -eq $($script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart08ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ApplicationCrashesImportCsvPosResults) { $script:AutoChart08ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart08ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart08ApplicationCrashesImportCsvPosResults) { $script:AutoChart08ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ApplicationCrashesImportCsvNegResults) { $script:AutoChart08ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart08ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesCheckDiffButton
$script:AutoChart08ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart08ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart08ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ApplicationCrashes }})
    $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ApplicationCrashes }})
    $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart08ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart08ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart08ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart08ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart08ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart08ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart08ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart08ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart08ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart08ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart08ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart08ApplicationCrashesCheckDiffButton)


$AutoChart08ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart08ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "IPs (Router Advertisement) Per Host" -PropertyX "PSComputerName" -PropertyY "IPAddress" }
}
CommonButtonSettings -Button $AutoChart08ApplicationCrashesExpandChartButton
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($AutoChart08ApplicationCrashesExpandChartButton)


$script:AutoChart08ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart08ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart08ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesOpenInShell
$script:AutoChart08ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart08ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart08ApplicationCrashesOpenInShell)


$script:AutoChart08ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08ApplicationCrashesOpenInShell.Location.X + $script:AutoChart08ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesViewResults
$script:AutoChart08ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart08ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart08ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart08ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart08ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart08ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08ApplicationCrashes -Title $script:AutoChart08ApplicationCrashesTitle
})
$script:AutoChart08ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart08ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart08ApplicationCrashesSaveButton.Location.Y + $script:AutoChart08ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart08ApplicationCrashesNoticeTextbox)

$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.Clear()
$script:AutoChart08ApplicationCrashesOverallDataResults | Sort-Object -Property ResultsCount | Select-Object -skip $script:AutoChart08ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ApplicationCrashes.Series["IPs (Router Advertisement) Per Host"].Points.AddXY($_.Computer,$_.ResultsCount)}



























##############################################################################################
# AutoChart09ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07ApplicationCrashes.Location.X
                  Y = $script:AutoChart07ApplicationCrashes.Location.Y + $script:AutoChart07ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart09ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09ApplicationCrashes.Titles.Add($script:AutoChart09ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart09ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart09ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart09ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart09ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart09ApplicationCrashes.ChartAreas.Add($script:AutoChart09ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09ApplicationCrashes.Series.Add("Address State")  
$script:AutoChart09ApplicationCrashes.Series["Address State"].Enabled           = $True
$script:AutoChart09ApplicationCrashes.Series["Address State"].BorderWidth       = 1
$script:AutoChart09ApplicationCrashes.Series["Address State"].IsVisibleInLegend = $false
$script:AutoChart09ApplicationCrashes.Series["Address State"].Chartarea         = 'Chart Area'
$script:AutoChart09ApplicationCrashes.Series["Address State"].Legend            = 'Legend'
$script:AutoChart09ApplicationCrashes.Series["Address State"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09ApplicationCrashes.Series["Address State"]['PieLineColor']   = 'Black'
$script:AutoChart09ApplicationCrashes.Series["Address State"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09ApplicationCrashes.Series["Address State"].ChartType         = 'Column'
$script:AutoChart09ApplicationCrashes.Series["Address State"].Color             = 'Yellow'

        function Generate-AutoChart09ApplicationCrashes {
            $script:AutoChart09ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart09ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' | Sort-Object -Property 'AddressState' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()

            if ($script:AutoChart09ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart09ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart09ApplicationCrashesTitle.Text = "Address State"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart09ApplicationCrashesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09ApplicationCrashesUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressState) -eq $DataField.AddressState) {
                            $Count += 1
                            if ( $script:AutoChart09ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart09ApplicationCrashesCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart09ApplicationCrashesUniqueCount = $script:AutoChart09ApplicationCrashesCsvComputers.Count
                    $script:AutoChart09ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09ApplicationCrashesUniqueCount
                        Computers   = $script:AutoChart09ApplicationCrashesCsvComputers 
                    }
                    $script:AutoChart09ApplicationCrashesOverallDataResults += $script:AutoChart09ApplicationCrashesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount) }

                $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ApplicationCrashesOverallDataResults.count))
                $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart09ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart09ApplicationCrashesTitle.Text = "Address State`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart09ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart09ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesOptionsButton
$script:AutoChart09ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart09ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart09ApplicationCrashes.Controls.Add($script:AutoChart09ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart09ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart09ApplicationCrashes.Controls.Remove($script:AutoChart09ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ApplicationCrashes)

$script:AutoChart09ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
        $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}    
    })
    $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart09ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ApplicationCrashesOverallDataResults.count))
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart09ApplicationCrashesOverallDataResults.count)
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart09ApplicationCrashesOverallDataResults.count) - $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart09ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09ApplicationCrashesOverallDataResults.count) - $script:AutoChart09ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
        $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    })
$script:AutoChart09ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart09ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart09ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ApplicationCrashes.Series["Address State"].ChartType = $script:AutoChart09ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
#    $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
})
$script:AutoChart09ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ApplicationCrashesChartTypesAvailable) { $script:AutoChart09ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart09ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashes3DToggleButton
$script:AutoChart09ApplicationCrashes3DInclination = 0
$script:AutoChart09ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart09ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart09ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart09ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart09ApplicationCrashes3DInclination
        $script:AutoChart09ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart09ApplicationCrashes3DInclination)"
#        $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
#        $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart09ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart09ApplicationCrashes3DInclination
        $script:AutoChart09ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart09ApplicationCrashes3DInclination)" 
#        $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
#        $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart09ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart09ApplicationCrashes3DInclination = 0
        $script:AutoChart09ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart09ApplicationCrashes3DInclination
        $script:AutoChart09ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
#        $script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}
    }
})
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart09ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart09ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ApplicationCrashesColorsAvailable) { $script:AutoChart09ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ApplicationCrashes.Series["Address State"].Color = $script:AutoChart09ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart09ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressState' -eq $($script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart09ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ApplicationCrashesImportCsvPosResults) { $script:AutoChart09ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart09ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart09ApplicationCrashesImportCsvPosResults) { $script:AutoChart09ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ApplicationCrashesImportCsvNegResults) { $script:AutoChart09ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart09ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesCheckDiffButton
$script:AutoChart09ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart09ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressState' -ExpandProperty 'AddressState' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart09ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ApplicationCrashes }})
    $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ApplicationCrashes }})
    $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart09ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart09ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart09ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart09ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart09ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart09ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart09ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart09ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart09ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart09ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart09ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart09ApplicationCrashesCheckDiffButton)
    

$AutoChart09ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart09ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address States" -PropertyX "AddressState" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart09ApplicationCrashesExpandChartButton
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($AutoChart09ApplicationCrashesExpandChartButton)


$script:AutoChart09ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart09ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart09ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesOpenInShell
$script:AutoChart09ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart09ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart09ApplicationCrashesOpenInShell)


$script:AutoChart09ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09ApplicationCrashesOpenInShell.Location.X + $script:AutoChart09ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesViewResults
$script:AutoChart09ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart09ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart09ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart09ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart09ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart09ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09ApplicationCrashes -Title $script:AutoChart09ApplicationCrashesTitle
})
$script:AutoChart09ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart09ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart09ApplicationCrashesSaveButton.Location.Y + $script:AutoChart09ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart09ApplicationCrashesNoticeTextbox)

$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.Clear()
$script:AutoChart09ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart09ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ApplicationCrashes.Series["Address State"].Points.AddXY($_.DataField.AddressState,$_.UniqueCount)}    






















##############################################################################################
# AutoChart10ApplicationCrashes
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10ApplicationCrashes = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08ApplicationCrashes.Location.X
                  Y = $script:AutoChart08ApplicationCrashes.Location.Y + $script:AutoChart08ApplicationCrashes.Size.Height + 20 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10ApplicationCrashes.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart10ApplicationCrashesTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10ApplicationCrashes.Titles.Add($script:AutoChart10ApplicationCrashesTitle)

### Create Charts Area
$script:AutoChart10ApplicationCrashesArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10ApplicationCrashesArea.Name        = 'Chart Area'
$script:AutoChart10ApplicationCrashesArea.AxisX.Title = 'Hosts'
$script:AutoChart10ApplicationCrashesArea.AxisX.Interval          = 1
$script:AutoChart10ApplicationCrashesArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10ApplicationCrashesArea.Area3DStyle.Inclination = 75
$script:AutoChart10ApplicationCrashes.ChartAreas.Add($script:AutoChart10ApplicationCrashesArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10ApplicationCrashes.Series.Add("Address Family")  
$script:AutoChart10ApplicationCrashes.Series["Address Family"].Enabled           = $True
$script:AutoChart10ApplicationCrashes.Series["Address Family"].BorderWidth       = 1
$script:AutoChart10ApplicationCrashes.Series["Address Family"].IsVisibleInLegend = $false
$script:AutoChart10ApplicationCrashes.Series["Address Family"].Chartarea         = 'Chart Area'
$script:AutoChart10ApplicationCrashes.Series["Address Family"].Legend            = 'Legend'
$script:AutoChart10ApplicationCrashes.Series["Address Family"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10ApplicationCrashes.Series["Address Family"]['PieLineColor']   = 'Black'
$script:AutoChart10ApplicationCrashes.Series["Address Family"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10ApplicationCrashes.Series["Address Family"].ChartType         = 'Column'
$script:AutoChart10ApplicationCrashes.Series["Address Family"].Color             = 'Red'

        function Generate-AutoChart10ApplicationCrashes {
            $script:AutoChart10ApplicationCrashesCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart10ApplicationCrashesUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' | Sort-Object -Property 'AddressFamily' -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10ApplicationCrashesUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()

            if ($script:AutoChart10ApplicationCrashesUniqueDataFields.count -gt 0){
                $script:AutoChart10ApplicationCrashesTitle.ForeColor = 'Black'
                $script:AutoChart10ApplicationCrashesTitle.Text = "Address Family"

                # If the Second field/Y Axis equals PSComputername, it counts it
                $script:AutoChart10ApplicationCrashesOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10ApplicationCrashesUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart10ApplicationCrashesCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.AddressFamily) -eq $DataField.AddressFamily) {
                            $Count += 1
                            if ( $script:AutoChart10ApplicationCrashesCsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart10ApplicationCrashesCsvComputers += $($Line.PSComputerName) }                        
                        }
                    }
                    $script:AutoChart10ApplicationCrashesUniqueCount = $script:AutoChart10ApplicationCrashesCsvComputers.Count
                    $script:AutoChart10ApplicationCrashesDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10ApplicationCrashesUniqueCount
                        Computers   = $script:AutoChart10ApplicationCrashesCsvComputers 
                    }
                    $script:AutoChart10ApplicationCrashesOverallDataResults += $script:AutoChart10ApplicationCrashesDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount) }

                $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ApplicationCrashesOverallDataResults.count))
                $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ApplicationCrashesOverallDataResults.count))
            }
            else {
                $script:AutoChart10ApplicationCrashesTitle.ForeColor = 'Red'
                $script:AutoChart10ApplicationCrashesTitle.Text = "Address Family`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart10ApplicationCrashes

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart10ApplicationCrashesOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10ApplicationCrashes.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10ApplicationCrashes.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesOptionsButton
$script:AutoChart10ApplicationCrashesOptionsButton.Add_Click({  
    if ($script:AutoChart10ApplicationCrashesOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10ApplicationCrashesOptionsButton.Text = 'Options ^'
        $script:AutoChart10ApplicationCrashes.Controls.Add($script:AutoChart10ApplicationCrashesManipulationPanel)
    }
    elseif ($script:AutoChart10ApplicationCrashesOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10ApplicationCrashesOptionsButton.Text = 'Options v'
        $script:AutoChart10ApplicationCrashes.Controls.Remove($script:AutoChart10ApplicationCrashesManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ApplicationCrashesOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ApplicationCrashes)

$script:AutoChart10ApplicationCrashesManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10ApplicationCrashes.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10ApplicationCrashes.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10ApplicationCrashesTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ApplicationCrashesOverallDataResults.count))                
    $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue = $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar.Value
        $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar.Value)"
        $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
        $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}    
    })
    $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Controls.Add($script:AutoChart10ApplicationCrashesTrimOffFirstTrackBar)
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10ApplicationCrashesTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Location.X + $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ApplicationCrashesOverallDataResults.count))
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.Value         = $($script:AutoChart10ApplicationCrashesOverallDataResults.count)
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue   = 0
    $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue = $($script:AutoChart10ApplicationCrashesOverallDataResults.count) - $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.Value
        $script:AutoChart10ApplicationCrashesTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10ApplicationCrashesOverallDataResults.count) - $script:AutoChart10ApplicationCrashesTrimOffLastTrackBar.Value)"
        $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
        $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    })
$script:AutoChart10ApplicationCrashesTrimOffLastGroupBox.Controls.Add($script:AutoChart10ApplicationCrashesTrimOffLastTrackBar)
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashesTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10ApplicationCrashesChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Location.Y + $script:AutoChart10ApplicationCrashesTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ApplicationCrashesChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ApplicationCrashes.Series["Address Family"].ChartType = $script:AutoChart10ApplicationCrashesChartTypeComboBox.SelectedItem
#    $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
#    $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
})
$script:AutoChart10ApplicationCrashesChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10ApplicationCrashesChartTypesAvailable) { $script:AutoChart10ApplicationCrashesChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashesChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10ApplicationCrashes3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10ApplicationCrashesChartTypeComboBox.Location.X + $script:AutoChart10ApplicationCrashesChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10ApplicationCrashesChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashes3DToggleButton
$script:AutoChart10ApplicationCrashes3DInclination = 0
$script:AutoChart10ApplicationCrashes3DToggleButton.Add_Click({
    $script:AutoChart10ApplicationCrashes3DInclination += 10
    if ( $script:AutoChart10ApplicationCrashes3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart10ApplicationCrashesArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart10ApplicationCrashes3DInclination
        $script:AutoChart10ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart10ApplicationCrashes3DInclination)"
#        $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
#        $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10ApplicationCrashes3DInclination -le 90 ) {
        $script:AutoChart10ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart10ApplicationCrashes3DInclination
        $script:AutoChart10ApplicationCrashes3DToggleButton.Text  = "3D On ($script:AutoChart10ApplicationCrashes3DInclination)" 
#        $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
#        $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart10ApplicationCrashes3DToggleButton.Text  = "3D Off" 
        $script:AutoChart10ApplicationCrashes3DInclination = 0
        $script:AutoChart10ApplicationCrashesArea.Area3DStyle.Inclination = $script:AutoChart10ApplicationCrashes3DInclination
        $script:AutoChart10ApplicationCrashesArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
#        $script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}
    }
})
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashes3DToggleButton)

### Change the color of the chart
$script:AutoChart10ApplicationCrashesChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10ApplicationCrashes3DToggleButton.Location.X + $script:AutoChart10ApplicationCrashes3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ApplicationCrashes3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ApplicationCrashesColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10ApplicationCrashesColorsAvailable) { $script:AutoChart10ApplicationCrashesChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10ApplicationCrashesChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ApplicationCrashes.Series["Address Family"].Color = $script:AutoChart10ApplicationCrashesChangeColorComboBox.SelectedItem
})
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashesChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10ApplicationCrashes {    
    # List of Positive Endpoints that positively match
    $script:AutoChart10ApplicationCrashesImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'AddressFamily' -eq $($script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart10ApplicationCrashesInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ApplicationCrashesImportCsvPosResults) { $script:AutoChart10ApplicationCrashesInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10ApplicationCrashesImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart10ApplicationCrashesImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10ApplicationCrashesImportCsvAll) { if ($Endpoint -notin $script:AutoChart10ApplicationCrashesImportCsvPosResults) { $script:AutoChart10ApplicationCrashesImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10ApplicationCrashesInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ApplicationCrashesImportCsvNegResults) { $script:AutoChart10ApplicationCrashesInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10ApplicationCrashesImportCsvPosResults.count))"
    $script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10ApplicationCrashesImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10ApplicationCrashesCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10ApplicationCrashesTrimOffLastGroupBox.Location.X + $script:AutoChart10ApplicationCrashesTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ApplicationCrashesTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesCheckDiffButton
$script:AutoChart10ApplicationCrashesCheckDiffButton.Add_Click({
    $script:AutoChart10ApplicationCrashesInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'AddressFamily' -ExpandProperty 'AddressFamily' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10ApplicationCrashesInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10ApplicationCrashesInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffDropDownLabel.Location.y + $script:AutoChart10ApplicationCrashesInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10ApplicationCrashesInvestDiffDropDownArray) { $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ApplicationCrashes }})
    $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10ApplicationCrashes })

    ### Investigate Difference Execute Button
    $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Location.y + $script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton
    $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ApplicationCrashes }})
    $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10ApplicationCrashes })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton.Location.y + $script:AutoChart10ApplicationCrashesInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart10ApplicationCrashesInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Location.y + $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Location.x + $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ApplicationCrashesInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel.Location.y + $script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10ApplicationCrashesInvestDiffForm.Controls.AddRange(@($script:AutoChart10ApplicationCrashesInvestDiffDropDownLabel,$script:AutoChart10ApplicationCrashesInvestDiffDropDownComboBox,$script:AutoChart10ApplicationCrashesInvestDiffExecuteButton,$script:AutoChart10ApplicationCrashesInvestDiffPosResultsLabel,$script:AutoChart10ApplicationCrashesInvestDiffPosResultsTextBox,$script:AutoChart10ApplicationCrashesInvestDiffNegResultsLabel,$script:AutoChart10ApplicationCrashesInvestDiffNegResultsTextBox))
    $script:AutoChart10ApplicationCrashesInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10ApplicationCrashesInvestDiffForm.ShowDialog()
})
$script:AutoChart10ApplicationCrashesCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart10ApplicationCrashesCheckDiffButton)
    

$AutoChart10ApplicationCrashesExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10ApplicationCrashesCheckDiffButton.Location.X + $script:AutoChart10ApplicationCrashesCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10ApplicationCrashesCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Network Settings" -QueryTabName "Address Family" -PropertyX "AddressFamily" -PropertyY "PSComputerName" }
}
CommonButtonSettings -Button $AutoChart10ApplicationCrashesExpandChartButton
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($AutoChart10ApplicationCrashesExpandChartButton)


$script:AutoChart10ApplicationCrashesOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10ApplicationCrashesCheckDiffButton.Location.X
                   Y = $script:AutoChart10ApplicationCrashesCheckDiffButton.Location.Y + $script:AutoChart10ApplicationCrashesCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesOpenInShell
$script:AutoChart10ApplicationCrashesOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart10ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart10ApplicationCrashesOpenInShell)


$script:AutoChart10ApplicationCrashesViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10ApplicationCrashesOpenInShell.Location.X + $script:AutoChart10ApplicationCrashesOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ApplicationCrashesOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesViewResults
$script:AutoChart10ApplicationCrashesViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart10ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart10ApplicationCrashesViewResults)


### Save the chart to file
$script:AutoChart10ApplicationCrashesSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10ApplicationCrashesOpenInShell.Location.X
                  Y = $script:AutoChart10ApplicationCrashesOpenInShell.Location.Y + $script:AutoChart10ApplicationCrashesOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ApplicationCrashesSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10ApplicationCrashesSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10ApplicationCrashes -Title $script:AutoChart10ApplicationCrashesTitle
})
$script:AutoChart10ApplicationCrashesManipulationPanel.controls.Add($script:AutoChart10ApplicationCrashesSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10ApplicationCrashesNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10ApplicationCrashesSaveButton.Location.X 
                        Y = $script:AutoChart10ApplicationCrashesSaveButton.Location.Y + $script:AutoChart10ApplicationCrashesSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10ApplicationCrashesCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10ApplicationCrashesManipulationPanel.Controls.Add($script:AutoChart10ApplicationCrashesNoticeTextbox)

$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.Clear()
$script:AutoChart10ApplicationCrashesOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart10ApplicationCrashesTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ApplicationCrashesTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ApplicationCrashes.Series["Address Family"].Points.AddXY($_.DataField.AddressFamily,$_.UniqueCount)}    
#>



