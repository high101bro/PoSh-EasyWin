$CollectedDataDirectorY = $FormScale * "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Active Directory Computers'
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

$script:AutoChart01ADComputersCSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir | Where-Object Extension -eq '.csv').FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'AD Computers' -or $CSVFile -match 'Active Directory Computers') { $script:AutoChart01ADComputersCSVFileMatch += $CSVFile } }
} 
$script:AutoChartCSVFileMostRecentCollection = $script:AutoChart01ADComputersCSVFileMatch | Select-Object -Last 1
$script:AutoChartDataSourceCsv = $null
$script:AutoChartDataSourceCsv = Import-Csv $script:AutoChartCSVFileMostRecentCollection

$script:AutoChartsProgressBar.Value = 1
$script:AutoChartsProgressBar.Update()


function Close-AllOptions {
    $script:AutoChart01ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart01ADComputers.Controls.Remove($script:AutoChart01ADComputersManipulationPanel)
    $script:AutoChart02ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart02ADComputers.Controls.Remove($script:AutoChart02ADComputersManipulationPanel)
    $script:AutoChart03ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart03ADComputers.Controls.Remove($script:AutoChart03ADComputersManipulationPanel)
    $script:AutoChart04ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart04ADComputers.Controls.Remove($script:AutoChart04ADComputersManipulationPanel)
    $script:AutoChart05ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart05ADComputers.Controls.Remove($script:AutoChart05ADComputersManipulationPanel)
    $script:AutoChart06ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart06ADComputers.Controls.Remove($script:AutoChart06ADComputersManipulationPanel)
    $script:AutoChart07ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart07ADComputers.Controls.Remove($script:AutoChart07ADComputersManipulationPanel)
    $script:AutoChart08ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart08ADComputers.Controls.Remove($script:AutoChart08ADComputersManipulationPanel)
    $script:AutoChart09ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart09ADComputers.Controls.Remove($script:AutoChart09ADComputersManipulationPanel)
    $script:AutoChart10ADComputersOptionsButton.Text = 'Options v'
    $script:AutoChart10ADComputers.Controls.Remove($script:AutoChart10ADComputersManipulationPanel)
}

### Main Label at the top
$script:AutoChartsMainLabel01 = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'AD Computers'
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size   = @{ Width  = $FormScale * 1150
                Height = $FormScale * 25 }
    Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    TextAlign = 'MiddleCenter' 
}











$script:AutoChartOpenResultsOpenFileDialogfilename = $null
Generate-ComputerList

$AutoChartsUpdateChartsOptionsPanel = New-Object System.Windows.Forms.Panel -Property @{
    text   = 0
    Left   = $FormScale * 5
    Top    = 0
    Autosize = $true
}
            $AutoChartPullNewDataFromChartsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Update From Endpoint: __________"
                Left   = $FormScale * 5
                Top    = 0
                Width  = $FormScale * 225
                Height = $FormScale * 15
                Checked = $false
                Add_Click = {
                    if ((Test-Path "$PoShHome\Settings\Domain Controller For Dashboards.txt")){
                        $script:SelectedDomainController = Get-Content "$PoShHome\Settings\Domain Controller For Dashboards.txt"
                        $AutoChartPullNewDataFromChartsRadioButton.text = "Update From Endpoint:  $script:SelectedDomainController"
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show('An endpoint, should be a AD Domain Controller, has not yet been established for use within this dashboard. Use the Update From CheckBoxed Domain Controller Radio Button first.','No Data Available','ok','Info')
                        $This.checked = $false
                        $script:SelectedDomainController = $null
                    }
                }
            }
            if ((Test-Path "$PoShHome\Settings\Domain Controller For Dashboards.txt")){
                $script:SelectedDomainController = Get-Content "$PoShHome\Settings\Domain Controller For Dashboards.txt"
                $AutoChartPullNewDataFromChartsRadioButton.text = "Update From Endpoint:  $script:SelectedDomainController"
                $AutoChartPullNewDataFromChartsRadioButton.checked = $true
            }
            $AutoChartsUpdateChartsOptionsPanel.Controls.Add($AutoChartPullNewDataFromChartsRadioButton)


            $AutoChartPullNewDataCheckBoxedRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text    = 'Update From One CheckBoxed Endpoint'
                Left    = $FormScale * 5
                Top     = $AutoChartPullNewDataFromChartsRadioButton.Top + $AutoChartPullNewDataFromChartsRadioButton.Height
                Width   = $FormScale * 225
                Height  = $FormScale * 15
                Add_Click = {
                    if ($script:ComputerList.count -gt 1) {
                        [System.Windows.Forms.MessageBox]::Show('To many endpoints are checkboxed - select only one.','PoSh-EasyWin','ok','Info')                        
                        $script:SelectedDomainController = $null
                        $This.checked = $false
                    }
                    elseif ($script:ComputerList.count -eq 0){
                        [System.Windows.Forms.MessageBox]::Show('Checkbox a single endpoint.','PoSh-EasyWin','ok','Info')
                        $script:SelectedDomainController = $null
                        $This.checked = $false
                    }
                    else {
                        $VerifyServerSelection = [System.Windows.Forms.MessageBox]::Show("The following endpoint will be saved as the Domain Controller to query for Active Directory information?`n`n$script:ComputerList",'PoSh-EasyWin','yesno','Info')
                        switch ($VerifyServerSelection){
                            'Yes' {
                                $script:SelectedDomainController = $script:ComputerList
                                $script:SelectedDomainController | Set-Content "$PoShHome\Settings\Domain Controller For Dashboards.txt" -Force
                                $AutoChartPullNewDataFromChartsRadioButton.text = "Update From Endpoint:  $script:SelectedDomainController"
                            }
                            'No'  {
                                $script:SelectedDomainController = $null
                                $This.checked = $false
                            }
                        }
                    }
                }
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
                Enabled = $false
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

    if ($script:SelectedDomainController -ne $null) {
        #====================
        # First Radio Button
        #====================
        if ($AutoChartPullNewDataFromChartsRadioButton.checked){

            if ($script:SelectedDomainController -eq $null) {
                [System.Windows.Forms.MessageBox]::Show('An endpoint, should be a AD Domain Controller, has not yet been established for use within this dashboard. Use the Update From CheckBoxed Domain Controller Radio Button first.','No Data Available','ok','Info')
            }
            else {
                $ScriptBlockProgressBarInput = { Update-AutoChartsActiveDirectoryComputers -ServerToQuery $script:SelectedDomainController }
                Launch-ProgressBarForm -FormTitle 'Progress Bar' -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
            }
        }

        #=====================
        # Second Radio Button
        #=====================
        if ($AutoChartPullNewDataCheckBoxedRadioButton.checked) {
            if ($script:ComputerList.count -eq 0) {
                [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints','PoSh-EasyWin')
            }
            else {
                $ScriptBlockProgressBarInput = { Update-AutoChartsActiveDirectoryComputers -ComputerNameList $script:ComputerList }
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

        Generate-AutoChart01ADComputers
        Generate-AutoChart02ADComputers
        Generate-AutoChart03ADComputers
        Generate-AutoChart04ADComputers
        Generate-AutoChart05ADComputers
        Generate-AutoChart06ADComputers
        Generate-AutoChart07ADComputers
        Generate-AutoChart08ADComputers
        Generate-AutoChart09ADComputers
        Generate-AutoChart10ADComputers
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChartsMainLabel01)

<#
$AutoChartPullNewDataEnrichedCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Enriched'
    Left    = $AutoChartPullNewDataButton.Left
    Top     = $AutoChartPullNewDataButton.Top + $AutoChartPullNewDataButton.Height
    Width   = $FormScale * 125
    Height  = $FormScale * 22
    Checked = $false
    Add_Click = {
        if ($this.checked) {
            $AutoChartProtocolRPCRadioButton.enabled = $false
            $AutoChartProtocolSmbRadioButton.enabled = $false

            $AutoChartProtocolWinRMRadioButton.checked = $true
            $AutoChartProtocolRPCRadioButton.checked   = $false
            $AutoChartProtocolSmbRadioButton.checked   = $false
        }
        else {
            $AutoChartProtocolRPCRadioButton.enabled = $true
            $AutoChartProtocolSmbRadioButton.enabled = $true
        }
    }
}
$script:AutoChartsIndividualTab01.Controls.Add($AutoChartPullNewDataEnrichedCheckBox)
#>






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
# AutoChart01ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart01ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 50 }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart01ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart01ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01ADComputers.Titles.Add($script:AutoChart01ADComputersTitle)

### Create Charts Area
$script:AutoChart01ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01ADComputersArea.Name        = 'Chart Area'
$script:AutoChart01ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart01ADComputersArea.AxisX.Interval          = 1
$script:AutoChart01ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart01ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart01ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart01ADComputers.ChartAreas.Add($script:AutoChart01ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart01ADComputers.Series.Add("OperatingSystem")
$script:AutoChart01ADComputers.Series["OperatingSystem"].Enabled           = $True
$script:AutoChart01ADComputers.Series["OperatingSystem"].BorderWidth       = 1
$script:AutoChart01ADComputers.Series["OperatingSystem"].IsVisibleInLegend = $false
$script:AutoChart01ADComputers.Series["OperatingSystem"].Chartarea         = 'Chart Area'
$script:AutoChart01ADComputers.Series["OperatingSystem"].Legend            = 'Legend'
$script:AutoChart01ADComputers.Series["OperatingSystem"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01ADComputers.Series["OperatingSystem"]['PieLineColor']   = 'Black'
$script:AutoChart01ADComputers.Series["OperatingSystem"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01ADComputers.Series["OperatingSystem"].ChartType         = 'Column'
$script:AutoChart01ADComputers.Series["OperatingSystem"].Color             = 'Red'

        function Generate-AutoChart01ADComputers {
            $script:AutoChart01ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart01ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object OperatingSystem | Sort-Object OperatingSystem -unique
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()

            if ($script:AutoChart01ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart01ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart01ADComputersTitle.Text = "Operating System"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart01ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart01ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart01ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.OperatingSystem) -eq $DataField.OperatingSystem) {
                            $Count += 1
                            if ( $script:AutoChart01ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart01ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart01ADComputersUniqueCount = $script:AutoChart01ADComputersCsvComputers.Count
                    $script:AutoChart01ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart01ADComputersUniqueCount
                        Computers   = $script:AutoChart01ADComputersCsvComputers 
                    }
                    $script:AutoChart01ADComputersOverallDataResults += $script:AutoChart01ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount) }
                $script:AutoChart01ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADComputersOverallDataResults.count))
                $script:AutoChart01ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart01ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart01ADComputersTitle.Text = "OperatingSystem`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart01ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart01ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart01ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart01ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ADComputersOptionsButton
$script:AutoChart01ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart01ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart01ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart01ADComputers.Controls.Add($script:AutoChart01ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart01ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart01ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart01ADComputers.Controls.Remove($script:AutoChart01ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01ADComputers)


$script:AutoChart01ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart01ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart01ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart01ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01ADComputersOverallDataResults.count))                
    $script:AutoChart01ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart01ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01ADComputersTrimOffFirstTrackBarValue = $script:AutoChart01ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart01ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
        $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
    })
    $script:AutoChart01ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart01ADComputersTrimOffFirstTrackBar)
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart01ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart01ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart01ADComputersOverallDataResults.count))
    $script:AutoChart01ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart01ADComputersOverallDataResults.count)
    $script:AutoChart01ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart01ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01ADComputersTrimOffLastTrackBarValue = $($script:AutoChart01ADComputersOverallDataResults.count) - $script:AutoChart01ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart01ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01ADComputersOverallDataResults.count) - $script:AutoChart01ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
        $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
    })
$script:AutoChart01ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart01ADComputersTrimOffLastTrackBar)
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart01ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart01ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart01ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADComputers.Series["OperatingSystem"].ChartType = $script:AutoChart01ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
#    $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
})
$script:AutoChart01ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ADComputersChartTypesAvailable) { $script:AutoChart01ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart01ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01ADComputersChartTypeComboBox.Location.X + $script:AutoChart01ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart01ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart01ADComputers3DToggleButton
$script:AutoChart01ADComputers3DInclination = 0
$script:AutoChart01ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart01ADComputers3DInclination += 10
    if ( $script:AutoChart01ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart01ADComputersArea.Area3DStyle.Inclination = $script:AutoChart01ADComputers3DInclination
        $script:AutoChart01ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart01ADComputers3DInclination)"
#        $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
#        $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart01ADComputers3DInclination -le 90 ) {
        $script:AutoChart01ADComputersArea.Area3DStyle.Inclination = $script:AutoChart01ADComputers3DInclination
        $script:AutoChart01ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart01ADComputers3DInclination)" 
#        $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
#        $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart01ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart01ADComputers3DInclination = 0
        $script:AutoChart01ADComputersArea.Area3DStyle.Inclination = $script:AutoChart01ADComputers3DInclination
        $script:AutoChart01ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
#        $script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}
    }
})
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart01ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart01ADComputers3DToggleButton.Location.X + $script:AutoChart01ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart01ADComputersColorsAvailable) { $script:AutoChart01ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart01ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart01ADComputers.Series["OperatingSystem"].Color = $script:AutoChart01ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'OperatingSystem' -eq $($script:AutoChart01ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart01ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADComputersImportCsvPosResults) { $script:AutoChart01ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart01ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ADComputersImportCsvPosResults) { $script:AutoChart01ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ADComputersImportCsvNegResults) { $script:AutoChart01ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ADComputersImportCsvPosResults.count))"
    $script:AutoChart01ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart01ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart01ADComputersCheckDiffButton
$script:AutoChart01ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart01ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'OperatingSystem' -ExpandProperty 'OperatingSystem' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart01ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01ADComputersInvestDiffDropDownArray) { $script:AutoChart01ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADComputers }})
    $script:AutoChart01ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart01ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart01ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart01ADComputersInvestDiffExecuteButton
    $script:AutoChart01ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01ADComputers }})
    $script:AutoChart01ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart01ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart01ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart01ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart01ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart01ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart01ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart01ADComputersInvestDiffDropDownLabel,$script:AutoChart01ADComputersInvestDiffDropDownComboBox,$script:AutoChart01ADComputersInvestDiffExecuteButton,$script:AutoChart01ADComputersInvestDiffPosResultsLabel,$script:AutoChart01ADComputersInvestDiffPosResultsTextBox,$script:AutoChart01ADComputersInvestDiffNegResultsLabel,$script:AutoChart01ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart01ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart01ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ADComputersManipulationPanel.controls.Add($script:AutoChart01ADComputersCheckDiffButton)


$AutoChart01ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart01ADComputersCheckDiffButton.Location.X + $script:AutoChart01ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart01ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "OperatingSystem" -PropertyX "OperatingSystem" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart01ADComputersExpandChartButton
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($AutoChart01ADComputersExpandChartButton)


$script:AutoChart01ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart01ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart01ADComputersCheckDiffButton.Location.Y + $script:AutoChart01ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ADComputersOpenInShell
$script:AutoChart01ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart01ADComputersManipulationPanel.controls.Add($script:AutoChart01ADComputersOpenInShell)


$script:AutoChart01ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01ADComputersOpenInShell.Location.X + $script:AutoChart01ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart01ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ADComputersViewResults
$script:AutoChart01ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart01ADComputersManipulationPanel.controls.Add($script:AutoChart01ADComputersViewResults)


### Save the chart to file
$script:AutoChart01ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart01ADComputersOpenInShell.Location.Y + $script:AutoChart01ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart01ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart01ADComputers -Title $script:AutoChart01ADComputersTitle
})
$script:AutoChart01ADComputersManipulationPanel.controls.Add($script:AutoChart01ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart01ADComputersSaveButton.Location.Y + $script:AutoChart01ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ADComputersManipulationPanel.Controls.Add($script:AutoChart01ADComputersNoticeTextbox)

$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.Clear()
$script:AutoChart01ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01ADComputers.Series["OperatingSystem"].Points.AddXY($_.DataField.OperatingSystem,$_.UniqueCount)}























##############################################################################################
# AutoChart02ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart02ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADComputers.Location.X + $script:AutoChart01ADComputers.Size.Width + $($FormScale * 20)
                  Y = $script:AutoChart01ADComputers.Location.Y }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart02ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart02ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart02ADComputers.Titles.Add($script:AutoChart02ADComputersTitle)

### Create Charts Area
$script:AutoChart02ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02ADComputersArea.Name        = 'Chart Area'
$script:AutoChart02ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart02ADComputersArea.AxisX.Interval          = 1
$script:AutoChart02ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart02ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart02ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart02ADComputers.ChartAreas.Add($script:AutoChart02ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart02ADComputers.Series.Add("OperatingSystemVersion")
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Enabled           = $True
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].BorderWidth       = 1
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].IsVisibleInLegend = $false
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Chartarea         = 'Chart Area'
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Legend            = 'Legend'
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"]['PieLineColor']   = 'Black'
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].ChartType         = 'Column'
$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Color             = 'Blue'

        function Generate-AutoChart02ADComputers {
            $script:AutoChart02ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart02ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object OperatingSystemVersion | Sort-Object OperatingSystemVersion -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Blue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart02ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()

            if ($script:AutoChart02ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart02ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart02ADComputersTitle.Text = "OS Version"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart02ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart02ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart02ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.OperatingSystemVersion) -eq $DataField.OperatingSystemVersion) {
                            $Count += 1
                            if ( $script:AutoChart02ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart02ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart02ADComputersUniqueCount = $script:AutoChart02ADComputersCsvComputers.Count
                    $script:AutoChart02ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart02ADComputersUniqueCount
                        Computers   = $script:AutoChart02ADComputersCsvComputers 
                    }
                    $script:AutoChart02ADComputersOverallDataResults += $script:AutoChart02ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount) }
                $script:AutoChart02ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADComputersOverallDataResults.count))
                $script:AutoChart02ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart02ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart02ADComputersTitle.Text = "OperatingSystemVersion`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart02ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart02ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart02ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart02ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ADComputersOptionsButton
$script:AutoChart02ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart02ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart02ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart02ADComputers.Controls.Add($script:AutoChart02ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart02ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart02ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart02ADComputers.Controls.Remove($script:AutoChart02ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02ADComputers)


$script:AutoChart02ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart02ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart02ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart02ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02ADComputersOverallDataResults.count))                
    $script:AutoChart02ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart02ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02ADComputersTrimOffFirstTrackBarValue = $script:AutoChart02ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart02ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
        $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
    })
    $script:AutoChart02ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart02ADComputersTrimOffFirstTrackBar)
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart02ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart02ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart02ADComputersOverallDataResults.count))
    $script:AutoChart02ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart02ADComputersOverallDataResults.count)
    $script:AutoChart02ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart02ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02ADComputersTrimOffLastTrackBarValue = $($script:AutoChart02ADComputersOverallDataResults.count) - $script:AutoChart02ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart02ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02ADComputersOverallDataResults.count) - $script:AutoChart02ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
        $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
    })
$script:AutoChart02ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart02ADComputersTrimOffLastTrackBar)
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart02ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart02ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart02ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].ChartType = $script:AutoChart02ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
#    $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
})
$script:AutoChart02ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ADComputersChartTypesAvailable) { $script:AutoChart02ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart02ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02ADComputersChartTypeComboBox.Location.X + $script:AutoChart02ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart02ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart02ADComputers3DToggleButton
$script:AutoChart02ADComputers3DInclination = 0
$script:AutoChart02ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart02ADComputers3DInclination += 10
    if ( $script:AutoChart02ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart02ADComputersArea.Area3DStyle.Inclination = $script:AutoChart02ADComputers3DInclination
        $script:AutoChart02ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart02ADComputers3DInclination)"
#        $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
#        $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart02ADComputers3DInclination -le 90 ) {
        $script:AutoChart02ADComputersArea.Area3DStyle.Inclination = $script:AutoChart02ADComputers3DInclination
        $script:AutoChart02ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart02ADComputers3DInclination)" 
#        $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
#        $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart02ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart02ADComputers3DInclination = 0
        $script:AutoChart02ADComputersArea.Area3DStyle.Inclination = $script:AutoChart02ADComputers3DInclination
        $script:AutoChart02ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
#        $script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}
    }
})
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart02ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart02ADComputers3DToggleButton.Location.X + $script:AutoChart02ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart02ADComputersColorsAvailable) { $script:AutoChart02ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart02ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Color = $script:AutoChart02ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'OperatingSystemVersion' -eq $($script:AutoChart02ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart02ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADComputersImportCsvPosResults) { $script:AutoChart02ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart02ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ADComputersImportCsvPosResults) { $script:AutoChart02ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ADComputersImportCsvNegResults) { $script:AutoChart02ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ADComputersImportCsvPosResults.count))"
    $script:AutoChart02ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart02ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart02ADComputersCheckDiffButton
$script:AutoChart02ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart02ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'OperatingSystemVersion' -ExpandProperty 'OperatingSystemVersion' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart02ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02ADComputersInvestDiffDropDownArray) { $script:AutoChart02ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADComputers }})
    $script:AutoChart02ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart02ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart02ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart02ADComputersInvestDiffExecuteButton
    $script:AutoChart02ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02ADComputers }})
    $script:AutoChart02ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart02ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart02ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart02ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart02ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart02ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart02ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart02ADComputersInvestDiffDropDownLabel,$script:AutoChart02ADComputersInvestDiffDropDownComboBox,$script:AutoChart02ADComputersInvestDiffExecuteButton,$script:AutoChart02ADComputersInvestDiffPosResultsLabel,$script:AutoChart02ADComputersInvestDiffPosResultsTextBox,$script:AutoChart02ADComputersInvestDiffNegResultsLabel,$script:AutoChart02ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart02ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart02ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ADComputersManipulationPanel.controls.Add($script:AutoChart02ADComputersCheckDiffButton)


$AutoChart02ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart02ADComputersCheckDiffButton.Location.X + $script:AutoChart02ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart02ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "OperatingSystemVersion" -PropertyX "OperatingSystemVersion" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart02ADComputersExpandChartButton
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($AutoChart02ADComputersExpandChartButton)


$script:AutoChart02ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart02ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart02ADComputersCheckDiffButton.Location.Y + $script:AutoChart02ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ADComputersOpenInShell
$script:AutoChart02ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart02ADComputersManipulationPanel.controls.Add($script:AutoChart02ADComputersOpenInShell)


$script:AutoChart02ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02ADComputersOpenInShell.Location.X + $script:AutoChart02ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart02ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ADComputersViewResults
$script:AutoChart02ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart02ADComputersManipulationPanel.controls.Add($script:AutoChart02ADComputersViewResults)


### Save the chart to file
$script:AutoChart02ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart02ADComputersOpenInShell.Location.Y + $script:AutoChart02ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart02ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart02ADComputers -Title $script:AutoChart02ADComputersTitle
})
$script:AutoChart02ADComputersManipulationPanel.controls.Add($script:AutoChart02ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart02ADComputersSaveButton.Location.Y + $script:AutoChart02ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ADComputersManipulationPanel.Controls.Add($script:AutoChart02ADComputersNoticeTextbox)

$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.Clear()
$script:AutoChart02ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02ADComputers.Series["OperatingSystemVersion"].Points.AddXY($_.DataField.OperatingSystemVersion,$_.UniqueCount)}




















##############################################################################################
# AutoChart03ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart03ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart01ADComputers.Location.X
                  Y = $script:AutoChart01ADComputers.Location.Y + $script:AutoChart01ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart03ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart03ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart03ADComputers.Titles.Add($script:AutoChart03ADComputersTitle)

### Create Charts Area
$script:AutoChart03ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03ADComputersArea.Name        = 'Chart Area'
$script:AutoChart03ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart03ADComputersArea.AxisX.Interval          = 1
$script:AutoChart03ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart03ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart03ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart03ADComputers.ChartAreas.Add($script:AutoChart03ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart03ADComputers.Series.Add("OperatingSystemServicePack")  
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Enabled           = $True
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].BorderWidth       = 1
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].IsVisibleInLegend = $false
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Chartarea         = 'Chart Area'
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Legend            = 'Legend'
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"]['PieLineColor']   = 'Black'
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].ChartType         = 'Column'
$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Color             = 'Green'

        function Generate-AutoChart03ADComputers {
            $script:AutoChart03ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart03ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object OperatingSystemServicePack | Sort-Object OperatingSystemServicePack -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Green'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()

            if ($script:AutoChart03ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart03ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart03ADComputersTitle.Text = "OS Service Pack"
                
                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart03ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart03ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart03ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($Line.OperatingSystemServicePack -eq $DataField.OperatingSystemServicePack) {
                            $Count += 1
                            if ( $script:AutoChart03ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart03ADComputersCsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart03ADComputersUniqueCount = $script:AutoChart03ADComputersCsvComputers.Count
                    $script:AutoChart03ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart03ADComputersUniqueCount
                        Computers   = $script:AutoChart03ADComputersCsvComputers 
                    }
                    $script:AutoChart03ADComputersOverallDataResults += $script:AutoChart03ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount) }

                $script:AutoChart03ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADComputersOverallDataResults.count))
                $script:AutoChart03ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart03ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart03ADComputersTitle.Text = "OperatingSystemServicePack`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart03ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart03ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart03ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ADComputersOptionsButton
$script:AutoChart03ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart03ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart03ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart03ADComputers.Controls.Add($script:AutoChart03ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart03ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart03ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart03ADComputers.Controls.Remove($script:AutoChart03ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03ADComputers)

$script:AutoChart03ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart03ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart03ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart03ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03ADComputersOverallDataResults.count))                
    $script:AutoChart03ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart03ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03ADComputersTrimOffFirstTrackBarValue = $script:AutoChart03ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart03ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
        $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}    
    })
    $script:AutoChart03ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart03ADComputersTrimOffFirstTrackBar)
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart03ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart03ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart03ADComputersOverallDataResults.count))
    $script:AutoChart03ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart03ADComputersOverallDataResults.count)
    $script:AutoChart03ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart03ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03ADComputersTrimOffLastTrackBarValue = $($script:AutoChart03ADComputersOverallDataResults.count) - $script:AutoChart03ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart03ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03ADComputersOverallDataResults.count) - $script:AutoChart03ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
        $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}
    })
$script:AutoChart03ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart03ADComputersTrimOffLastTrackBar)
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart03ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart03ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].ChartType = $script:AutoChart03ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
#    $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}
})
$script:AutoChart03ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ADComputersChartTypesAvailable) { $script:AutoChart03ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputersChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart03ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03ADComputersChartTypeComboBox.Location.X + $script:AutoChart03ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart03ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart03ADComputers3DToggleButton
$script:AutoChart03ADComputers3DInclination = 0
$script:AutoChart03ADComputers3DToggleButton.Add_Click({
    $script:AutoChart03ADComputers3DInclination += 10
    if ( $script:AutoChart03ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart03ADComputersArea.Area3DStyle.Inclination = $script:AutoChart03ADComputers3DInclination
        $script:AutoChart03ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart03ADComputers3DInclination)"
#        $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
#        $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart03ADComputers3DInclination -le 90 ) {
        $script:AutoChart03ADComputersArea.Area3DStyle.Inclination = $script:AutoChart03ADComputers3DInclination
        $script:AutoChart03ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart03ADComputers3DInclination)" 
#        $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
#        $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart03ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart03ADComputers3DInclination = 0
        $script:AutoChart03ADComputersArea.Area3DStyle.Inclination = $script:AutoChart03ADComputers3DInclination
        $script:AutoChart03ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
#        $script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}
    }
})
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart03ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart03ADComputers3DToggleButton.Location.X + $script:AutoChart03ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart03ADComputersColorsAvailable) { $script:AutoChart03ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart03ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Color = $script:AutoChart03ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputersChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'OperatingSystemServicePack' -eq $($script:AutoChart03ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart03ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADComputersImportCsvPosResults) { $script:AutoChart03ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart03ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ADComputersImportCsvPosResults) { $script:AutoChart03ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ADComputersImportCsvNegResults) { $script:AutoChart03ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ADComputersImportCsvPosResults.count))"
    $script:AutoChart03ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart03ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart03ADComputersCheckDiffButton
$script:AutoChart03ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart03ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'OperatingSystemServicePack' -ExpandProperty 'OperatingSystemServicePack' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart03ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03ADComputersInvestDiffDropDownArray) { $script:AutoChart03ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADComputers }})
    $script:AutoChart03ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart03ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart03ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart03ADComputersInvestDiffExecuteButton
    $script:AutoChart03ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03ADComputers }})
    $script:AutoChart03ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart03ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart03ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart03ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart03ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart03ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart03ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart03ADComputersInvestDiffDropDownLabel,$script:AutoChart03ADComputersInvestDiffDropDownComboBox,$script:AutoChart03ADComputersInvestDiffExecuteButton,$script:AutoChart03ADComputersInvestDiffPosResultsLabel,$script:AutoChart03ADComputersInvestDiffPosResultsTextBox,$script:AutoChart03ADComputersInvestDiffNegResultsLabel,$script:AutoChart03ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart03ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart03ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ADComputersManipulationPanel.controls.Add($script:AutoChart03ADComputersCheckDiffButton)
    

$AutoChart03ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart03ADComputersCheckDiffButton.Location.X + $script:AutoChart03ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart03ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "OperatingSystemServicePack" -PropertyX "OperatingSystemServicePack" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart03ADComputersExpandChartButton
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($AutoChart03ADComputersExpandChartButton)


$script:AutoChart03ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart03ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart03ADComputersCheckDiffButton.Location.Y + $script:AutoChart03ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ADComputersOpenInShell
$script:AutoChart03ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart03ADComputersManipulationPanel.controls.Add($script:AutoChart03ADComputersOpenInShell)


$script:AutoChart03ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03ADComputersOpenInShell.Location.X + $script:AutoChart03ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart03ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ADComputersViewResults
$script:AutoChart03ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart03ADComputersManipulationPanel.controls.Add($script:AutoChart03ADComputersViewResults)


### Save the chart to file
$script:AutoChart03ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart03ADComputersOpenInShell.Location.Y + $script:AutoChart03ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart03ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart03ADComputers -Title $script:AutoChart03ADComputersTitle
})
$script:AutoChart03ADComputersManipulationPanel.controls.Add($script:AutoChart03ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart03ADComputersSaveButton.Location.Y + $script:AutoChart03ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ADComputersManipulationPanel.Controls.Add($script:AutoChart03ADComputersNoticeTextbox)

$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.Clear()
$script:AutoChart03ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03ADComputers.Series["OperatingSystemServicePack"].Points.AddXY($_.DataField.OperatingSystemServicePack,$_.UniqueCount)}    





















##############################################################################################
# AutoChart04ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart04ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart02ADComputers.Location.X
                  Y = $script:AutoChart02ADComputers.Location.Y + $script:AutoChart02ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart04ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart04ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart04ADComputers.Titles.Add($script:AutoChart04ADComputersTitle)

### Create Charts Area
$script:AutoChart04ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04ADComputersArea.Name        = 'Chart Area'
$script:AutoChart04ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart04ADComputersArea.AxisX.Interval          = 1
$script:AutoChart04ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart04ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart04ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart04ADComputers.ChartAreas.Add($script:AutoChart04ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart04ADComputers.Series.Add("OperatingSystemHotfix")
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Enabled           = $True
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].BorderWidth       = 1
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].IsVisibleInLegend = $false
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Chartarea         = 'Chart Area'
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Legend            = 'Legend'
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"]['PieLineColor']   = 'Black'
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].ChartType         = 'Column'
$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Color             = 'Orange'

        function Generate-AutoChart04ADComputers {
            $script:AutoChart04ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart04ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object OperatingSystemHotfix | Sort-Object OperatingSystemHotfix -Unique
            $script:AutoChartsProgressBar.ForeColor = 'Orange'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart04ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()

            if ($script:AutoChart04ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart04ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart04ADComputersTitle.Text = "OS Hotfix"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart04ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart04ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart04ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.OperatingSystemHotfix) -eq $DataField.OperatingSystemHotfix) {
                            $Count += 1
                            if ( $script:AutoChart04ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart04ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart04ADComputersUniqueCount = $script:AutoChart04ADComputersCsvComputers.Count
                    $script:AutoChart04ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart04ADComputersUniqueCount
                        Computers   = $script:AutoChart04ADComputersCsvComputers 
                    }
                    $script:AutoChart04ADComputersOverallDataResults += $script:AutoChart04ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount) }
                $script:AutoChart04ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADComputersOverallDataResults.count))
                $script:AutoChart04ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart04ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart04ADComputersTitle.Text = "OperatingSystemHotfix`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart04ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart04ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart04ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ADComputersOptionsButton
$script:AutoChart04ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart04ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart04ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart04ADComputers.Controls.Add($script:AutoChart04ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart04ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart04ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart04ADComputers.Controls.Remove($script:AutoChart04ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04ADComputers)


$script:AutoChart04ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart04ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart04ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart04ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04ADComputersOverallDataResults.count))                
    $script:AutoChart04ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart04ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04ADComputersTrimOffFirstTrackBarValue = $script:AutoChart04ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart04ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
        $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
    })
    $script:AutoChart04ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart04ADComputersTrimOffFirstTrackBar)
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart04ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart04ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart04ADComputersOverallDataResults.count))
    $script:AutoChart04ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart04ADComputersOverallDataResults.count)
    $script:AutoChart04ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart04ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04ADComputersTrimOffLastTrackBarValue = $($script:AutoChart04ADComputersOverallDataResults.count) - $script:AutoChart04ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart04ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04ADComputersOverallDataResults.count) - $script:AutoChart04ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
        $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
    })
$script:AutoChart04ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart04ADComputersTrimOffLastTrackBar)
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart04ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart04ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].ChartType = $script:AutoChart04ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
#    $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
})
$script:AutoChart04ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ADComputersChartTypesAvailable) { $script:AutoChart04ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart04ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04ADComputersChartTypeComboBox.Location.X + $script:AutoChart04ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart04ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart04ADComputers3DToggleButton
$script:AutoChart04ADComputers3DInclination = 0
$script:AutoChart04ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart04ADComputers3DInclination += 10
    if ( $script:AutoChart04ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart04ADComputersArea.Area3DStyle.Inclination = $script:AutoChart04ADComputers3DInclination
        $script:AutoChart04ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart04ADComputers3DInclination)"
#        $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
#        $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart04ADComputers3DInclination -le 90 ) {
        $script:AutoChart04ADComputersArea.Area3DStyle.Inclination = $script:AutoChart04ADComputers3DInclination
        $script:AutoChart04ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart04ADComputers3DInclination)" 
#        $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
#        $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart04ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart04ADComputers3DInclination = 0
        $script:AutoChart04ADComputersArea.Area3DStyle.Inclination = $script:AutoChart04ADComputers3DInclination
        $script:AutoChart04ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
#        $script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}
    }
})
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart04ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart04ADComputers3DToggleButton.Location.X + $script:AutoChart04ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart04ADComputersColorsAvailable) { $script:AutoChart04ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart04ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Color = $script:AutoChart04ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'OperatingSystemHotfix' -eq $($script:AutoChart04ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart04ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADComputersImportCsvPosResults) { $script:AutoChart04ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart04ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ADComputersImportCsvPosResults) { $script:AutoChart04ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ADComputersImportCsvNegResults) { $script:AutoChart04ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ADComputersImportCsvPosResults.count))"
    $script:AutoChart04ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart04ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart04ADComputersCheckDiffButton
$script:AutoChart04ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart04ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'OperatingSystemHotfix' -ExpandProperty 'OperatingSystemHotfix' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart04ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04ADComputersInvestDiffDropDownArray) { $script:AutoChart04ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADComputers }})
    $script:AutoChart04ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart04ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart04ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart04ADComputersInvestDiffExecuteButton
    $script:AutoChart04ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04ADComputers }})
    $script:AutoChart04ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart04ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart04ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart04ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart04ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart04ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart04ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart04ADComputersInvestDiffDropDownLabel,$script:AutoChart04ADComputersInvestDiffDropDownComboBox,$script:AutoChart04ADComputersInvestDiffExecuteButton,$script:AutoChart04ADComputersInvestDiffPosResultsLabel,$script:AutoChart04ADComputersInvestDiffPosResultsTextBox,$script:AutoChart04ADComputersInvestDiffNegResultsLabel,$script:AutoChart04ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart04ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart04ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ADComputersManipulationPanel.controls.Add($script:AutoChart04ADComputersCheckDiffButton)


$AutoChart04ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart04ADComputersCheckDiffButton.Location.X + $script:AutoChart04ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart04ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "OperatingSystemHotfix" -PropertyX "OperatingSystemHotfix" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart04ADComputersExpandChartButton
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($AutoChart04ADComputersExpandChartButton)


$script:AutoChart04ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart04ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart04ADComputersCheckDiffButton.Location.Y + $script:AutoChart04ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ADComputersOpenInShell
$script:AutoChart04ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart04ADComputersManipulationPanel.controls.Add($script:AutoChart04ADComputersOpenInShell)


$script:AutoChart04ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04ADComputersOpenInShell.Location.X + $script:AutoChart04ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart04ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ADComputersViewResults
$script:AutoChart04ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart04ADComputersManipulationPanel.controls.Add($script:AutoChart04ADComputersViewResults)


### Save the chart to file
$script:AutoChart04ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart04ADComputersOpenInShell.Location.Y + $script:AutoChart04ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart04ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart04ADComputers -Title $script:AutoChart04ADComputersTitle
})
$script:AutoChart04ADComputersManipulationPanel.controls.Add($script:AutoChart04ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart04ADComputersSaveButton.Location.Y + $script:AutoChart04ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ADComputersManipulationPanel.Controls.Add($script:AutoChart04ADComputersNoticeTextbox)

$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.Clear()
$script:AutoChart04ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04ADComputers.Series["OperatingSystemHotfix"].Points.AddXY($_.DataField.OperatingSystemHotfix,$_.UniqueCount)}




















##############################################################################################
# AutoChart05ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart05ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart03ADComputers.Location.X
                  Y = $script:AutoChart03ADComputers.Location.Y + $script:AutoChart03ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart05ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart05ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart05ADComputers.Titles.Add($script:AutoChart05ADComputersTitle)

### Create Charts Area
$script:AutoChart05ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05ADComputersArea.Name        = 'Chart Area'
$script:AutoChart05ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart05ADComputersArea.AxisX.Interval          = 1
$script:AutoChart05ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart05ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart05ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart05ADComputers.ChartAreas.Add($script:AutoChart05ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart05ADComputers.Series.Add("IPv4Address")  
$script:AutoChart05ADComputers.Series["IPv4Address"].Enabled           = $True
$script:AutoChart05ADComputers.Series["IPv4Address"].BorderWidth       = 1
$script:AutoChart05ADComputers.Series["IPv4Address"].IsVisibleInLegend = $false
$script:AutoChart05ADComputers.Series["IPv4Address"].Chartarea         = 'Chart Area'
$script:AutoChart05ADComputers.Series["IPv4Address"].Legend            = 'Legend'
$script:AutoChart05ADComputers.Series["IPv4Address"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05ADComputers.Series["IPv4Address"]['PieLineColor']   = 'Black'
$script:AutoChart05ADComputers.Series["IPv4Address"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05ADComputers.Series["IPv4Address"].ChartType         = 'Column'
$script:AutoChart05ADComputers.Series["IPv4Address"].Color             = 'Brown'

        function Generate-AutoChart05ADComputers {
            $script:AutoChart05ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart05ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object IPv4Address | Sort-Object IPv4Address -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Brown'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart05ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()

            if ($script:AutoChart05ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart05ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart05ADComputersTitle.Text = "IPv4 Address"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart05ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart05ADComputersUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart05ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.IPv4Address) -eq $DataField.IPv4Address) {
                            $Count += 1
                            if ( $script:AutoChart05ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart05ADComputersCsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart05ADComputersUniqueCount = $script:AutoChart05ADComputersCsvComputers.Count
                    $script:AutoChart05ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart05ADComputersUniqueCount
                        Computers   = $script:AutoChart05ADComputersCsvComputers 
                    }
                    $script:AutoChart05ADComputersOverallDataResults += $script:AutoChart05ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount) }

                $script:AutoChart05ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADComputersOverallDataResults.count))
                $script:AutoChart05ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart05ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart05ADComputersTitle.Text = "IPv4Address`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart05ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart05ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart05ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ADComputersOptionsButton
$script:AutoChart05ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart05ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart05ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart05ADComputers.Controls.Add($script:AutoChart05ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart05ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart05ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart05ADComputers.Controls.Remove($script:AutoChart05ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05ADComputers)

$script:AutoChart05ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart05ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart05ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart05ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05ADComputersOverallDataResults.count))                
    $script:AutoChart05ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart05ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05ADComputersTrimOffFirstTrackBarValue = $script:AutoChart05ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart05ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
        $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}    
    })
    $script:AutoChart05ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart05ADComputersTrimOffFirstTrackBar)
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart05ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart05ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart05ADComputersOverallDataResults.count))
    $script:AutoChart05ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart05ADComputersOverallDataResults.count)
    $script:AutoChart05ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart05ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05ADComputersTrimOffLastTrackBarValue = $($script:AutoChart05ADComputersOverallDataResults.count) - $script:AutoChart05ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart05ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05ADComputersOverallDataResults.count) - $script:AutoChart05ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
        $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}
    })
$script:AutoChart05ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart05ADComputersTrimOffLastTrackBar)
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart05ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart05ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart05ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADComputers.Series["IPv4Address"].ChartType = $script:AutoChart05ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
#    $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}
})
$script:AutoChart05ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ADComputersChartTypesAvailable) { $script:AutoChart05ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputersChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart05ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05ADComputersChartTypeComboBox.Location.X + $script:AutoChart05ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart05ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart05ADComputers3DToggleButton
$script:AutoChart05ADComputers3DInclination = 0
$script:AutoChart05ADComputers3DToggleButton.Add_Click({
    $script:AutoChart05ADComputers3DInclination += 10
    if ( $script:AutoChart05ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart05ADComputersArea.Area3DStyle.Inclination = $script:AutoChart05ADComputers3DInclination
        $script:AutoChart05ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart05ADComputers3DInclination)"
#        $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
#        $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart05ADComputers3DInclination -le 90 ) {
        $script:AutoChart05ADComputersArea.Area3DStyle.Inclination = $script:AutoChart05ADComputers3DInclination
        $script:AutoChart05ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart05ADComputers3DInclination)" 
#        $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
#        $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart05ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart05ADComputers3DInclination = 0
        $script:AutoChart05ADComputersArea.Area3DStyle.Inclination = $script:AutoChart05ADComputers3DInclination
        $script:AutoChart05ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
#        $script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}
    }
})
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart05ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart05ADComputers3DToggleButton.Location.X + $script:AutoChart05ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart05ADComputersColorsAvailable) { $script:AutoChart05ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart05ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart05ADComputers.Series["IPv4Address"].Color = $script:AutoChart05ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputersChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'IPv4Address' -eq $($script:AutoChart05ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart05ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADComputersImportCsvPosResults) { $script:AutoChart05ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart05ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ADComputersImportCsvPosResults) { $script:AutoChart05ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ADComputersImportCsvNegResults) { $script:AutoChart05ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ADComputersImportCsvPosResults.count))"
    $script:AutoChart05ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart05ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart05ADComputersCheckDiffButton
$script:AutoChart05ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart05ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'IPv4Address' -ExpandProperty 'IPv4Address' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart05ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05ADComputersInvestDiffDropDownArray) { $script:AutoChart05ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADComputers }})
    $script:AutoChart05ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart05ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart05ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart05ADComputersInvestDiffExecuteButton
    $script:AutoChart05ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05ADComputers }})
    $script:AutoChart05ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart05ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart05ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart05ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart05ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart05ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart05ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart05ADComputersInvestDiffDropDownLabel,$script:AutoChart05ADComputersInvestDiffDropDownComboBox,$script:AutoChart05ADComputersInvestDiffExecuteButton,$script:AutoChart05ADComputersInvestDiffPosResultsLabel,$script:AutoChart05ADComputersInvestDiffPosResultsTextBox,$script:AutoChart05ADComputersInvestDiffNegResultsLabel,$script:AutoChart05ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart05ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart05ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ADComputersManipulationPanel.controls.Add($script:AutoChart05ADComputersCheckDiffButton)
    

$AutoChart05ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart05ADComputersCheckDiffButton.Location.X + $script:AutoChart05ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart05ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "IPv4Addresses" -PropertyX "IPv4Address" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart05ADComputersExpandChartButton
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($AutoChart05ADComputersExpandChartButton)


$script:AutoChart05ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart05ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart05ADComputersCheckDiffButton.Location.Y + $script:AutoChart05ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ADComputersOpenInShell
$script:AutoChart05ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart05ADComputersManipulationPanel.controls.Add($script:AutoChart05ADComputersOpenInShell)


$script:AutoChart05ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05ADComputersOpenInShell.Location.X + $script:AutoChart05ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart05ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ADComputersViewResults
$script:AutoChart05ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart05ADComputersManipulationPanel.controls.Add($script:AutoChart05ADComputersViewResults)


### Save the chart to file
$script:AutoChart05ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart05ADComputersOpenInShell.Location.Y + $script:AutoChart05ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart05ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart05ADComputers -Title $script:AutoChart05ADComputersTitle
})
$script:AutoChart05ADComputersManipulationPanel.controls.Add($script:AutoChart05ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart05ADComputersSaveButton.Location.Y + $script:AutoChart05ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ADComputersManipulationPanel.Controls.Add($script:AutoChart05ADComputersNoticeTextbox)

$script:AutoChart05ADComputers.Series["IPv4Address"].Points.Clear()
$script:AutoChart05ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05ADComputers.Series["IPv4Address"].Points.AddXY($_.DataField.IPv4Address,$_.UniqueCount)}    

















##############################################################################################
# AutoChart06ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart06ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart04ADComputers.Location.X
                  Y = $script:AutoChart04ADComputers.Location.Y + $script:AutoChart04ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart06ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart06ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart06ADComputers.Titles.Add($script:AutoChart06ADComputersTitle)

### Create Charts Area
$script:AutoChart06ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06ADComputersArea.Name        = 'Chart Area'
$script:AutoChart06ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart06ADComputersArea.AxisX.Interval          = 1
$script:AutoChart06ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart06ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart06ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart06ADComputers.ChartAreas.Add($script:AutoChart06ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart06ADComputers.Series.Add("Enabled")  
$script:AutoChart06ADComputers.Series["Enabled"].Enabled           = $True
$script:AutoChart06ADComputers.Series["Enabled"].BorderWidth       = 1
$script:AutoChart06ADComputers.Series["Enabled"].IsVisibleInLegend = $false
$script:AutoChart06ADComputers.Series["Enabled"].Chartarea         = 'Chart Area'
$script:AutoChart06ADComputers.Series["Enabled"].Legend            = 'Legend'
$script:AutoChart06ADComputers.Series["Enabled"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06ADComputers.Series["Enabled"]['PieLineColor']   = 'Black'
$script:AutoChart06ADComputers.Series["Enabled"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06ADComputers.Series["Enabled"].ChartType         = 'Column'
$script:AutoChart06ADComputers.Series["Enabled"].Color             = 'Gray'

        function Generate-AutoChart06ADComputers {
            $script:AutoChart06ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart06ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Enabled | Sort-Object Enabled -Unique

            $script:AutoChartsProgressBar.ForeColor = 'Gray'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart06ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()

            if ($script:AutoChart06ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart06ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart06ADComputersTitle.Text = "Enabled"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart06ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart06ADComputersUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart06ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Enabled) -eq $DataField.Enabled) {
                            $Count += 1
                            if ( $script:AutoChart06ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart06ADComputersCsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart06ADComputersUniqueCount = $script:AutoChart06ADComputersCsvComputers.Count
                    $script:AutoChart06ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart06ADComputersUniqueCount
                        Computers   = $script:AutoChart06ADComputersCsvComputers 
                    }
                    $script:AutoChart06ADComputersOverallDataResults += $script:AutoChart06ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object { $script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount) }

                $script:AutoChart06ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADComputersOverallDataResults.count))
                $script:AutoChart06ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart06ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart06ADComputersTitle.Text = "Enabled`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart06ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart06ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart06ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ADComputersOptionsButton
$script:AutoChart06ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart06ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart06ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart06ADComputers.Controls.Add($script:AutoChart06ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart06ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart06ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart06ADComputers.Controls.Remove($script:AutoChart06ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06ADComputers)

$script:AutoChart06ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart06ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart06ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart06ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06ADComputersOverallDataResults.count))                
    $script:AutoChart06ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart06ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06ADComputersTrimOffFirstTrackBarValue = $script:AutoChart06ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart06ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
        $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}    
    })
    $script:AutoChart06ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart06ADComputersTrimOffFirstTrackBar)
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart06ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart06ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart06ADComputersOverallDataResults.count))
    $script:AutoChart06ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart06ADComputersOverallDataResults.count)
    $script:AutoChart06ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart06ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06ADComputersTrimOffLastTrackBarValue = $($script:AutoChart06ADComputersOverallDataResults.count) - $script:AutoChart06ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart06ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06ADComputersOverallDataResults.count) - $script:AutoChart06ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
        $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    })
$script:AutoChart06ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart06ADComputersTrimOffLastTrackBar)
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart06ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart06ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart06ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADComputers.Series["Enabled"].ChartType = $script:AutoChart06ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
#    $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
})
$script:AutoChart06ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ADComputersChartTypesAvailable) { $script:AutoChart06ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputersChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart06ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06ADComputersChartTypeComboBox.Location.X + $script:AutoChart06ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart06ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart06ADComputers3DToggleButton
$script:AutoChart06ADComputers3DInclination = 0
$script:AutoChart06ADComputers3DToggleButton.Add_Click({
    $script:AutoChart06ADComputers3DInclination += 10
    if ( $script:AutoChart06ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart06ADComputersArea.Area3DStyle.Inclination = $script:AutoChart06ADComputers3DInclination
        $script:AutoChart06ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart06ADComputers3DInclination)"
#        $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
#        $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart06ADComputers3DInclination -le 90 ) {
        $script:AutoChart06ADComputersArea.Area3DStyle.Inclination = $script:AutoChart06ADComputers3DInclination
        $script:AutoChart06ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart06ADComputers3DInclination)" 
#        $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
#        $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart06ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart06ADComputers3DInclination = 0
        $script:AutoChart06ADComputersArea.Area3DStyle.Inclination = $script:AutoChart06ADComputers3DInclination
        $script:AutoChart06ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
#        $script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}
    }
})
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart06ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart06ADComputers3DToggleButton.Location.X + $script:AutoChart06ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart06ADComputersColorsAvailable) { $script:AutoChart06ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart06ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart06ADComputers.Series["Enabled"].Color = $script:AutoChart06ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputersChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Enabled' -eq $($script:AutoChart06ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart06ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADComputersImportCsvPosResults) { $script:AutoChart06ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart06ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ADComputersImportCsvPosResults) { $script:AutoChart06ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ADComputersImportCsvNegResults) { $script:AutoChart06ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ADComputersImportCsvPosResults.count))"
    $script:AutoChart06ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart06ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart06ADComputersCheckDiffButton
$script:AutoChart06ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart06ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Enabled' -ExpandProperty 'Enabled' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart06ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06ADComputersInvestDiffDropDownArray) { $script:AutoChart06ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADComputers }})
    $script:AutoChart06ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart06ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart06ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart06ADComputersInvestDiffExecuteButton
    $script:AutoChart06ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06ADComputers }})
    $script:AutoChart06ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart06ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart06ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart06ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart06ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart06ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart06ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart06ADComputersInvestDiffDropDownLabel,$script:AutoChart06ADComputersInvestDiffDropDownComboBox,$script:AutoChart06ADComputersInvestDiffExecuteButton,$script:AutoChart06ADComputersInvestDiffPosResultsLabel,$script:AutoChart06ADComputersInvestDiffPosResultsTextBox,$script:AutoChart06ADComputersInvestDiffNegResultsLabel,$script:AutoChart06ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart06ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart06ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ADComputersManipulationPanel.controls.Add($script:AutoChart06ADComputersCheckDiffButton)
    

$AutoChart06ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart06ADComputersCheckDiffButton.Location.X + $script:AutoChart06ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart06ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Enabledes" -PropertyX "Enabled" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart06ADComputersExpandChartButton
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($AutoChart06ADComputersExpandChartButton)


$script:AutoChart06ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart06ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart06ADComputersCheckDiffButton.Location.Y + $script:AutoChart06ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ADComputersOpenInShell
$script:AutoChart06ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart06ADComputersManipulationPanel.controls.Add($script:AutoChart06ADComputersOpenInShell)


$script:AutoChart06ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06ADComputersOpenInShell.Location.X + $script:AutoChart06ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart06ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ADComputersViewResults
$script:AutoChart06ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart06ADComputersManipulationPanel.controls.Add($script:AutoChart06ADComputersViewResults)


### Save the chart to file
$script:AutoChart06ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart06ADComputersOpenInShell.Location.Y + $script:AutoChart06ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart06ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart06ADComputers -Title $script:AutoChart06ADComputersTitle
})
$script:AutoChart06ADComputersManipulationPanel.controls.Add($script:AutoChart06ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart06ADComputersSaveButton.Location.Y + $script:AutoChart06ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ADComputersManipulationPanel.Controls.Add($script:AutoChart06ADComputersNoticeTextbox)

$script:AutoChart06ADComputers.Series["Enabled"].Points.Clear()
$script:AutoChart06ADComputersOverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06ADComputers.Series["Enabled"].Points.AddXY($_.DataField.Enabled,$_.UniqueCount)}    


















##############################################################################################
# AutoChart07ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart07ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart05ADComputers.Location.X
                  Y = $script:AutoChart05ADComputers.Location.Y + $script:AutoChart05ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart07ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart07ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart07ADComputers.Titles.Add($script:AutoChart07ADComputersTitle)

### Create Charts Area
$script:AutoChart07ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart07ADComputersArea.Name        = 'Chart Area'
$script:AutoChart07ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart07ADComputersArea.AxisX.Interval          = 1
$script:AutoChart07ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart07ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart07ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart07ADComputers.ChartAreas.Add($script:AutoChart07ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart07ADComputers.Series.Add("Created")  
$script:AutoChart07ADComputers.Series["Created"].Created           = $True
$script:AutoChart07ADComputers.Series["Created"].BorderWidth       = 1
$script:AutoChart07ADComputers.Series["Created"].IsVisibleInLegend = $false
$script:AutoChart07ADComputers.Series["Created"].Chartarea         = 'Chart Area'
$script:AutoChart07ADComputers.Series["Created"].Legend            = 'Legend'
$script:AutoChart07ADComputers.Series["Created"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart07ADComputers.Series["Created"]['PieLineColor']   = 'Black'
$script:AutoChart07ADComputers.Series["Created"]['PieLabelStyle']  = 'Outside'
$script:AutoChart07ADComputers.Series["Created"].ChartType         = 'Bar'
$script:AutoChart07ADComputers.Series["Created"].Color             = 'SlateBLue'

        function Generate-AutoChart07ADComputers {
            $script:AutoChart07ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
            $script:AutoChart07ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Created  | Sort-Object Created -Unique

            $script:AutoChartsProgressBar.ForeColor = 'SlateBLue'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart07ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart07ADComputers.Series["Created"].Points.Clear()

            if ($script:AutoChart07ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart07ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart07ADComputersTitle.Text = "Created"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart07ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart07ADComputersUniqueDataFields) {
                    $Count = 0
                    $script:AutoChart07ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Created) -eq $DataField.Created) {
                            $Count += 1
                            if ( $script:AutoChart07ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart07ADComputersCsvComputers += $($Line.Name) }                        
                        }
                    }
                    $script:AutoChart07ADComputersUniqueCount = $script:AutoChart07ADComputersCsvComputers.Count
                    $script:AutoChart07ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart07ADComputersUniqueCount
                        Computers   = $script:AutoChart07ADComputersCsvComputers 
                    }
                    $script:AutoChart07ADComputersOverallDataResults += $script:AutoChart07ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | ForEach-Object { $script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount) }

                $script:AutoChart07ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ADComputersOverallDataResults.count))
                $script:AutoChart07ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart07ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart07ADComputersTitle.Text = "Created`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart07ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart07ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart07ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart07ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07ADComputersOptionsButton
$script:AutoChart07ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart07ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart07ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart07ADComputers.Controls.Add($script:AutoChart07ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart07ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart07ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart07ADComputers.Controls.Remove($script:AutoChart07ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart07ADComputers)

$script:AutoChart07ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart07ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart07ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart07ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart07ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart07ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart07ADComputersOverallDataResults.count))                
    $script:AutoChart07ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart07ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart07ADComputersTrimOffFirstTrackBarValue = $script:AutoChart07ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart07ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart07ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
        $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}    
    })
    $script:AutoChart07ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart07ADComputersTrimOffFirstTrackBar)
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart07ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart07ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart07ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 5)
                     Y = $script:AutoChart07ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart07ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart07ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart07ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart07ADComputersOverallDataResults.count))
    $script:AutoChart07ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart07ADComputersOverallDataResults.count)
    $script:AutoChart07ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart07ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart07ADComputersTrimOffLastTrackBarValue = $($script:AutoChart07ADComputersOverallDataResults.count) - $script:AutoChart07ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart07ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart07ADComputersOverallDataResults.count) - $script:AutoChart07ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
        $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    })
$script:AutoChart07ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart07ADComputersTrimOffLastTrackBar)
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart07ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart07ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart07ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart07ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ADComputers.Series["Created"].ChartType = $script:AutoChart07ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
#    $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
})
$script:AutoChart07ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart07ADComputersChartTypesAvailable) { $script:AutoChart07ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputersChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart07ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart07ADComputersChartTypeComboBox.Location.X + $script:AutoChart07ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart07ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart07ADComputers3DToggleButton
$script:AutoChart07ADComputers3DInclination = 0
$script:AutoChart07ADComputers3DToggleButton.Add_Click({
    $script:AutoChart07ADComputers3DInclination += 10
    if ( $script:AutoChart07ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart07ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart07ADComputersArea.Area3DStyle.Inclination = $script:AutoChart07ADComputers3DInclination
        $script:AutoChart07ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart07ADComputers3DInclination)"
#        $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
#        $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart07ADComputers3DInclination -le 90 ) {
        $script:AutoChart07ADComputersArea.Area3DStyle.Inclination = $script:AutoChart07ADComputers3DInclination
        $script:AutoChart07ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart07ADComputers3DInclination)" 
#        $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
#        $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart07ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart07ADComputers3DInclination = 0
        $script:AutoChart07ADComputersArea.Area3DStyle.Inclination = $script:AutoChart07ADComputers3DInclination
        $script:AutoChart07ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart07ADComputers.Series["Created"].Points.Clear()
#        $script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}
    }
})
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart07ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart07ADComputers3DToggleButton.Location.X + $script:AutoChart07ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart07ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart07ADComputersColorsAvailable) { $script:AutoChart07ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart07ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart07ADComputers.Series["Created"].Color = $script:AutoChart07ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputersChangeColorComboBox)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart07ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart07ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Created' -eq $($script:AutoChart07ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart07ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ADComputersImportCsvPosResults) { $script:AutoChart07ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart07ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart07ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart07ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart07ADComputersImportCsvPosResults) { $script:AutoChart07ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart07ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart07ADComputersImportCsvNegResults) { $script:AutoChart07ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart07ADComputersImportCsvPosResults.count))"
    $script:AutoChart07ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart07ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart07ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart07ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart07ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5)  }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart07ADComputersCheckDiffButton
$script:AutoChart07ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart07ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Created' -ExpandProperty 'Created' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart07ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart07ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart07ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart07ADComputersInvestDiffDropDownArray) { $script:AutoChart07ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart07ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ADComputers }})
    $script:AutoChart07ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart07ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart07ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart07ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart07ADComputersInvestDiffExecuteButton
    $script:AutoChart07ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart07ADComputers }})
    $script:AutoChart07ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart07ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart07ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart07ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart07ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart07ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart07ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart07ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart07ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart07ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart07ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart07ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart07ADComputersInvestDiffDropDownLabel,$script:AutoChart07ADComputersInvestDiffDropDownComboBox,$script:AutoChart07ADComputersInvestDiffExecuteButton,$script:AutoChart07ADComputersInvestDiffPosResultsLabel,$script:AutoChart07ADComputersInvestDiffPosResultsTextBox,$script:AutoChart07ADComputersInvestDiffNegResultsLabel,$script:AutoChart07ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart07ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart07ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart07ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart07ADComputersManipulationPanel.controls.Add($script:AutoChart07ADComputersCheckDiffButton)
    

$AutoChart07ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart07ADComputersCheckDiffButton.Location.X + $script:AutoChart07ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart07ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Createdes" -PropertyX "Created" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart07ADComputersExpandChartButton
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($AutoChart07ADComputersExpandChartButton)


$script:AutoChart07ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart07ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart07ADComputersCheckDiffButton.Location.Y + $script:AutoChart07ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ADComputersOpenInShell
$script:AutoChart07ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart07ADComputersManipulationPanel.controls.Add($script:AutoChart07ADComputersOpenInShell)


$script:AutoChart07ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart07ADComputersOpenInShell.Location.X + $script:AutoChart07ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart07ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ADComputersViewResults
$script:AutoChart07ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart07ADComputersManipulationPanel.controls.Add($script:AutoChart07ADComputersViewResults)


### Save the chart to file
$script:AutoChart07ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart07ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart07ADComputersOpenInShell.Location.Y + $script:AutoChart07ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart07ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart07ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart07ADComputers -Title $script:AutoChart07ADComputersTitle
})
$script:AutoChart07ADComputersManipulationPanel.controls.Add($script:AutoChart07ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart07ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart07ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart07ADComputersSaveButton.Location.Y + $script:AutoChart07ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart07ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Created     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart07ADComputersManipulationPanel.Controls.Add($script:AutoChart07ADComputersNoticeTextbox)

$script:AutoChart07ADComputers.Series["Created"].Points.Clear()
$script:AutoChart07ADComputersOverallDataResults | Sort-Object { $_.DataField.Created -as [datetime] } | Select-Object -skip $script:AutoChart07ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart07ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart07ADComputers.Series["Created"].Points.AddXY($_.DataField.Created,$_.UniqueCount)}    





















##############################################################################################
# AutoChart08ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart08ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart06ADComputers.Location.X
                  Y = $script:AutoChart06ADComputers.Location.Y + $script:AutoChart06ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart08ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart08ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart08ADComputers.Titles.Add($script:AutoChart08ADComputersTitle)

### Create Charts Area
$script:AutoChart08ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart08ADComputersArea.Name        = 'Chart Area'
$script:AutoChart08ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart08ADComputersArea.AxisX.Interval          = 1
$script:AutoChart08ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart08ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart08ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart08ADComputers.ChartAreas.Add($script:AutoChart08ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart08ADComputers.Series.Add("Modified")
$script:AutoChart08ADComputers.Series["Modified"].Enabled           = $True
$script:AutoChart08ADComputers.Series["Modified"].BorderWidth       = 1
$script:AutoChart08ADComputers.Series["Modified"].IsVisibleInLegend = $false
$script:AutoChart08ADComputers.Series["Modified"].Chartarea         = 'Chart Area'
$script:AutoChart08ADComputers.Series["Modified"].Legend            = 'Legend'
$script:AutoChart08ADComputers.Series["Modified"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart08ADComputers.Series["Modified"]['PieLineColor']   = 'Black'
$script:AutoChart08ADComputers.Series["Modified"]['PieLabelStyle']  = 'Outside'
$script:AutoChart08ADComputers.Series["Modified"].ChartType         = 'Bar'
$script:AutoChart08ADComputers.Series["Modified"].Color             = 'Purple'

        function Generate-AutoChart08ADComputers {
            $script:AutoChart08ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart08ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object Modified | Sort-Object Modified -unique
            $script:AutoChartsProgressBar.ForeColor = 'Purple'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart08ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()

            if ($script:AutoChart08ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart08ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart08ADComputersTitle.Text = "Modified"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart08ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart08ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart08ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.Modified) -eq $DataField.Modified) {
                            $Count += 1
                            if ( $script:AutoChart08ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart08ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart08ADComputersUniqueCount = $script:AutoChart08ADComputersCsvComputers.Count
                    $script:AutoChart08ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart08ADComputersUniqueCount
                        Computers   = $script:AutoChart08ADComputersCsvComputers 
                    }
                    $script:AutoChart08ADComputersOverallDataResults += $script:AutoChart08ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | ForEach-Object { $script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount) }
                $script:AutoChart08ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ADComputersOverallDataResults.count))
                $script:AutoChart08ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart08ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart08ADComputersTitle.Text = "Modified`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart08ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart08ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart08ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart08ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08ADComputersOptionsButton
$script:AutoChart08ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart08ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart08ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart08ADComputers.Controls.Add($script:AutoChart08ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart08ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart08ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart08ADComputers.Controls.Remove($script:AutoChart08ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart08ADComputers)


$script:AutoChart08ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart08ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart08ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart08ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart08ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart08ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart08ADComputersOverallDataResults.count))                
    $script:AutoChart08ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart08ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart08ADComputersTrimOffFirstTrackBarValue = $script:AutoChart08ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart08ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart08ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
        $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
    $script:AutoChart08ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart08ADComputersTrimOffFirstTrackBar)
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart08ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart08ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart08ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart08ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart08ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart08ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart08ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart08ADComputersOverallDataResults.count))
    $script:AutoChart08ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart08ADComputersOverallDataResults.count)
    $script:AutoChart08ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart08ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart08ADComputersTrimOffLastTrackBarValue = $($script:AutoChart08ADComputersOverallDataResults.count) - $script:AutoChart08ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart08ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart08ADComputersOverallDataResults.count) - $script:AutoChart08ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
        $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    })
$script:AutoChart08ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart08ADComputersTrimOffLastTrackBar)
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart08ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart08ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart08ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart08ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ADComputers.Series["Modified"].ChartType = $script:AutoChart08ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
#    $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
})
$script:AutoChart08ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart08ADComputersChartTypesAvailable) { $script:AutoChart08ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart08ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart08ADComputersChartTypeComboBox.Location.X + $script:AutoChart08ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart08ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart08ADComputers3DToggleButton
$script:AutoChart08ADComputers3DInclination = 0
$script:AutoChart08ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart08ADComputers3DInclination += 10
    if ( $script:AutoChart08ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart08ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart08ADComputersArea.Area3DStyle.Inclination = $script:AutoChart08ADComputers3DInclination
        $script:AutoChart08ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart08ADComputers3DInclination)"
#        $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
#        $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart08ADComputers3DInclination -le 90 ) {
        $script:AutoChart08ADComputersArea.Area3DStyle.Inclination = $script:AutoChart08ADComputers3DInclination
        $script:AutoChart08ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart08ADComputers3DInclination)" 
#        $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
#        $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart08ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart08ADComputers3DInclination = 0
        $script:AutoChart08ADComputersArea.Area3DStyle.Inclination = $script:AutoChart08ADComputers3DInclination
        $script:AutoChart08ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
#        $script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}
    }
})
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart08ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart08ADComputers3DToggleButton.Location.X + $script:AutoChart08ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart08ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart08ADComputersColorsAvailable) { $script:AutoChart08ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart08ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart08ADComputers.Series["Modified"].Color = $script:AutoChart08ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart08ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart08ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'Modified' -eq $($script:AutoChart08ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart08ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ADComputersImportCsvPosResults) { $script:AutoChart08ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart08ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart08ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart08ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart08ADComputersImportCsvPosResults) { $script:AutoChart08ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart08ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart08ADComputersImportCsvNegResults) { $script:AutoChart08ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart08ADComputersImportCsvPosResults.count))"
    $script:AutoChart08ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart08ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart08ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart08ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart08ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart08ADComputersCheckDiffButton
$script:AutoChart08ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart08ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'Modified' -ExpandProperty 'Modified' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart08ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart08ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart08ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart08ADComputersInvestDiffDropDownArray) { $script:AutoChart08ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart08ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ADComputers }})
    $script:AutoChart08ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart08ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart08ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart08ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart08ADComputersInvestDiffExecuteButton
    $script:AutoChart08ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart08ADComputers }})
    $script:AutoChart08ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart08ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart08ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart08ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart08ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart08ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart08ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart08ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart08ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart08ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart08ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart08ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart08ADComputersInvestDiffDropDownLabel,$script:AutoChart08ADComputersInvestDiffDropDownComboBox,$script:AutoChart08ADComputersInvestDiffExecuteButton,$script:AutoChart08ADComputersInvestDiffPosResultsLabel,$script:AutoChart08ADComputersInvestDiffPosResultsTextBox,$script:AutoChart08ADComputersInvestDiffNegResultsLabel,$script:AutoChart08ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart08ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart08ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart08ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart08ADComputersManipulationPanel.controls.Add($script:AutoChart08ADComputersCheckDiffButton)


$AutoChart08ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart08ADComputersCheckDiffButton.Location.X + $script:AutoChart08ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart08ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "Modified" -PropertyX "Modified" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart08ADComputersExpandChartButton
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($AutoChart08ADComputersExpandChartButton)


$script:AutoChart08ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart08ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart08ADComputersCheckDiffButton.Location.Y + $script:AutoChart08ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ADComputersOpenInShell
$script:AutoChart08ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart08ADComputersManipulationPanel.controls.Add($script:AutoChart08ADComputersOpenInShell)


$script:AutoChart08ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart08ADComputersOpenInShell.Location.X + $script:AutoChart08ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart08ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ADComputersViewResults
$script:AutoChart08ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart08ADComputersManipulationPanel.controls.Add($script:AutoChart08ADComputersViewResults)


### Save the chart to file
$script:AutoChart08ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart08ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart08ADComputersOpenInShell.Location.Y + $script:AutoChart08ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart08ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart08ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart08ADComputers -Title $script:AutoChart08ADComputersTitle
})
$script:AutoChart08ADComputersManipulationPanel.controls.Add($script:AutoChart08ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart08ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart08ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart08ADComputersSaveButton.Location.Y + $script:AutoChart08ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart08ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart08ADComputersManipulationPanel.Controls.Add($script:AutoChart08ADComputersNoticeTextbox)

$script:AutoChart08ADComputers.Series["Modified"].Points.Clear()
$script:AutoChart08ADComputersOverallDataResults | Sort-Object { $_.DataField.Modified -as [datetime] } | Select-Object -skip $script:AutoChart08ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart08ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart08ADComputers.Series["Modified"].Points.AddXY($_.DataField.Modified,$_.UniqueCount)}


















##############################################################################################
# AutoChart09ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart09ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart07ADComputers.Location.X
                  Y = $script:AutoChart07ADComputers.Location.Y + $script:AutoChart07ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart09ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart09ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart09ADComputers.Titles.Add($script:AutoChart09ADComputersTitle)

### Create Charts Area
$script:AutoChart09ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart09ADComputersArea.Name        = 'Chart Area'
$script:AutoChart09ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart09ADComputersArea.AxisX.Interval          = 1
$script:AutoChart09ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart09ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart09ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart09ADComputers.ChartAreas.Add($script:AutoChart09ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart09ADComputers.Series.Add("LastLogonDate")
$script:AutoChart09ADComputers.Series["LastLogonDate"].Enabled           = $True
$script:AutoChart09ADComputers.Series["LastLogonDate"].BorderWidth       = 1
$script:AutoChart09ADComputers.Series["LastLogonDate"].IsVisibleInLegend = $false
$script:AutoChart09ADComputers.Series["LastLogonDate"].Chartarea         = 'Chart Area'
$script:AutoChart09ADComputers.Series["LastLogonDate"].Legend            = 'Legend'
$script:AutoChart09ADComputers.Series["LastLogonDate"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart09ADComputers.Series["LastLogonDate"]['PieLineColor']   = 'Black'
$script:AutoChart09ADComputers.Series["LastLogonDate"]['PieLabelStyle']  = 'Outside'
$script:AutoChart09ADComputers.Series["LastLogonDate"].ChartType         = 'Bar'
$script:AutoChart09ADComputers.Series["LastLogonDate"].Color             = 'Yellow'

        function Generate-AutoChart09ADComputers {
            $script:AutoChart09ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart09ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object LastLogonDate | Sort-Object LastLogonDate -unique
            $script:AutoChartsProgressBar.ForeColor = 'Yellow'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart09ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()

            if ($script:AutoChart09ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart09ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart09ADComputersTitle.Text = "Last Logon Date"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart09ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart09ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart09ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.LastLogonDate) -eq $DataField.LastLogonDate) {
                            $Count += 1
                            if ( $script:AutoChart09ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart09ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart09ADComputersUniqueCount = $script:AutoChart09ADComputersCsvComputers.Count
                    $script:AutoChart09ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart09ADComputersUniqueCount
                        Computers   = $script:AutoChart09ADComputersCsvComputers 
                    }
                    $script:AutoChart09ADComputersOverallDataResults += $script:AutoChart09ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | ForEach-Object { $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount) }
                $script:AutoChart09ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ADComputersOverallDataResults.count))
                $script:AutoChart09ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart09ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart09ADComputersTitle.Text = "LastLogonDate`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart09ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart09ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart09ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart09ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09ADComputersOptionsButton
$script:AutoChart09ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart09ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart09ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart09ADComputers.Controls.Add($script:AutoChart09ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart09ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart09ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart09ADComputers.Controls.Remove($script:AutoChart09ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart09ADComputers)


$script:AutoChart09ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart09ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart09ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart09ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart09ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart09ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart09ADComputersOverallDataResults.count))                
    $script:AutoChart09ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart09ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart09ADComputersTrimOffFirstTrackBarValue = $script:AutoChart09ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart09ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart09ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
        $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    })
    $script:AutoChart09ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart09ADComputersTrimOffFirstTrackBar)
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart09ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart09ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart09ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart09ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart09ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart09ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart09ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart09ADComputersOverallDataResults.count))
    $script:AutoChart09ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart09ADComputersOverallDataResults.count)
    $script:AutoChart09ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart09ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart09ADComputersTrimOffLastTrackBarValue = $($script:AutoChart09ADComputersOverallDataResults.count) - $script:AutoChart09ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart09ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart09ADComputersOverallDataResults.count) - $script:AutoChart09ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
        $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    })
$script:AutoChart09ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart09ADComputersTrimOffLastTrackBar)
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart09ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart09ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart09ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart09ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ADComputers.Series["LastLogonDate"].ChartType = $script:AutoChart09ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
#    $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
})
$script:AutoChart09ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart09ADComputersChartTypesAvailable) { $script:AutoChart09ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart09ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart09ADComputersChartTypeComboBox.Location.X + $script:AutoChart09ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart09ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart09ADComputers3DToggleButton
$script:AutoChart09ADComputers3DInclination = 0
$script:AutoChart09ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart09ADComputers3DInclination += 10
    if ( $script:AutoChart09ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart09ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart09ADComputersArea.Area3DStyle.Inclination = $script:AutoChart09ADComputers3DInclination
        $script:AutoChart09ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart09ADComputers3DInclination)"
#        $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
#        $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart09ADComputers3DInclination -le 90 ) {
        $script:AutoChart09ADComputersArea.Area3DStyle.Inclination = $script:AutoChart09ADComputers3DInclination
        $script:AutoChart09ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart09ADComputers3DInclination)" 
#        $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
#        $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart09ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart09ADComputers3DInclination = 0
        $script:AutoChart09ADComputersArea.Area3DStyle.Inclination = $script:AutoChart09ADComputers3DInclination
        $script:AutoChart09ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
#        $script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}
    }
})
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart09ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart09ADComputers3DToggleButton.Location.X + $script:AutoChart09ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart09ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart09ADComputersColorsAvailable) { $script:AutoChart09ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart09ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart09ADComputers.Series["LastLogonDate"].Color = $script:AutoChart09ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart09ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart09ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'LastLogonDate' -eq $($script:AutoChart09ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart09ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ADComputersImportCsvPosResults) { $script:AutoChart09ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart09ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart09ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart09ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart09ADComputersImportCsvPosResults) { $script:AutoChart09ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart09ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart09ADComputersImportCsvNegResults) { $script:AutoChart09ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart09ADComputersImportCsvPosResults.count))"
    $script:AutoChart09ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart09ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart09ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart09ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart09ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart09ADComputersCheckDiffButton
$script:AutoChart09ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart09ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'LastLogonDate' -ExpandProperty 'LastLogonDate' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart09ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart09ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart09ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart09ADComputersInvestDiffDropDownArray) { $script:AutoChart09ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart09ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ADComputers }})
    $script:AutoChart09ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart09ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart09ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart09ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart09ADComputersInvestDiffExecuteButton
    $script:AutoChart09ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart09ADComputers }})
    $script:AutoChart09ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart09ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart09ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart09ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart09ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart09ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart09ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart09ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart09ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart09ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart09ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart09ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart09ADComputersInvestDiffDropDownLabel,$script:AutoChart09ADComputersInvestDiffDropDownComboBox,$script:AutoChart09ADComputersInvestDiffExecuteButton,$script:AutoChart09ADComputersInvestDiffPosResultsLabel,$script:AutoChart09ADComputersInvestDiffPosResultsTextBox,$script:AutoChart09ADComputersInvestDiffNegResultsLabel,$script:AutoChart09ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart09ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart09ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart09ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart09ADComputersManipulationPanel.controls.Add($script:AutoChart09ADComputersCheckDiffButton)


$AutoChart09ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart09ADComputersCheckDiffButton.Location.X + $script:AutoChart09ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart09ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "LastLogonDate" -PropertyX "LastLogonDate" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart09ADComputersExpandChartButton
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($AutoChart09ADComputersExpandChartButton)


$script:AutoChart09ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart09ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart09ADComputersCheckDiffButton.Location.Y + $script:AutoChart09ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ADComputersOpenInShell
$script:AutoChart09ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart09ADComputersManipulationPanel.controls.Add($script:AutoChart09ADComputersOpenInShell)


$script:AutoChart09ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart09ADComputersOpenInShell.Location.X + $script:AutoChart09ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart09ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ADComputersViewResults
$script:AutoChart09ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart09ADComputersManipulationPanel.controls.Add($script:AutoChart09ADComputersViewResults)


### Save the chart to file
$script:AutoChart09ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart09ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart09ADComputersOpenInShell.Location.Y + $script:AutoChart09ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart09ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart09ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart09ADComputers -Title $script:AutoChart09ADComputersTitle
})
$script:AutoChart09ADComputersManipulationPanel.controls.Add($script:AutoChart09ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart09ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart09ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart09ADComputersSaveButton.Location.Y + $script:AutoChart09ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart09ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart09ADComputersManipulationPanel.Controls.Add($script:AutoChart09ADComputersNoticeTextbox)

$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.Clear()
$script:AutoChart09ADComputersOverallDataResults | Sort-Object { $_.DataField.LastLogonDate -as [datetime] } | Select-Object -skip $script:AutoChart09ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart09ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart09ADComputers.Series["LastLogonDate"].Points.AddXY($_.DataField.LastLogonDate,$_.UniqueCount)}


















##############################################################################################
# AutoChart10ADComputers
##############################################################################################

### Auto Create Charts Object
$script:AutoChart10ADComputers = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = $script:AutoChart08ADComputers.Location.X
                  Y = $script:AutoChart08ADComputers.Location.Y + $script:AutoChart08ADComputers.Size.Height + $($FormScale * 20) }
    Size     = @{ Width  = $FormScale * 560
                  Height = $FormScale * 375 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
    BorderDashStyle = 'Solid'
}
$script:AutoChart10ADComputers.Add_MouseHover({ Close-AllOptions })

### Auto Create Charts Title 
$script:AutoChart10ADComputersTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart10ADComputers.Titles.Add($script:AutoChart10ADComputersTitle)

### Create Charts Area
$script:AutoChart10ADComputersArea             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart10ADComputersArea.Name        = 'Chart Area'
$script:AutoChart10ADComputersArea.AxisX.Title = 'Hosts'
$script:AutoChart10ADComputersArea.AxisX.Interval          = 1
$script:AutoChart10ADComputersArea.AxisY.IntervalAutoMode  = $true
$script:AutoChart10ADComputersArea.Area3DStyle.Enable3D    = $false
$script:AutoChart10ADComputersArea.Area3DStyle.Inclination = 75
$script:AutoChart10ADComputers.ChartAreas.Add($script:AutoChart10ADComputersArea)

### Auto Create Charts Data Series Recent
$script:AutoChart10ADComputers.Series.Add("PasswordLastSet")
$script:AutoChart10ADComputers.Series["PasswordLastSet"].Enabled           = $True
$script:AutoChart10ADComputers.Series["PasswordLastSet"].BorderWidth       = 1
$script:AutoChart10ADComputers.Series["PasswordLastSet"].IsVisibleInLegend = $false
$script:AutoChart10ADComputers.Series["PasswordLastSet"].Chartarea         = 'Chart Area'
$script:AutoChart10ADComputers.Series["PasswordLastSet"].Legend            = 'Legend'
$script:AutoChart10ADComputers.Series["PasswordLastSet"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart10ADComputers.Series["PasswordLastSet"]['PieLineColor']   = 'Black'
$script:AutoChart10ADComputers.Series["PasswordLastSet"]['PieLabelStyle']  = 'Outside'
$script:AutoChart10ADComputers.Series["PasswordLastSet"].ChartType         = 'Bar'
$script:AutoChart10ADComputers.Series["PasswordLastSet"].Color             = 'Red'

        function Generate-AutoChart10ADComputers {
            $script:AutoChart10ADComputersCsvFileHosts      = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name
            $script:AutoChart10ADComputersUniqueDataFields  = $script:AutoChartDataSourceCsv | Select-Object PasswordLastSet | Sort-Object PasswordLastSet -unique
            $script:AutoChartsProgressBar.ForeColor = 'Red'
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart10ADComputersUniqueDataFields.count
            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Update()

            $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()

            if ($script:AutoChart10ADComputersUniqueDataFields.count -gt 0){
                $script:AutoChart10ADComputersTitle.ForeColor = 'Black'
                $script:AutoChart10ADComputersTitle.Text = "Password Last Set"

                # If the Second field/Y Axis equals Name, it counts it
                $script:AutoChart10ADComputersOverallDataResults = @()

                # Generates and Counts the data - Counts the number of times that any given property possess a given value
                foreach ($DataField in $script:AutoChart10ADComputersUniqueDataFields) {
                    $Count        = 0
                    $script:AutoChart10ADComputersCsvComputers = @()
                    foreach ( $Line in $script:AutoChartDataSourceCsv ) {
                        if ($($Line.PasswordLastSet) -eq $DataField.PasswordLastSet) {
                            $Count += 1
                            if ( $script:AutoChart10ADComputersCsvComputers -notcontains $($Line.Name) ) { $script:AutoChart10ADComputersCsvComputers += $($Line.Name) }
                        }
                    }
                    $script:AutoChart10ADComputersUniqueCount = $script:AutoChart10ADComputersCsvComputers.Count
                    $script:AutoChart10ADComputersDataResults = New-Object PSObject -Property @{
                        DataField   = $DataField
                        TotalCount  = $Count
                        UniqueCount = $script:AutoChart10ADComputersUniqueCount
                        Computers   = $script:AutoChart10ADComputersCsvComputers 
                    }
                    $script:AutoChart10ADComputersOverallDataResults += $script:AutoChart10ADComputersDataResults
                    $script:AutoChartsProgressBar.Value += 1
                    $script:AutoChartsProgressBar.Update()
                }
                $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | ForEach-Object { $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount) }
                $script:AutoChart10ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ADComputersOverallDataResults.count))
                $script:AutoChart10ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ADComputersOverallDataResults.count))
            }
            else {
                $script:AutoChart10ADComputersTitle.ForeColor = 'Red'
                $script:AutoChart10ADComputersTitle.Text = "PasswordLastSet`n
[ No Data Available ]`n"                
            }
        }
        Generate-AutoChart10ADComputers

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart10ADComputersOptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Options v"
    Location  = @{ X = $script:AutoChart10ADComputers.Location.X + $($FormScale * 5)
                   Y = $script:AutoChart10ADComputers.Location.Y + $($FormScale * 350) }
    Size      = @{ Width  = $FormScale * 75
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10ADComputersOptionsButton
$script:AutoChart10ADComputersOptionsButton.Add_Click({  
    if ($script:AutoChart10ADComputersOptionsButton.Text -eq 'Options v') {
        $script:AutoChart10ADComputersOptionsButton.Text = 'Options ^'
        $script:AutoChart10ADComputers.Controls.Add($script:AutoChart10ADComputersManipulationPanel)
    }
    elseif ($script:AutoChart10ADComputersOptionsButton.Text -eq 'Options ^') {
        $script:AutoChart10ADComputersOptionsButton.Text = 'Options v'
        $script:AutoChart10ADComputers.Controls.Remove($script:AutoChart10ADComputersManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ADComputersOptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart10ADComputers)


$script:AutoChart10ADComputersManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = $script:AutoChart10ADComputers.Size.Height - $($FormScale * 121) }
    Size        = @{ Width  = $script:AutoChart10ADComputers.Size.Width
                     Height = $FormScale * 121 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart10ADComputersTrimOffFirstGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = $FormScale * 5
                     Y = $FormScale * 5 }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart10ADComputersTrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
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
    $script:AutoChart10ADComputersTrimOffFirstTrackBar.SetRange(0, $($script:AutoChart10ADComputersOverallDataResults.count))                
    $script:AutoChart10ADComputersTrimOffFirstTrackBarValue   = 0
    $script:AutoChart10ADComputersTrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart10ADComputersTrimOffFirstTrackBarValue = $script:AutoChart10ADComputersTrimOffFirstTrackBar.Value
        $script:AutoChart10ADComputersTrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart10ADComputersTrimOffFirstTrackBar.Value)"
        $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
        $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    })
    $script:AutoChart10ADComputersTrimOffFirstGroupBox.Controls.Add($script:AutoChart10ADComputersTrimOffFirstTrackBar)
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputersTrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart10ADComputersTrimOffLastGroupBoX = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart10ADComputersTrimOffFirstGroupBox.Location.X + $script:AutoChart10ADComputersTrimOffFirstGroupBox.Size.Width + $($FormScale * 8)
                     Y = $script:AutoChart10ADComputersTrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = $FormScale * 165
                     Height = $FormScale * 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart10ADComputersTrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = $FormScale * 1
                           Y = $FormScale * 30 }
        Size          = @{ Width  = $FormScale * 160
                           Height = $FormScale * 25}                
        Orientation   = "Horizontal"
        TickFrequencY = $FormScale * 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart10ADComputersTrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart10ADComputersTrimOffLastTrackBar.SetRange(0, $($script:AutoChart10ADComputersOverallDataResults.count))
    $script:AutoChart10ADComputersTrimOffLastTrackBar.Value         = $($script:AutoChart10ADComputersOverallDataResults.count)
    $script:AutoChart10ADComputersTrimOffLastTrackBarValue   = 0
    $script:AutoChart10ADComputersTrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart10ADComputersTrimOffLastTrackBarValue = $($script:AutoChart10ADComputersOverallDataResults.count) - $script:AutoChart10ADComputersTrimOffLastTrackBar.Value
        $script:AutoChart10ADComputersTrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart10ADComputersOverallDataResults.count) - $script:AutoChart10ADComputersTrimOffLastTrackBar.Value)"
        $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
        $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    })
$script:AutoChart10ADComputersTrimOffLastGroupBox.Controls.Add($script:AutoChart10ADComputersTrimOffLastTrackBar)
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputersTrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart10ADComputersChartTypeComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Bar' 
    Location  = @{ X = $script:AutoChart10ADComputersTrimOffFirstGroupBox.Location.X + $($FormScale * 80)
                    Y = $script:AutoChart10ADComputersTrimOffFirstGroupBox.Location.Y + $script:AutoChart10ADComputersTrimOffFirstGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 85
                    Height = $FormScale * 20 }     
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ADComputersChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ADComputers.Series["PasswordLastSet"].ChartType = $script:AutoChart10ADComputersChartTypeComboBox.SelectedItem
#    $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
#    $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
})
$script:AutoChart10ADComputersChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart10ADComputersChartTypesAvailable) { $script:AutoChart10ADComputersChartTypeComboBox.Items.Add($Item) }
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputersChartTypeComboBox)


### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart10ADComputers3DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart10ADComputersChartTypeComboBox.Location.X + $script:AutoChart10ADComputersChartTypeComboBox.Size.Width + $($FormScale * 8)
                   Y = $script:AutoChart10ADComputersChartTypeComboBox.Location.Y }
    Size      = @{ Width  = $FormScale * 65
                   Height = $FormScale * 20 }
}
CommonButtonSettings -Button $script:AutoChart10ADComputers3DToggleButton
$script:AutoChart10ADComputers3DInclination = 0
$script:AutoChart10ADComputers3DToggleButton.Add_Click({
    
    $script:AutoChart10ADComputers3DInclination += 10
    if ( $script:AutoChart10ADComputers3DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart10ADComputersArea.Area3DStyle.Enable3D    = $true
        $script:AutoChart10ADComputersArea.Area3DStyle.Inclination = $script:AutoChart10ADComputers3DInclination
        $script:AutoChart10ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart10ADComputers3DInclination)"
#        $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
#        $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart10ADComputers3DInclination -le 90 ) {
        $script:AutoChart10ADComputersArea.Area3DStyle.Inclination = $script:AutoChart10ADComputers3DInclination
        $script:AutoChart10ADComputers3DToggleButton.Text  = "3D On ($script:AutoChart10ADComputers3DInclination)" 
#        $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
#        $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart10ADComputers3DToggleButton.Text  = "3D Off" 
        $script:AutoChart10ADComputers3DInclination = 0
        $script:AutoChart10ADComputersArea.Area3DStyle.Inclination = $script:AutoChart10ADComputers3DInclination
        $script:AutoChart10ADComputersArea.Area3DStyle.Enable3D    = $false
#        $script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
#        $script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}
    }
})
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputers3DToggleButton)

### Change the color of the chart
$script:AutoChart10ADComputersChangeColorComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Change Color"
    Location  = @{ X = $script:AutoChart10ADComputers3DToggleButton.Location.X + $script:AutoChart10ADComputers3DToggleButton.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADComputers3DToggleButton.Location.Y }
    Size      = @{ Width  = $FormScale * 95
                   Height = $FormScale * 20 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart10ADComputersColorsAvailable = @('Gray','Black','Brown','Red','Orange','Yellow','Green','Blue','Purple')
ForEach ($Item in $script:AutoChart10ADComputersColorsAvailable) { $script:AutoChart10ADComputersChangeColorComboBox.Items.Add($Item) }
$script:AutoChart10ADComputersChangeColorComboBox.add_SelectedIndexChanged({
    $script:AutoChart10ADComputers.Series["PasswordLastSet"].Color = $script:AutoChart10ADComputersChangeColorComboBox.SelectedItem
})
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputersChangeColorComboBox)


#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart10ADComputers {    
    # List of Positive Endpoints that positively match
    $script:AutoChart10ADComputersImportCsvPosResults = $script:AutoChartDataSourceCsv | Where-Object 'PasswordLastSet' -eq $($script:AutoChart10ADComputersInvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty Name -Unique
    $script:AutoChart10ADComputersInvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ADComputersImportCsvPosResults) { $script:AutoChart10ADComputersInvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart10ADComputersImportCsvAll = $script:AutoChartDataSourceCsv | Select-Object -ExpandProperty Name -Unique
    
    $script:AutoChart10ADComputersImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart10ADComputersImportCsvAll) { if ($Endpoint -notin $script:AutoChart10ADComputersImportCsvPosResults) { $script:AutoChart10ADComputersImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart10ADComputersInvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart10ADComputersImportCsvNegResults) { $script:AutoChart10ADComputersInvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart10ADComputersImportCsvPosResults.count))"
    $script:AutoChart10ADComputersInvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart10ADComputersImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart10ADComputersCheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart10ADComputersTrimOffLastGroupBox.Location.X + $script:AutoChart10ADComputersTrimOffLastGroupBox.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADComputersTrimOffLastGroupBox.Location.Y + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
}
CommonButtonSettings -Button $script:AutoChart10ADComputersCheckDiffButton
$script:AutoChart10ADComputersCheckDiffButton.Add_Click({
    $script:AutoChart10ADComputersInvestDiffDropDownArraY = $script:AutoChartDataSourceCsv | Select-Object -Property 'PasswordLastSet' -ExpandProperty 'PasswordLastSet' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart10ADComputersInvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = $FormScale * 330
                    Height = $FormScale * 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        StartPosition = "CenterScreen"
        ControlBoX = $true
        Add_Closing = { $This.dispose() }
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart10ADComputersInvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = $FormScale * 10
                        Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 290
                        Height = $FormScale * 45 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ADComputersInvestDiffDropDownComboBoX = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADComputersInvestDiffDropDownLabel.Location.y + $script:AutoChart10ADComputersInvestDiffDropDownLabel.Size.Height }
        Width    = $FormScale * 290
        Height   = $FormScale * 30
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart10ADComputersInvestDiffDropDownArray) { $script:AutoChart10ADComputersInvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart10ADComputersInvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ADComputers }})
    $script:AutoChart10ADComputersInvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart10ADComputers })

    ### Investigate Difference Execute Button
    $script:AutoChart10ADComputersInvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADComputersInvestDiffDropDownComboBox.Location.y + $script:AutoChart10ADComputersInvestDiffDropDownComboBox.Size.Height + $($FormScale + 5) }
        Width    = $FormScale * 100 
        Height   = $FormScale * 20
    }
    CommonButtonSettings -Button $script:AutoChart10ADComputersInvestDiffExecuteButton
    $script:AutoChart10ADComputersInvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart10ADComputers }})
    $script:AutoChart10ADComputersInvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart10ADComputers })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart10ADComputersInvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADComputersInvestDiffExecuteButton.Location.y + $script:AutoChart10ADComputersInvestDiffExecuteButton.Size.Height + $($FormScale * 10) }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }        
    $script:AutoChart10ADComputersInvestDiffPosResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $FormScale * 10
                        Y = $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Location.y + $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Size.Height }
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
    $script:AutoChart10ADComputersInvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Location.x + $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Size.Width + $($FormScale * 10)
                        Y = $script:AutoChart10ADComputersInvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 22 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:AutoChart10ADComputersInvestDiffNegResultsTextBoX = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart10ADComputersInvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart10ADComputersInvestDiffNegResultsLabel.Location.y + $script:AutoChart10ADComputersInvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = $FormScale * 100
                        Height = $FormScale * 178 }
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart10ADComputersInvestDiffForm.Controls.AddRange(@($script:AutoChart10ADComputersInvestDiffDropDownLabel,$script:AutoChart10ADComputersInvestDiffDropDownComboBox,$script:AutoChart10ADComputersInvestDiffExecuteButton,$script:AutoChart10ADComputersInvestDiffPosResultsLabel,$script:AutoChart10ADComputersInvestDiffPosResultsTextBox,$script:AutoChart10ADComputersInvestDiffNegResultsLabel,$script:AutoChart10ADComputersInvestDiffNegResultsTextBox))
    $script:AutoChart10ADComputersInvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart10ADComputersInvestDiffForm.ShowDialog()
})
$script:AutoChart10ADComputersCheckDiffButton.Add_MouseHover({
Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message @"
+  Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart10ADComputersManipulationPanel.controls.Add($script:AutoChart10ADComputersCheckDiffButton)


$AutoChart10ADComputersExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Multi-Series'
    Location = @{ X = $script:AutoChart10ADComputersCheckDiffButton.Location.X + $script:AutoChart10ADComputersCheckDiffButton.Size.Width + $($FormScale * 5)
                  Y = $script:AutoChart10ADComputersCheckDiffButton.Location.Y }
    Size   = @{ Width  = $FormScale * 100
                Height = $FormScale * 23 }
    Add_Click  = { Generate-AutoChartsCommand -FilePath $script:AutoChartDataSourceCsvFileName -QueryName "Processes" -QueryTabName "PasswordLastSet" -PropertyX "PasswordLastSet" -PropertyY "Name" }
}
CommonButtonSettings -Button $AutoChart10ADComputersExpandChartButton
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($AutoChart10ADComputersExpandChartButton)


$script:AutoChart10ADComputersOpenInShell = New-Object Windows.Forms.Button -Property @{
    Text      = "Open In Shell"
    Location  = @{ X = $script:AutoChart10ADComputersCheckDiffButton.Location.X
                   Y = $script:AutoChart10ADComputersCheckDiffButton.Location.Y + $script:AutoChart10ADComputersCheckDiffButton.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ADComputersOpenInShell
$script:AutoChart10ADComputersOpenInShell.Add_Click({ AutoChartOpenDataInShell }) 
$script:AutoChart10ADComputersManipulationPanel.controls.Add($script:AutoChart10ADComputersOpenInShell)


$script:AutoChart10ADComputersViewResults = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart10ADComputersOpenInShell.Location.X + $script:AutoChart10ADComputersOpenInShell.Size.Width + $($FormScale * 5)
                   Y = $script:AutoChart10ADComputersOpenInShell.Location.Y }
    Size      = @{ Width  = $FormScale * 100
                   Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ADComputersViewResults
$script:AutoChart10ADComputersViewResults.Add_Click({ $script:AutoChartDataSourceCsv | Out-GridView -Title "$script:AutoChartCSVFileMostRecentCollection" }) 
$script:AutoChart10ADComputersManipulationPanel.controls.Add($script:AutoChart10ADComputersViewResults)


### Save the chart to file
$script:AutoChart10ADComputersSaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart10ADComputersOpenInShell.Location.X
                  Y = $script:AutoChart10ADComputersOpenInShell.Location.Y + $script:AutoChart10ADComputersOpenInShell.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 205
                  Height = $FormScale * 23 }
}
CommonButtonSettings -Button $script:AutoChart10ADComputersSaveButton
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart10ADComputersSaveButton.Add_Click({
    Save-ChartImage -Chart $script:AutoChart10ADComputers -Title $script:AutoChart10ADComputersTitle
})
$script:AutoChart10ADComputersManipulationPanel.controls.Add($script:AutoChart10ADComputersSaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart10ADComputersNoticeTextboX = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart10ADComputersSaveButton.Location.X 
                        Y = $script:AutoChart10ADComputersSaveButton.Location.Y + $script:AutoChart10ADComputersSaveButton.Size.Height + $($FormScale * 6) }
    Size        = @{ Width  = $FormScale * 205
                        Height = $FormScale * 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart10ADComputersCsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart10ADComputersManipulationPanel.Controls.Add($script:AutoChart10ADComputersNoticeTextbox)

$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.Clear()
$script:AutoChart10ADComputersOverallDataResults | Sort-Object { $_.DataField.PasswordLastSet -as [datetime] } | Select-Object -skip $script:AutoChart10ADComputersTrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart10ADComputersTrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart10ADComputers.Series["PasswordLastSet"].Points.AddXY($_.DataField.PasswordLastSet,$_.UniqueCount)}

























