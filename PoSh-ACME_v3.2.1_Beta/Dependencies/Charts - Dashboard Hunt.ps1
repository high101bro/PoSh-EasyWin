$CollectedDataDirectory = "$PoShHome\Collected Data"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

### Creates Tabs From Each File
$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = 'Process Info'
    Anchor = $AnchorAll
    Font   = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
    AutoScroll    = $True
}
$AutoChartsTabControl.Controls.Add($script:AutoChartsIndividualTab01)

# Searches though the all Collection Data Directories to find files that match the 'Processes'
$script:ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName










##############################################################################################
# AutoChart01
##############################################################################################

$script:AutoChart01CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Processes') { $script:AutoChart01CSVFileMatch += $CSVFile } }
} 
$script:AutoChart01CSVFileMostRecentCollection = $script:AutoChart01CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart01 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 5
                  Y = 5 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    #Anchor          = $AnchorAll
    
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart01Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Unique Processes'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter"
}
$script:AutoChart01.Titles.Add($script:AutoChart01Title)

### Create Charts Area
$script:AutoChart01Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart01Area.Name        = 'Chart Area'
$script:AutoChart01Area.AxisX.Title = 'Hosts'
$script:AutoChart01Area.AxisX.Interval          = 1
$script:AutoChart01Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart01Area.Area3DStyle.Enable3D    = $false
$script:AutoChart01Area.Area3DStyle.Inclination = 75
$script:AutoChart01.ChartAreas.Add($script:AutoChart01Area)

### Auto Create Charts Data Series Recent
$script:AutoChart01.Series.Add("Unique Processes")  
$script:AutoChart01.Series["Unique Processes"].Enabled           = $True
$script:AutoChart01.Series["Unique Processes"].BorderWidth       = 1
$script:AutoChart01.Series["Unique Processes"].IsVisibleInLegend = $false
$script:AutoChart01.Series["Unique Processes"].Chartarea         = 'Chart Area'
$script:AutoChart01.Series["Unique Processes"].Legend            = 'Legend'
$script:AutoChart01.Series["Unique Processes"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart01.Series["Unique Processes"]['PieLineColor']   = 'Black'
$script:AutoChart01.Series["Unique Processes"]['PieLabelStyle']  = 'Outside'
$script:AutoChart01.Series["Unique Processes"].ChartType         = 'Column'
$script:AutoChart01.Series["Unique Processes"].Color             = 'Red'

            $script:AutoChart01DataSource = Import-Csv $script:AutoChart01CSVFileMostRecentCollection
            $script:AutoChart01CsvFileHosts      = $script:AutoChart01DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart01DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart01UniqueDataFields  = $script:AutoChart01DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            # If the Second field/Y Axis equals PSComputername, it counts it
            $script:AutoChart01OverallDataResults = @()

            # Generates and Counts the data - Counts the number of times that any given property possess a given value
            foreach ($DataField in $script:AutoChart01UniqueDataFields) {
                $Count        = 0
                $script:AutoChart01CsvComputers = @()
                foreach ( $Line in $script:AutoChart01DataSource ) {
                    if ($($Line.Name) -eq $DataField.Name) {
                        $Count += 1
                        if ( $script:AutoChart01CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart01CsvComputers += $($Line.PSComputerName) }                        
                    }
                }
                $script:AutoChart01UniqueCount = $script:AutoChart01CsvComputers.Count
                $script:AutoChart01DataResults = New-Object PSObject -Property @{
                    DataField   = $DataField
                    TotalCount  = $Count
                    UniqueCount = $script:AutoChart01UniqueCount
                    Computers   = $script:AutoChart01CsvComputers 
                }
                $script:AutoChart01OverallDataResults += $script:AutoChart01DataResults
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart01UniqueDataFields.count

            $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
                $script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
                $script:AutoChartsProgressBar.Value += 1
                #Start-Sleep -Milliseconds 1
            }

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart01OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart01.Location.X + 10
                   Y = $script:AutoChart01.Location.Y + 320 }
    Size      = @{ Width  = 125
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart01OptionsButton.Add_Click({  
    if ($script:AutoChart01OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart01OptionsButton.Text = 'Hide Options'
        $script:AutoChart01.Controls.Add($script:AutoChart01ManipulationPanel)
    }
    elseif ($script:AutoChart01OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart01OptionsButton.Text = 'Show Options'
        $script:AutoChart01.Controls.Remove($script:AutoChart01ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart01)

$script:AutoChart01ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart01.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart01TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart01TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart01TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))                
    $script:AutoChart01TrimOffFirstTrackBarValue   = 0
    $script:AutoChart01TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart01TrimOffFirstTrackBarValue = $script:AutoChart01TrimOffFirstTrackBar.Value
        $script:AutoChart01TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart01TrimOffFirstTrackBar.Value)"
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart01TrimOffFirstGroupBox.Controls.Add($script:AutoChart01TrimOffFirstTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart01TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X + $script:AutoChart01TrimOffFirstGroupBox.Size.Width + 10
                     Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                     Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart01TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart01TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart01TrimOffLastTrackBar.SetRange(0, $($script:AutoChart01OverallDataResults.count))
    $script:AutoChart01TrimOffLastTrackBar.Value         = $($script:AutoChart01OverallDataResults.count)
    $script:AutoChart01TrimOffLastTrackBarValue   = 0
    $script:AutoChart01TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart01TrimOffLastTrackBarValue = $($script:AutoChart01OverallDataResults.count) - $script:AutoChart01TrimOffLastTrackBar.Value
        $script:AutoChart01TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart01OverallDataResults.count) - $script:AutoChart01TrimOffLastTrackBar.Value)"
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart01TrimOffLastGroupBox.Controls.Add($script:AutoChart01TrimOffLastTrackBar)
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart01ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart01TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart01TrimOffFirstGroupBox.Location.Y + $script:AutoChart01TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart01ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart01.Series["Unique Processes"].ChartType = $script:AutoChart01ChartTypeComboBox.SelectedItem
    $script:AutoChart01.Series["Unique Processes"].Points.Clear()
    $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart01ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart01ChartTypesAvailable) { $script:AutoChart01ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart013DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart01TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart01TrimOffLastGroupBox.Location.Y + $script:AutoChart01TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart013DInclination = 0
$script:AutoChart013DToggleButton.Add_Click({
    $script:AutoChart013DInclination += 10
    if ( $script:AutoChart013DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)"
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart013DInclination -le 90 ) {
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart013DToggleButton.Text  = "3D On ($script:AutoChart013DInclination)" 
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart013DToggleButton.Text  = "3D Off" 
        $script:AutoChart013DInclination = 0
        $script:AutoChart01Area.Area3DStyle.Inclination = $script:AutoChart013DInclination
        $script:AutoChart01Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart01.Series["Unique Processes"].Points.Clear()
        $script:AutoChart01OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart01TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart01TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart01.Series["Unique Processes"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart013DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart01 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart01ImportCsvPosResults = $script:AutoChart01DataSource | Where-Object 'Name' -eq $($script:AutoChart01InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart01InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart01ImportCsvAll = $script:AutoChart01DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart01ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart01ImportCsvAll) { if ($Endpoint -notin $script:AutoChart01ImportCsvPosResults) { $script:AutoChart01ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart01InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart01ImportCsvNegResults) { $script:AutoChart01InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart01InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart01ImportCsvPosResults.count))"
    $script:AutoChart01InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart01ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart01CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart01TrimOffLastGroupBox.Location.X + $script:AutoChart01TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart01TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart01CheckDiffButton.Add_Click({
    $script:AutoChart01InvestDiffDropDownArray = $script:AutoChart01DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart01InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart01InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart01InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart01InvestDiffDropDownLabel.Location.y + $script:AutoChart01InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart01InvestDiffDropDownArray) { $script:AutoChart01InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart01InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Execute Button
    $script:AutoChart01InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart01InvestDiffDropDownComboBox.Location.y + $script:AutoChart01InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart01InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart01 }})
    $script:AutoChart01InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart01 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart01InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart01InvestDiffExecuteButton.Location.y + $script:AutoChart01InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart01InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y + $script:AutoChart01InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart01InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart01InvestDiffPosResultsLabel.Location.x + $script:AutoChart01InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart01InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart01InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart01InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart01InvestDiffNegResultsLabel.Location.y + $script:AutoChart01InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart01InvestDiffForm.Controls.AddRange(@($script:AutoChart01InvestDiffDropDownLabel,$script:AutoChart01InvestDiffDropDownComboBox,$script:AutoChart01InvestDiffExecuteButton,$script:AutoChart01InvestDiffPosResultsLabel,$script:AutoChart01InvestDiffPosResultsTextBox,$script:AutoChart01InvestDiffNegResultsLabel,$script:AutoChart01InvestDiffNegResultsTextBox))
    $script:AutoChart01InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart01InvestDiffForm.ShowDialog()
})
$script:AutoChart01CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01CheckDiffButton)
    
$script:AutoChart01Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart01CheckDiffButton.Location.X
                   Y = $script:AutoChart01CheckDiffButton.Location.Y + $script:AutoChart01CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart01Results.Add_Click({ $script:AutoChart01DataSource | Out-GridView -Title "$script:AutoChart01CSVFileMostRecentCollection" }) 
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01Results)

### Save the chart to file
$script:AutoChart01SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart01Results.Location.X
                  Y = $script:AutoChart01Results.Location.Y + $script:AutoChart01Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart01SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart01.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart01ManipulationPanel.controls.Add($script:AutoChart01SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart01NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart01SaveButton.Location.X 
                        Y = $script:AutoChart01SaveButton.Location.Y + $script:AutoChart01SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart01CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart01ManipulationPanel.Controls.Add($script:AutoChart01NoticeTextbox)























##############################################################################################
# AutoChart02
##############################################################################################

$script:AutoChart02CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Services') { $script:AutoChart02CSVFileMatch += $CSVFile } }
} 
$script:AutoChart02CSVFileMostRecentCollection = $script:AutoChart02CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart02 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 525
                  Y = 5 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    ##Anchor          = $AnchorAll
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart02Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Running Services'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart02.Titles.Add($script:AutoChart02Title)

### Create Charts Area
$script:AutoChart02Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart02Area.Name        = 'Chart Area'
$script:AutoChart02Area.AxisX.Title = 'Hosts'
$script:AutoChart02Area.AxisX.Interval          = 1
$script:AutoChart02Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart02Area.Area3DStyle.Enable3D    = $false
$script:AutoChart02Area.Area3DStyle.Inclination = 75
$script:AutoChart02.ChartAreas.Add($script:AutoChart02Area)

### Auto Create Charts Data Series Recent
$script:AutoChart02.Series.Add("Running Services")  
$script:AutoChart02.Series["Running Services"].Enabled           = $True
$script:AutoChart02.Series["Running Services"].BorderWidth       = 1
$script:AutoChart02.Series["Running Services"].IsVisibleInLegend = $false
$script:AutoChart02.Series["Running Services"].Chartarea         = 'Chart Area'
$script:AutoChart02.Series["Running Services"].Legend            = 'Legend'
$script:AutoChart02.Series["Running Services"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart02.Series["Running Services"]['PieLineColor']   = 'Black'
$script:AutoChart02.Series["Running Services"]['PieLabelStyle']  = 'Outside'
$script:AutoChart02.Series["Running Services"].ChartType         = 'Column'
$script:AutoChart02.Series["Running Services"].Color             = 'Blue'

$script:AutoChart02DataSource = Import-Csv $script:AutoChart02CSVFileMostRecentCollection
$script:AutoChart02CsvFileHosts      = $script:AutoChart02DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart02DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
$script:AutoChart02UniqueDataFields  = $script:AutoChart02DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

# If the Second field/Y Axis equals PSComputername, it counts it
$script:AutoChart02OverallDataResults = @()

# Generates and Counts the data - Counts the number of times that any given property possess a given value
foreach ($DataField in $script:AutoChart02UniqueDataFields) {
    $Count        = 0
    $script:AutoChart02CsvComputers = @()
    foreach ( $Line in $script:AutoChart02DataSource ) {
        if ($($Line.Name) -eq $DataField.Name) {
            $Count += 1
            if ( $script:AutoChart02CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart02CsvComputers += $($Line.PSComputerName) }                        
        }
    }
    $script:AutoChart02UniqueCount    = $script:AutoChart02CsvComputers.Count
    $script:AutoChart02DataResults    = New-Object PSObject -Property @{
        DataField   = $DataField
        TotalCount  = $Count
        UniqueCount = $script:AutoChart02UniqueCount
        Computers   = $script:AutoChart02CsvComputers 
    }
    $script:AutoChart02OverallDataResults += $script:AutoChart02DataResults
}

$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = $script:AutoChart02UniqueDataFields.count

$script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
    $script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
    $script:AutoChartsProgressBar.Value += 1
    #Start-Sleep -Milliseconds 1
}

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart02OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart02.Location.X + 10
                   Y = $script:AutoChart02.Location.Y + 320 }
    Size      = @{ Width  = 125
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart02OptionsButton.Add_Click({  
    if ($script:AutoChart02OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart02OptionsButton.Text = 'Hide Options'
        $script:AutoChart02.Controls.Add($script:AutoChart02ManipulationPanel)
    }
    elseif ($script:AutoChart02OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart02OptionsButton.Text = 'Show Options'
        $script:AutoChart02.Controls.Remove($script:AutoChart02ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart02)

$script:AutoChart02ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart02.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart02TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart02TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart02TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))                
    $script:AutoChart02TrimOffFirstTrackBarValue   = 0
    $script:AutoChart02TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart02TrimOffFirstTrackBarValue = $script:AutoChart02TrimOffFirstTrackBar.Value
        $script:AutoChart02TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart02TrimOffFirstTrackBar.Value)"
        $script:AutoChart02.Series["Running Services"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart02TrimOffFirstGroupBox.Controls.Add($script:AutoChart02TrimOffFirstTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart02TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X + $script:AutoChart02TrimOffFirstGroupBox.Size.Width + 10
                        Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart02TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart02TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart02TrimOffLastTrackBar.SetRange(0, $($script:AutoChart02OverallDataResults.count))
    $script:AutoChart02TrimOffLastTrackBar.Value         = $($script:AutoChart02OverallDataResults.count)
    $script:AutoChart02TrimOffLastTrackBarValue   = 0
    $script:AutoChart02TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart02TrimOffLastTrackBarValue = $($script:AutoChart02OverallDataResults.count) - $script:AutoChart02TrimOffLastTrackBar.Value
        $script:AutoChart02TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart02OverallDataResults.count) - $script:AutoChart02TrimOffLastTrackBar.Value)"
        $script:AutoChart02.Series["Running Services"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart02TrimOffLastGroupBox.Controls.Add($script:AutoChart02TrimOffLastTrackBar)
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart02ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart02TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart02TrimOffFirstGroupBox.Location.Y + $script:AutoChart02TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart02ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart02.Series["Running Services"].ChartType = $script:AutoChart02ChartTypeComboBox.SelectedItem
    $script:AutoChart02.Series["Running Services"].Points.Clear()
    $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart02ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart02ChartTypesAvailable) { $script:AutoChart02ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart023DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart02TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart02TrimOffLastGroupBox.Location.Y + $script:AutoChart02TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart023DInclination = 0
$script:AutoChart023DToggleButton.Add_Click({
    $script:AutoChart023DInclination += 10
    if ( $script:AutoChart023DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)"
        $script:AutoChart02.Series["Running Services"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart023DInclination -le 90 ) {
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart023DToggleButton.Text  = "3D On ($script:AutoChart023DInclination)" 
        $script:AutoChart02.Series["Running Services"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart023DToggleButton.Text  = "3D Off" 
        $script:AutoChart023DInclination = 0
        $script:AutoChart02Area.Area3DStyle.Inclination = $script:AutoChart023DInclination
        $script:AutoChart02Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart02.Series["Running Services"].Points.Clear()
        $script:AutoChart02OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart02TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart02TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart02.Series["Running Services"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart023DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart02 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart02ImportCsvPosResults = $script:AutoChart02DataSource | Where-Object 'Name' -eq $($script:AutoChart02InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart02InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart02ImportCsvAll = $script:AutoChart02DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart02ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart02ImportCsvAll) { if ($Endpoint -notin $script:AutoChart02ImportCsvPosResults) { $script:AutoChart02ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart02InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart02ImportCsvNegResults) { $script:AutoChart02InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart02InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart02ImportCsvPosResults.count))"
    $script:AutoChart02InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart02ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart02CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart02TrimOffLastGroupBox.Location.X + $script:AutoChart02TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart02TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart02CheckDiffButton.Add_Click({
    $script:AutoChart02InvestDiffDropDownArray = $script:AutoChart02DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart02InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart02InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart02InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart02InvestDiffDropDownLabel.Location.y + $script:AutoChart02InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart02InvestDiffDropDownArray) { $script:AutoChart02InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart02InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Execute Button
    $script:AutoChart02InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart02InvestDiffDropDownComboBox.Location.y + $script:AutoChart02InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart02InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart02 }})
    $script:AutoChart02InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart02 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart02InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart02InvestDiffExecuteButton.Location.y + $script:AutoChart02InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart02InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y + $script:AutoChart02InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart02InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart02InvestDiffPosResultsLabel.Location.x + $script:AutoChart02InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart02InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart02InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart02InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart02InvestDiffNegResultsLabel.Location.y + $script:AutoChart02InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart02InvestDiffForm.Controls.AddRange(@($script:AutoChart02InvestDiffDropDownLabel,$script:AutoChart02InvestDiffDropDownComboBox,$script:AutoChart02InvestDiffExecuteButton,$script:AutoChart02InvestDiffPosResultsLabel,$script:AutoChart02InvestDiffPosResultsTextBox,$script:AutoChart02InvestDiffNegResultsLabel,$script:AutoChart02InvestDiffNegResultsTextBox))
    $script:AutoChart02InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart02InvestDiffForm.ShowDialog()
})
$script:AutoChart02CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02CheckDiffButton)
    
$script:AutoChart02Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart02CheckDiffButton.Location.X
                   Y = $script:AutoChart02CheckDiffButton.Location.Y + $script:AutoChart02CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart02Results.Add_Click({ $script:AutoChart02DataSource | Out-GridView -Title "$script:AutoChart02CSVFileMostRecentCollection" }) 
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02Results)

### Save the chart to file
$script:AutoChart02SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart02Results.Location.X
                    Y = $script:AutoChart02Results.Location.Y + $script:AutoChart02Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart02SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart02.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart02ManipulationPanel.controls.Add($script:AutoChart02SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart02NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart02SaveButton.Location.X 
                        Y = $script:AutoChart02SaveButton.Location.Y + $script:AutoChart02SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart02CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart02ManipulationPanel.Controls.Add($script:AutoChart02NoticeTextbox)




















##############################################################################################
# AutoChart03
##############################################################################################

$script:AutoChart03CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Startup Commands') { $script:AutoChart03CSVFileMatch += $CSVFile } }
} 
$script:AutoChart03CSVFileMostRecentCollection = $script:AutoChart03CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart03 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 5
                  Y = 375 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    ##Anchor          = $AnchorAll
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart03Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Startup Commands'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart03.Titles.Add($script:AutoChart03Title)

### Create Charts Area
$script:AutoChart03Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart03Area.Name        = 'Chart Area'
$script:AutoChart03Area.AxisX.Title = 'Hosts'
$script:AutoChart03Area.AxisX.Interval          = 1
$script:AutoChart03Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart03Area.Area3DStyle.Enable3D    = $false
$script:AutoChart03Area.Area3DStyle.Inclination = 75
$script:AutoChart03.ChartAreas.Add($script:AutoChart03Area)

### Auto Create Charts Data Series Recent
$script:AutoChart03.Series.Add("Startup Commands")  
$script:AutoChart03.Series["Startup Commands"].Enabled           = $True
$script:AutoChart03.Series["Startup Commands"].BorderWidth       = 1
$script:AutoChart03.Series["Startup Commands"].IsVisibleInLegend = $false
$script:AutoChart03.Series["Startup Commands"].Chartarea         = 'Chart Area'
$script:AutoChart03.Series["Startup Commands"].Legend            = 'Legend'
$script:AutoChart03.Series["Startup Commands"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart03.Series["Startup Commands"]['PieLineColor']   = 'Black'
$script:AutoChart03.Series["Startup Commands"]['PieLabelStyle']  = 'Outside'
$script:AutoChart03.Series["Startup Commands"].ChartType         = 'Column'
$script:AutoChart03.Series["Startup Commands"].Color             = 'Green'


            $script:AutoChart03DataSource = Import-Csv $script:AutoChart03CSVFileMostRecentCollection
            $script:AutoChart03CsvFileHosts      = $script:AutoChart03DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart03DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
            $script:AutoChart03UniqueDataFields  = $script:AutoChart03DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

            # If the Second field/Y Axis equals PSComputername, it counts it
            $script:AutoChart03OverallDataResults = @()

            # Generates and Counts the data - Counts the number of times that any given property possess a given value
            foreach ($DataField in $script:AutoChart03UniqueDataFields) {
                $Count        = 0
                $script:AutoChart03CsvComputers = @()
                foreach ( $Line in $script:AutoChart03DataSource ) {
                    if ($($Line.Name) -eq $DataField.Name) {
                        $Count += 1
                        if ( $script:AutoChart03CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart03CsvComputers += $($Line.PSComputerName) }                        
                    }
                }
                $script:AutoChart03UniqueCount    = $script:AutoChart03CsvComputers.Count
                $script:AutoChart03DataResults    = New-Object PSObject -Property @{
                    DataField   = $DataField
                    TotalCount  = $Count
                    UniqueCount = $script:AutoChart03UniqueCount
                    Computers   = $script:AutoChart03CsvComputers 
                }
                $script:AutoChart03OverallDataResults += $script:AutoChart03DataResults
            }

            $script:AutoChartsProgressBar.Value   = 0
            $script:AutoChartsProgressBar.Minimum = 0
            $script:AutoChartsProgressBar.Maximum = $script:AutoChart03UniqueDataFields.count

            $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
                $script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
                $script:AutoChartsProgressBar.Value += 1
                #Start-Sleep -Milliseconds 1
            }

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart03OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart03.Location.X + 10
                    Y = $script:AutoChart03.Location.Y + 320 }
    Size      = @{ Width  = 125
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart03OptionsButton.Add_Click({  
    if ($script:AutoChart03OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart03OptionsButton.Text = 'Hide Options'
        $script:AutoChart03.Controls.Add($script:AutoChart03ManipulationPanel)
    }
    elseif ($script:AutoChart03OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart03OptionsButton.Text = 'Show Options'
        $script:AutoChart03.Controls.Remove($script:AutoChart03ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart03)

$script:AutoChart03ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart03.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart03TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart03TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart03TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))                
    $script:AutoChart03TrimOffFirstTrackBarValue   = 0
    $script:AutoChart03TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffFirstTrackBarValue = $script:AutoChart03TrimOffFirstTrackBar.Value
        $script:AutoChart03TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart03TrimOffFirstTrackBar.Value)"
        $script:AutoChart03.Series["Startup Commands"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart03TrimOffFirstGroupBox.Controls.Add($script:AutoChart03TrimOffFirstTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart03TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X + $script:AutoChart03TrimOffFirstGroupBox.Size.Width + 10
                        Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart03TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart03TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart03TrimOffLastTrackBar.SetRange(0, $($script:AutoChart03OverallDataResults.count))
    $script:AutoChart03TrimOffLastTrackBar.Value         = $($script:AutoChart03OverallDataResults.count)
    $script:AutoChart03TrimOffLastTrackBarValue   = 0
    $script:AutoChart03TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart03TrimOffLastTrackBarValue = $($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value
        $script:AutoChart03TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart03OverallDataResults.count) - $script:AutoChart03TrimOffLastTrackBar.Value)"
        $script:AutoChart03.Series["Startup Commands"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart03TrimOffLastGroupBox.Controls.Add($script:AutoChart03TrimOffLastTrackBar)
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart03ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart03TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart03TrimOffFirstGroupBox.Location.Y + $script:AutoChart03TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart03ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart03.Series["Startup Commands"].ChartType = $script:AutoChart03ChartTypeComboBox.SelectedItem
    $script:AutoChart03.Series["Startup Commands"].Points.Clear()
    $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart03ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart03ChartTypesAvailable) { $script:AutoChart03ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart033DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart03TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart03TrimOffLastGroupBox.Location.Y + $script:AutoChart03TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart033DInclination = 0
$script:AutoChart033DToggleButton.Add_Click({
    $script:AutoChart033DInclination += 10
    if ( $script:AutoChart033DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)"
        $script:AutoChart03.Series["Startup Commands"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart033DInclination -le 90 ) {
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart033DToggleButton.Text  = "3D On ($script:AutoChart033DInclination)" 
        $script:AutoChart03.Series["Startup Commands"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart033DToggleButton.Text  = "3D Off" 
        $script:AutoChart033DInclination = 0
        $script:AutoChart03Area.Area3DStyle.Inclination = $script:AutoChart033DInclination
        $script:AutoChart03Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart03.Series["Startup Commands"].Points.Clear()
        $script:AutoChart03OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart03TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart03TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart03.Series["Startup Commands"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart033DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart03 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart03ImportCsvPosResults = $script:AutoChart03DataSource | Where-Object 'Name' -eq $($script:AutoChart03InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart03InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart03ImportCsvAll = $script:AutoChart03DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart03ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart03ImportCsvAll) { if ($Endpoint -notin $script:AutoChart03ImportCsvPosResults) { $script:AutoChart03ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart03InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart03ImportCsvNegResults) { $script:AutoChart03InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart03InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart03ImportCsvPosResults.count))"
    $script:AutoChart03InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart03ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart03CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart03TrimOffLastGroupBox.Location.X + $script:AutoChart03TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart03TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart03CheckDiffButton.Add_Click({
    $script:AutoChart03InvestDiffDropDownArray = $script:AutoChart03DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart03InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart03InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart03InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart03InvestDiffDropDownLabel.Location.y + $script:AutoChart03InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart03InvestDiffDropDownArray) { $script:AutoChart03InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart03InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Execute Button
    $script:AutoChart03InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart03InvestDiffDropDownComboBox.Location.y + $script:AutoChart03InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart03InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart03 }})
    $script:AutoChart03InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart03 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart03InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart03InvestDiffExecuteButton.Location.y + $script:AutoChart03InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart03InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y + $script:AutoChart03InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart03InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart03InvestDiffPosResultsLabel.Location.x + $script:AutoChart03InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart03InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart03InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart03InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart03InvestDiffNegResultsLabel.Location.y + $script:AutoChart03InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart03InvestDiffForm.Controls.AddRange(@($script:AutoChart03InvestDiffDropDownLabel,$script:AutoChart03InvestDiffDropDownComboBox,$script:AutoChart03InvestDiffExecuteButton,$script:AutoChart03InvestDiffPosResultsLabel,$script:AutoChart03InvestDiffPosResultsTextBox,$script:AutoChart03InvestDiffNegResultsLabel,$script:AutoChart03InvestDiffNegResultsTextBox))
    $script:AutoChart03InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart03InvestDiffForm.ShowDialog()
})
$script:AutoChart03CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03CheckDiffButton)
    
$script:AutoChart03Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart03CheckDiffButton.Location.X
                   Y = $script:AutoChart03CheckDiffButton.Location.Y + $script:AutoChart03CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart03Results.Add_Click({ $script:AutoChart03DataSource | Out-GridView -Title "$script:AutoChart03CSVFileMostRecentCollection" }) 
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03Results)

### Save the chart to file
$script:AutoChart03SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart03Results.Location.X
                    Y = $script:AutoChart03Results.Location.Y + $script:AutoChart03Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart03SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart03.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart03ManipulationPanel.controls.Add($script:AutoChart03SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart03NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart03SaveButton.Location.X 
                        Y = $script:AutoChart03SaveButton.Location.Y + $script:AutoChart03SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart03CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart03ManipulationPanel.Controls.Add($script:AutoChart03NoticeTextbox)



















##############################################################################################
# AutoChart04
##############################################################################################

$script:AutoChart04CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Software Installed') { $script:AutoChart04CSVFileMatch += $CSVFile } }
} 
$script:AutoChart04CSVFileMostRecentCollection = $script:AutoChart04CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart04 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 525
                  Y = 375 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    ##Anchor          = $AnchorAll
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart04Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Software Installed'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart04.Titles.Add($script:AutoChart04Title)

### Create Charts Area
$script:AutoChart04Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart04Area.Name        = 'Chart Area'
$script:AutoChart04Area.AxisX.Title = 'Hosts'
$script:AutoChart04Area.AxisX.Interval          = 1
$script:AutoChart04Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart04Area.Area3DStyle.Enable3D    = $false
$script:AutoChart04Area.Area3DStyle.Inclination = 75
$script:AutoChart04.ChartAreas.Add($script:AutoChart04Area)

### Auto Create Charts Data Series Recent
$script:AutoChart04.Series.Add("Software Installed")  
$script:AutoChart04.Series["Software Installed"].Enabled           = $True
$script:AutoChart04.Series["Software Installed"].BorderWidth       = 1
$script:AutoChart04.Series["Software Installed"].IsVisibleInLegend = $false
$script:AutoChart04.Series["Software Installed"].Chartarea         = 'Chart Area'
$script:AutoChart04.Series["Software Installed"].Legend            = 'Legend'
$script:AutoChart04.Series["Software Installed"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart04.Series["Software Installed"]['PieLineColor']   = 'Black'
$script:AutoChart04.Series["Software Installed"]['PieLabelStyle']  = 'Outside'
$script:AutoChart04.Series["Software Installed"].ChartType         = 'Column'
$script:AutoChart04.Series["Software Installed"].Color             = 'Orange'

$script:AutoChart04DataSource = Import-Csv $script:AutoChart04CSVFileMostRecentCollection
$script:AutoChart04CsvFileHosts      = $script:AutoChart04DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart04DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
$script:AutoChart04UniqueDataFields  = $script:AutoChart04DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

# If the Second field/Y Axis equals PSComputername, it counts it
$script:AutoChart04OverallDataResults = @()

# Generates and Counts the data - Counts the number of times that any given property possess a given value
foreach ($DataField in $script:AutoChart04UniqueDataFields) {
    $Count        = 0
    $script:AutoChart04CsvComputers = @()
    foreach ( $Line in $script:AutoChart04DataSource ) {
        if ($($Line.Name) -eq $DataField.Name) {
            $Count += 1
            if ( $script:AutoChart04CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart04CsvComputers += $($Line.PSComputerName) }                        
        }
    }
    $script:AutoChart04UniqueCount    = $script:AutoChart04CsvComputers.Count
    $script:AutoChart04DataResults    = New-Object PSObject -Property @{
        DataField   = $DataField
        TotalCount  = $Count
        UniqueCount = $script:AutoChart04UniqueCount
        Computers   = $script:AutoChart04CsvComputers 
    }
    $script:AutoChart04OverallDataResults += $script:AutoChart04DataResults
}

$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = $script:AutoChart04UniqueDataFields.count

$script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
    $script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
    $script:AutoChartsProgressBar.Value += 1
    #Start-Sleep -Milliseconds 1
}

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart04OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart04.Location.X + 10
                    Y = $script:AutoChart04.Location.Y + 320 }
    Size      = @{ Width  = 125
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart04OptionsButton.Add_Click({  
    if ($script:AutoChart04OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart04OptionsButton.Text = 'Hide Options'
        $script:AutoChart04.Controls.Add($script:AutoChart04ManipulationPanel)
    }
    elseif ($script:AutoChart04OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart04OptionsButton.Text = 'Show Options'
        $script:AutoChart04.Controls.Remove($script:AutoChart04ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart04)

$script:AutoChart04ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart04.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart04TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart04TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart04TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))                
    $script:AutoChart04TrimOffFirstTrackBarValue   = 0
    $script:AutoChart04TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart04TrimOffFirstTrackBarValue = $script:AutoChart04TrimOffFirstTrackBar.Value
        $script:AutoChart04TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart04TrimOffFirstTrackBar.Value)"
        $script:AutoChart04.Series["Software Installed"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart04TrimOffFirstGroupBox.Controls.Add($script:AutoChart04TrimOffFirstTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart04TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X + $script:AutoChart04TrimOffFirstGroupBox.Size.Width + 10
                        Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart04TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart04TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart04TrimOffLastTrackBar.SetRange(0, $($script:AutoChart04OverallDataResults.count))
    $script:AutoChart04TrimOffLastTrackBar.Value         = $($script:AutoChart04OverallDataResults.count)
    $script:AutoChart04TrimOffLastTrackBarValue   = 0
    $script:AutoChart04TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart04TrimOffLastTrackBarValue = $($script:AutoChart04OverallDataResults.count) - $script:AutoChart04TrimOffLastTrackBar.Value
        $script:AutoChart04TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart04OverallDataResults.count) - $script:AutoChart04TrimOffLastTrackBar.Value)"
        $script:AutoChart04.Series["Software Installed"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart04TrimOffLastGroupBox.Controls.Add($script:AutoChart04TrimOffLastTrackBar)
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart04ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart04TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart04TrimOffFirstGroupBox.Location.Y + $script:AutoChart04TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart04ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart04.Series["Software Installed"].ChartType = $script:AutoChart04ChartTypeComboBox.SelectedItem
    $script:AutoChart04.Series["Software Installed"].Points.Clear()
    $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart04ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart04ChartTypesAvailable) { $script:AutoChart04ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart043DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart04TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart04TrimOffLastGroupBox.Location.Y + $script:AutoChart04TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart043DInclination = 0
$script:AutoChart043DToggleButton.Add_Click({
    $script:AutoChart043DInclination += 10
    if ( $script:AutoChart043DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)"
        $script:AutoChart04.Series["Software Installed"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart043DInclination -le 90 ) {
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart043DToggleButton.Text  = "3D On ($script:AutoChart043DInclination)" 
        $script:AutoChart04.Series["Software Installed"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart043DToggleButton.Text  = "3D Off" 
        $script:AutoChart043DInclination = 0
        $script:AutoChart04Area.Area3DStyle.Inclination = $script:AutoChart043DInclination
        $script:AutoChart04Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart04.Series["Software Installed"].Points.Clear()
        $script:AutoChart04OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart04TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart04TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart04.Series["Software Installed"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart043DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart04 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart04ImportCsvPosResults = $script:AutoChart04DataSource | Where-Object 'Name' -eq $($script:AutoChart04InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart04InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart04ImportCsvAll = $script:AutoChart04DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart04ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart04ImportCsvAll) { if ($Endpoint -notin $script:AutoChart04ImportCsvPosResults) { $script:AutoChart04ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart04InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart04ImportCsvNegResults) { $script:AutoChart04InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart04InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart04ImportCsvPosResults.count))"
    $script:AutoChart04InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart04ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart04CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart04TrimOffLastGroupBox.Location.X + $script:AutoChart04TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart04TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart04CheckDiffButton.Add_Click({
    $script:AutoChart04InvestDiffDropDownArray = $script:AutoChart04DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart04InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart04InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart04InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart04InvestDiffDropDownLabel.Location.y + $script:AutoChart04InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart04InvestDiffDropDownArray) { $script:AutoChart04InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart04InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Execute Button
    $script:AutoChart04InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart04InvestDiffDropDownComboBox.Location.y + $script:AutoChart04InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart04InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart04 }})
    $script:AutoChart04InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart04 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart04InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart04InvestDiffExecuteButton.Location.y + $script:AutoChart04InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart04InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y + $script:AutoChart04InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart04InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart04InvestDiffPosResultsLabel.Location.x + $script:AutoChart04InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart04InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart04InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart04InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart04InvestDiffNegResultsLabel.Location.y + $script:AutoChart04InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart04InvestDiffForm.Controls.AddRange(@($script:AutoChart04InvestDiffDropDownLabel,$script:AutoChart04InvestDiffDropDownComboBox,$script:AutoChart04InvestDiffExecuteButton,$script:AutoChart04InvestDiffPosResultsLabel,$script:AutoChart04InvestDiffPosResultsTextBox,$script:AutoChart04InvestDiffNegResultsLabel,$script:AutoChart04InvestDiffNegResultsTextBox))
    $script:AutoChart04InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart04InvestDiffForm.ShowDialog()
})
$script:AutoChart04CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04CheckDiffButton)
    
$script:AutoChart04Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart04CheckDiffButton.Location.X
                   Y = $script:AutoChart04CheckDiffButton.Location.Y + $script:AutoChart04CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart04Results.Add_Click({ $script:AutoChart04DataSource | Out-GridView -Title "$script:AutoChart04CSVFileMostRecentCollection" }) 
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04Results)

### Save the chart to file
$script:AutoChart04SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart04Results.Location.X
                    Y = $script:AutoChart04Results.Location.Y + $script:AutoChart04Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart04SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart04.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart04ManipulationPanel.controls.Add($script:AutoChart04SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart04NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart04SaveButton.Location.X 
                        Y = $script:AutoChart04SaveButton.Location.Y + $script:AutoChart04SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart04CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart04ManipulationPanel.Controls.Add($script:AutoChart04NoticeTextbox)



















##############################################################################################
# AutoChart05
##############################################################################################

$script:AutoChart05CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Disk - Physical Info') { $script:AutoChart05CSVFileMatch += $CSVFile } }
} 
$script:AutoChart05CSVFileMostRecentCollection = $script:AutoChart05CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart05 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 5
                  Y = 750 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    ##Anchor          = $AnchorAll
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart05Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Mapped Drives'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart05.Titles.Add($script:AutoChart05Title)

### Create Charts Area
$script:AutoChart05Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart05Area.Name        = 'Chart Area'
$script:AutoChart05Area.AxisX.Title = 'Hosts'
$script:AutoChart05Area.AxisX.Interval          = 1
$script:AutoChart05Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart05Area.Area3DStyle.Enable3D    = $false
$script:AutoChart05Area.Area3DStyle.Inclination = 75
$script:AutoChart05.ChartAreas.Add($script:AutoChart05Area)

### Auto Create Charts Data Series Recent
$script:AutoChart05.Series.Add("Mapped Drives")  
$script:AutoChart05.Series["Mapped Drives"].Enabled           = $True
$script:AutoChart05.Series["Mapped Drives"].BorderWidth       = 1
$script:AutoChart05.Series["Mapped Drives"].IsVisibleInLegend = $false
$script:AutoChart05.Series["Mapped Drives"].Chartarea         = 'Chart Area'
$script:AutoChart05.Series["Mapped Drives"].Legend            = 'Legend'
$script:AutoChart05.Series["Mapped Drives"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart05.Series["Mapped Drives"]['PieLineColor']   = 'Black'
$script:AutoChart05.Series["Mapped Drives"]['PieLabelStyle']  = 'Outside'
$script:AutoChart05.Series["Mapped Drives"].ChartType         = 'Column'
$script:AutoChart05.Series["Mapped Drives"].Color             = 'Yellow'

$script:AutoChart05DataSource = Import-Csv $script:AutoChart05CSVFileMostRecentCollection
$script:AutoChart05CsvFileHosts      = $script:AutoChart05DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart05DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
$script:AutoChart05UniqueDataFields  = $script:AutoChart05DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

# If the Second field/Y Axis equals PSComputername, it counts it
$script:AutoChart05OverallDataResults = @()

# Generates and Counts the data - Counts the number of times that any given property possess a given value
foreach ($DataField in $script:AutoChart05UniqueDataFields) {
    $Count        = 0
    $script:AutoChart05CsvComputers = @()
    foreach ( $Line in $script:AutoChart05DataSource ) {
        if ($($Line.Name) -eq $DataField.Name) {
            $Count += 1
            if ( $script:AutoChart05CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart05CsvComputers += $($Line.PSComputerName) }                        
        }
    }
    $script:AutoChart05UniqueCount    = $script:AutoChart05CsvComputers.Count
    $script:AutoChart05DataResults    = New-Object PSObject -Property @{
        DataField   = $DataField
        TotalCount  = $Count
        UniqueCount = $script:AutoChart05UniqueCount
        Computers   = $script:AutoChart05CsvComputers 
    }
    $script:AutoChart05OverallDataResults += $script:AutoChart05DataResults
}

$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = $script:AutoChart05UniqueDataFields.count

$script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
    $script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
    $script:AutoChartsProgressBar.Value += 1
    #Start-Sleep -Milliseconds 1
}

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart05OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart05.Location.X + 10
                    Y = $script:AutoChart05.Location.Y + 320 }
    Size      = @{ Width  = 125
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart05OptionsButton.Add_Click({  
    if ($script:AutoChart05OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart05OptionsButton.Text = 'Hide Options'
        $script:AutoChart05.Controls.Add($script:AutoChart05ManipulationPanel)
    }
    elseif ($script:AutoChart05OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart05OptionsButton.Text = 'Show Options'
        $script:AutoChart05.Controls.Remove($script:AutoChart05ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart05)

$script:AutoChart05ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart05.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart05TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart05TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart05TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))                
    $script:AutoChart05TrimOffFirstTrackBarValue   = 0
    $script:AutoChart05TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart05TrimOffFirstTrackBarValue = $script:AutoChart05TrimOffFirstTrackBar.Value
        $script:AutoChart05TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart05TrimOffFirstTrackBar.Value)"
        $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart05TrimOffFirstGroupBox.Controls.Add($script:AutoChart05TrimOffFirstTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart05TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X + $script:AutoChart05TrimOffFirstGroupBox.Size.Width + 10
                        Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart05TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart05TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart05TrimOffLastTrackBar.SetRange(0, $($script:AutoChart05OverallDataResults.count))
    $script:AutoChart05TrimOffLastTrackBar.Value         = $($script:AutoChart05OverallDataResults.count)
    $script:AutoChart05TrimOffLastTrackBarValue   = 0
    $script:AutoChart05TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart05TrimOffLastTrackBarValue = $($script:AutoChart05OverallDataResults.count) - $script:AutoChart05TrimOffLastTrackBar.Value
        $script:AutoChart05TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart05OverallDataResults.count) - $script:AutoChart05TrimOffLastTrackBar.Value)"
        $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart05TrimOffLastGroupBox.Controls.Add($script:AutoChart05TrimOffLastTrackBar)
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart05ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart05TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart05TrimOffFirstGroupBox.Location.Y + $script:AutoChart05TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart05ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart05.Series["Mapped Drives"].ChartType = $script:AutoChart05ChartTypeComboBox.SelectedItem
    $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
    $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart05ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart05ChartTypesAvailable) { $script:AutoChart05ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart053DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart05TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart05TrimOffLastGroupBox.Location.Y + $script:AutoChart05TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart053DInclination = 0
$script:AutoChart053DToggleButton.Add_Click({
    $script:AutoChart053DInclination += 10
    if ( $script:AutoChart053DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)"
        $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart053DInclination -le 90 ) {
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart053DToggleButton.Text  = "3D On ($script:AutoChart053DInclination)" 
        $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart053DToggleButton.Text  = "3D Off" 
        $script:AutoChart053DInclination = 0
        $script:AutoChart05Area.Area3DStyle.Inclination = $script:AutoChart053DInclination
        $script:AutoChart05Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart05.Series["Mapped Drives"].Points.Clear()
        $script:AutoChart05OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart05TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart05TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart05.Series["Mapped Drives"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart053DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart05 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart05ImportCsvPosResults = $script:AutoChart05DataSource | Where-Object 'Name' -eq $($script:AutoChart05InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart05InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ImportCsvPosResults) { $script:AutoChart05InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart05ImportCsvAll = $script:AutoChart05DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart05ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart05ImportCsvAll) { if ($Endpoint -notin $script:AutoChart05ImportCsvPosResults) { $script:AutoChart05ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart05InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart05ImportCsvNegResults) { $script:AutoChart05InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart05InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart05ImportCsvPosResults.count))"
    $script:AutoChart05InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart05ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart05CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart05TrimOffLastGroupBox.Location.X + $script:AutoChart05TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart05TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart05CheckDiffButton.Add_Click({
    $script:AutoChart05InvestDiffDropDownArray = $script:AutoChart05DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart05InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart05InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart05InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart05InvestDiffDropDownLabel.Location.y + $script:AutoChart05InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart05InvestDiffDropDownArray) { $script:AutoChart05InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart05InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Execute Button
    $script:AutoChart05InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart05InvestDiffDropDownComboBox.Location.y + $script:AutoChart05InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart05InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart05 }})
    $script:AutoChart05InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart05 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart05InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart05InvestDiffExecuteButton.Location.y + $script:AutoChart05InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart05InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y + $script:AutoChart05InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart05InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart05InvestDiffPosResultsLabel.Location.x + $script:AutoChart05InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart05InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart05InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart05InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart05InvestDiffNegResultsLabel.Location.y + $script:AutoChart05InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart05InvestDiffForm.Controls.AddRange(@($script:AutoChart05InvestDiffDropDownLabel,$script:AutoChart05InvestDiffDropDownComboBox,$script:AutoChart05InvestDiffExecuteButton,$script:AutoChart05InvestDiffPosResultsLabel,$script:AutoChart05InvestDiffPosResultsTextBox,$script:AutoChart05InvestDiffNegResultsLabel,$script:AutoChart05InvestDiffNegResultsTextBox))
    $script:AutoChart05InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart05InvestDiffForm.ShowDialog()
})
$script:AutoChart05CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05CheckDiffButton)
    
$script:AutoChart05Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart05CheckDiffButton.Location.X
                   Y = $script:AutoChart05CheckDiffButton.Location.Y + $script:AutoChart05CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart05Results.Add_Click({ $script:AutoChart05DataSource | Out-GridView -Title "$script:AutoChart05CSVFileMostRecentCollection" }) 
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05Results)

### Save the chart to file
$script:AutoChart05SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart05Results.Location.X
                    Y = $script:AutoChart05Results.Location.Y + $script:AutoChart05Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart05SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart05.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart05ManipulationPanel.controls.Add($script:AutoChart05SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart05NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart05SaveButton.Location.X 
                        Y = $script:AutoChart05SaveButton.Location.Y + $script:AutoChart05SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart05CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart05ManipulationPanel.Controls.Add($script:AutoChart05NoticeTextbox)

















##############################################################################################
# AutoChart06
##############################################################################################

$script:AutoChart06CSVFileMatch = @()
foreach ($CollectionDir in $script:ListOfCollectedDataDirectories) {
    $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
    foreach ($CSVFile in $CSVFiles) { if ($CSVFile -match 'Local Users') { $script:AutoChart06CSVFileMatch += $CSVFile } }
} 
$script:AutoChart06CSVFileMostRecentCollection = $script:AutoChart06CSVFileMatch | Select-Object -Last 1

### Auto Create Charts Object
$script:AutoChart06 = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
    Location = @{ X = 525
                  Y = 750 }
    Size     = @{ Width  = 500
                  Height = 350 }
    BackColor       = [System.Drawing.Color]::White
    BorderColor     = 'Black'
    Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    ##Anchor          = $AnchorAll
    BorderDashStyle = 'Solid'
}

### Auto Create Charts Title 
$script:AutoChart06Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
    ForeColor = "black"
    Text      = 'Local Users'
    Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    Alignment = "topcenter" #"topLeft"
}
$script:AutoChart06.Titles.Add($script:AutoChart06Title)

### Create Charts Area
$script:AutoChart06Area             = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$script:AutoChart06Area.Name        = 'Chart Area'
$script:AutoChart06Area.AxisX.Title = 'Hosts'
$script:AutoChart06Area.AxisX.Interval          = 1
$script:AutoChart06Area.AxisY.IntervalAutoMode  = $true
$script:AutoChart06Area.Area3DStyle.Enable3D    = $false
$script:AutoChart06Area.Area3DStyle.Inclination = 75
$script:AutoChart06.ChartAreas.Add($script:AutoChart06Area)

### Auto Create Charts Data Series Recent
$script:AutoChart06.Series.Add("Local Users")  
$script:AutoChart06.Series["Local Users"].Enabled           = $True
$script:AutoChart06.Series["Local Users"].BorderWidth       = 1
$script:AutoChart06.Series["Local Users"].IsVisibleInLegend = $false
$script:AutoChart06.Series["Local Users"].Chartarea         = 'Chart Area'
$script:AutoChart06.Series["Local Users"].Legend            = 'Legend'
$script:AutoChart06.Series["Local Users"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
$script:AutoChart06.Series["Local Users"]['PieLineColor']   = 'Black'
$script:AutoChart06.Series["Local Users"]['PieLabelStyle']  = 'Outside'
$script:AutoChart06.Series["Local Users"].ChartType         = 'Column'
$script:AutoChart06.Series["Local Users"].Color             = 'Gray'

$script:AutoChart06DataSource = Import-Csv $script:AutoChart06CSVFileMostRecentCollection
$script:AutoChart06CsvFileHosts      = $script:AutoChart06DataSource | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($script:AutoChart06DataSource))};Label="FileName"} | Select-Object -ExpandProperty 'PSComputerName' -Unique
$script:AutoChart06UniqueDataFields  = $script:AutoChart06DataSource | Select-Object -Property 'Name' | Sort-Object -Property 'Name' -Unique

# If the Second field/Y Axis equals PSComputername, it counts it
$script:AutoChart06OverallDataResults = @()

# Generates and Counts the data - Counts the number of times that any given property possess a given value
foreach ($DataField in $script:AutoChart06UniqueDataFields) {
    $Count        = 0
    $script:AutoChart06CsvComputers = @()
    foreach ( $Line in $script:AutoChart06DataSource ) {
        if ($($Line.Name) -eq $DataField.Name) {
            $Count += 1
            if ( $script:AutoChart06CsvComputers -notcontains $($Line.PSComputerName) ) { $script:AutoChart06CsvComputers += $($Line.PSComputerName) }                        
        }
    }
    $script:AutoChart06UniqueCount    = $script:AutoChart06CsvComputers.Count
    $script:AutoChart06DataResults    = New-Object PSObject -Property @{
        DataField   = $DataField
        TotalCount  = $Count
        UniqueCount = $script:AutoChart06UniqueCount
        Computers   = $script:AutoChart06CsvComputers 
    }
    $script:AutoChart06OverallDataResults += $script:AutoChart06DataResults
}

$script:AutoChartsProgressBar.Value   = 0
$script:AutoChartsProgressBar.Minimum = 0
$script:AutoChartsProgressBar.Maximum = $script:AutoChart06UniqueDataFields.count

$script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | ForEach-Object {
    $script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)
    $script:AutoChartsProgressBar.Value += 1
    #Start-Sleep -Milliseconds 1
}

### Auto Chart Panel that contains all the options to manage open/close feature 
$script:AutoChart06OptionsButton = New-Object Windows.Forms.Button -Property @{
    Text      = "Show Options"
    Location  = @{ X = $script:AutoChart06.Location.X + 10
                   Y = $script:AutoChart06.Location.Y + 320 }
    Size      = @{ Width  = 125
                   Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    UseVisualStyleBackColor = $True
}
$script:AutoChart06OptionsButton.Add_Click({  
    if ($script:AutoChart06OptionsButton.Text -eq 'Show Options') {
        $script:AutoChart06OptionsButton.Text = 'Hide Options'
        $script:AutoChart06.Controls.Add($script:AutoChart06ManipulationPanel)
    }
    elseif ($script:AutoChart06OptionsButton.Text -eq 'Hide Options') {
        $script:AutoChart06OptionsButton.Text = 'Show Options'
        $script:AutoChart06.Controls.Remove($script:AutoChart06ManipulationPanel)
    }
})
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06OptionsButton)
$script:AutoChartsIndividualTab01.Controls.Add($script:AutoChart06)

$script:AutoChart06ManipulationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location    = @{ X = 0
                     Y = 0 }
    Size        = @{ Width  = $script:AutoChart06.Size.Width
                     Height = 125 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
    BackColor   = 'White'
    BorderStyle = 'FixedSingle'
}

### AutoCharts - Trim Off First GroupBox
$script:AutoChart06TrimOffFirstGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off First: 0"
    Location    = @{ X = 5
                     Y = 5 }
    Size        = @{ Width  = 165
                     Height = 85 }
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off First TrackBar
    $script:AutoChart06TrimOffFirstTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location    = @{ X = 1
                         Y = 30 }
        Size        = @{ Width  = 160
                         Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
        Value         = 0 
    }
    $script:AutoChart06TrimOffFirstTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))                
    $script:AutoChart06TrimOffFirstTrackBarValue   = 0
    $script:AutoChart06TrimOffFirstTrackBar.add_ValueChanged({
        $script:AutoChart06TrimOffFirstTrackBarValue = $script:AutoChart06TrimOffFirstTrackBar.Value
        $script:AutoChart06TrimOffFirstGroupBox.Text = "Trim Off First: $($script:AutoChart06TrimOffFirstTrackBar.Value)"
        $script:AutoChart06.Series["Local Users"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}    
    })
    $script:AutoChart06TrimOffFirstGroupBox.Controls.Add($script:AutoChart06TrimOffFirstTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffFirstGroupBox)

### Auto Charts - Trim Off Last GroupBox
$script:AutoChart06TrimOffLastGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text        = "Trim Off Last: 0"
    Location    = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X + $script:AutoChart06TrimOffFirstGroupBox.Size.Width + 10
                        Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y }
    Size        = @{ Width  = 165
                        Height = 85 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("$font",11,0,0,0)
    ForeColor   = 'Black'
}
    ### AutoCharts - Trim Off Last TrackBar
    $script:AutoChart06TrimOffLastTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Location      = @{ X = 1
                           Y = 30 }
        Size          = @{ Width  = 160
                           Height = 25}                
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 0
    }
    $script:AutoChart06TrimOffLastTrackBar.RightToLeft   = $true
    $script:AutoChart06TrimOffLastTrackBar.SetRange(0, $($script:AutoChart06OverallDataResults.count))
    $script:AutoChart06TrimOffLastTrackBar.Value         = $($script:AutoChart06OverallDataResults.count)
    $script:AutoChart06TrimOffLastTrackBarValue   = 0
    $script:AutoChart06TrimOffLastTrackBar.add_ValueChanged({
        $script:AutoChart06TrimOffLastTrackBarValue = $($script:AutoChart06OverallDataResults.count) - $script:AutoChart06TrimOffLastTrackBar.Value
        $script:AutoChart06TrimOffLastGroupBox.Text = "Trim Off Last: $($($script:AutoChart06OverallDataResults.count) - $script:AutoChart06TrimOffLastTrackBar.Value)"
        $script:AutoChart06.Series["Local Users"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    })
$script:AutoChart06TrimOffLastGroupBox.Controls.Add($script:AutoChart06TrimOffLastTrackBar)
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06TrimOffLastGroupBox)

#======================================
# Auto Create Charts Select Chart Type
#======================================
$script:AutoChart06ChartTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = 'Column' 
    Location  = @{ X = $script:AutoChart06TrimOffFirstGroupBox.Location.X 
                    Y = $script:AutoChart06TrimOffFirstGroupBox.Location.Y + $script:AutoChart06TrimOffFirstGroupBox.Size.Height + 5 }
    Size      = @{ Width  = 165
                    Height = 20 }     
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
}
$script:AutoChart06ChartTypeComboBox.add_SelectedIndexChanged({
    $script:AutoChart06.Series["Local Users"].ChartType = $script:AutoChart06ChartTypeComboBox.SelectedItem
    $script:AutoChart06.Series["Local Users"].Points.Clear()
    $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
})
$script:AutoChart06ChartTypesAvailable = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
ForEach ($Item in $script:AutoChart06ChartTypesAvailable) { $script:AutoChart06ChartTypeComboBox.Items.Add($Item) }
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06ChartTypeComboBox)

### Auto Charts Toggle 3D on/off and inclination angle
$script:AutoChart063DToggleButton = New-Object Windows.Forms.Button -Property @{
    Text      = "3D Off"
    Location  = @{ X = $script:AutoChart06TrimOffLastGroupBox.Location.X 
                    Y = $script:AutoChart06TrimOffLastGroupBox.Location.Y + $script:AutoChart06TrimOffLastGroupBox.Size.Height + 5}
    Size      = @{ Width  = 165
                    Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart063DInclination = 0
$script:AutoChart063DToggleButton.Add_Click({
    $script:AutoChart063DInclination += 10
    if ( $script:AutoChart063DToggleButton.Text -eq "3D Off" ) { 
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $true
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)"
        $script:AutoChart06.Series["Local Users"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    elseif ( $script:AutoChart063DInclination -le 90 ) {
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart063DToggleButton.Text  = "3D On ($script:AutoChart063DInclination)" 
        $script:AutoChart06.Series["Local Users"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
    else { 
        $script:AutoChart063DToggleButton.Text  = "3D Off" 
        $script:AutoChart063DInclination = 0
        $script:AutoChart06Area.Area3DStyle.Inclination = $script:AutoChart063DInclination
        $script:AutoChart06Area.Area3DStyle.Enable3D    = $false
        $script:AutoChart06.Series["Local Users"].Points.Clear()
        $script:AutoChart06OverallDataResults | Sort-Object -Property UniqueCount | Select-Object -skip $script:AutoChart06TrimOffFirstTrackBarValue | Select-Object -SkipLast $script:AutoChart06TrimOffLastTrackBarValue | ForEach-Object {$script:AutoChart06.Series["Local Users"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
    }
})
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart063DToggleButton)

#=====================================
# AutoCharts - Investigate Difference
#=====================================
function script:InvestigateDifference-AutoChart06 {    
    # List of Positive Endpoints that positively match
    $script:AutoChart06ImportCsvPosResults = $script:AutoChart06DataSource | Where-Object 'Name' -eq $($script:AutoChart06InvestDiffDropDownComboBox.Text) | Select-Object -ExpandProperty 'PSComputerName' -Unique
    $script:AutoChart06InvestDiffPosResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ImportCsvPosResults) { $script:AutoChart06InvestDiffPosResultsTextBox.Text += "$Endpoint`r`n" }

    # List of all endpoints within the csv file
    $script:AutoChart06ImportCsvAll = $script:AutoChart06DataSource | Select-Object -ExpandProperty 'PSComputerName' -Unique
    
    $script:AutoChart06ImportCsvNegResults = @()
    # Creates a list of Endpoints with Negative Results
    foreach ($Endpoint in $script:AutoChart06ImportCsvAll) { if ($Endpoint -notin $script:AutoChart06ImportCsvPosResults) { $script:AutoChart06ImportCsvNegResults += $Endpoint } }

    # Populates the listbox with Negative Endpoint Results
    $script:AutoChart06InvestDiffNegResultsTextBox.Text = ''
    ForEach ($Endpoint in $script:AutoChart06ImportCsvNegResults) { $script:AutoChart06InvestDiffNegResultsTextBox.Text += "$Endpoint`r`n" }

    # Updates the label to include the count
    $script:AutoChart06InvestDiffPosResultsLabel.Text = "Positive Match ($($script:AutoChart06ImportCsvPosResults.count))"
    $script:AutoChart06InvestDiffNegResultsLabel.Text = "Negative Match ($($script:AutoChart06ImportCsvNegResults.count))"
}

#==============================
# Auto Chart Buttons
#==============================
### Auto Create Charts Check Diff Button
$script:AutoChart06CheckDiffButton = New-Object Windows.Forms.Button -Property @{
    Text      = 'Investigate'
    Location  = @{ X = $script:AutoChart06TrimOffLastGroupBox.Location.X + $script:AutoChart06TrimOffLastGroupBox.Size.Width + 5
                   Y = $script:AutoChart06TrimOffLastGroupBox.Location.Y }
    Size      = @{ Width  = 140
                   Height = 25 }
    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart06CheckDiffButton.Add_Click({
    $script:AutoChart06InvestDiffDropDownArray = $script:AutoChart06DataSource | Select-Object -Property 'Name' -ExpandProperty 'Name' | Sort-Object -Unique

    ### Investigate Difference Compare Csv Files Form
    $script:AutoChart06InvestDiffForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = 'Investigate Difference'
        Size   = @{ Width  = 330
                    Height = 360 }
        Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        StartPosition = "CenterScreen"
        ControlBox = $true
    }

    ### Investigate Difference Drop Down Label & ComboBox
    $script:AutoChart06InvestDiffDropDownLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Investigate the difference between computers."
        Location = @{ X = 10
                        Y = 10 }
        Size     = @{ Width  = 290
                        Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart06InvestDiffDropDownComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = @{ X = 10
                        Y = $script:AutoChart06InvestDiffDropDownLabel.Location.y + $script:AutoChart06InvestDiffDropDownLabel.Size.Height }
        Width    = 290
        Height   = 30
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    ForEach ($Item in $script:AutoChart06InvestDiffDropDownArray) { $script:AutoChart06InvestDiffDropDownComboBox.Items.Add($Item) }
    $script:AutoChart06InvestDiffDropDownComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffDropDownComboBox.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Execute Button
    $script:AutoChart06InvestDiffExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = 10
                        Y = $script:AutoChart06InvestDiffDropDownComboBox.Location.y + $script:AutoChart06InvestDiffDropDownComboBox.Size.Height + 10 }
        Width    = 100 
        Height   = 20
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart06InvestDiffExecuteButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart06 }})
    $script:AutoChart06InvestDiffExecuteButton.Add_Click({ script:InvestigateDifference-AutoChart06 })

    ### Investigate Difference Positive Results Label & TextBox
    $script:AutoChart06InvestDiffPosResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Positive Match (+)"
        Location   = @{ X = 10
                        Y = $script:AutoChart06InvestDiffExecuteButton.Location.y + $script:AutoChart06InvestDiffExecuteButton.Size.Height + 10 }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }        
    $script:AutoChart06InvestDiffPosResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = 10
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y + $script:AutoChart06InvestDiffPosResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }            

    ### Investigate Difference Negative Results Label & TextBox
    $script:AutoChart06InvestDiffNegResultsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Negative Match (-)"
        Location   = @{ X = $script:AutoChart06InvestDiffPosResultsLabel.Location.x + $script:AutoChart06InvestDiffPosResultsLabel.Size.Width + 10
                        Y = $script:AutoChart06InvestDiffPosResultsLabel.Location.y }
        Size       = @{ Width  = 140
                        Height = 22 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $script:AutoChart06InvestDiffNegResultsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location   = @{ X = $script:AutoChart06InvestDiffNegResultsLabel.Location.x
                        Y = $script:AutoChart06InvestDiffNegResultsLabel.Location.y + $script:AutoChart06InvestDiffNegResultsLabel.Size.Height }
        Size       = @{ Width  = 140
                        Height = 178 }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly   = $true
        BackColor  = 'White'
        WordWrap   = $false
        Multiline  = $true
        ScrollBars = "Vertical"
    }
    $script:AutoChart06InvestDiffForm.Controls.AddRange(@($script:AutoChart06InvestDiffDropDownLabel,$script:AutoChart06InvestDiffDropDownComboBox,$script:AutoChart06InvestDiffExecuteButton,$script:AutoChart06InvestDiffPosResultsLabel,$script:AutoChart06InvestDiffPosResultsTextBox,$script:AutoChart06InvestDiffNegResultsLabel,$script:AutoChart06InvestDiffNegResultsTextBox))
    $script:AutoChart06InvestDiffForm.add_Load($OnLoadForm_StateCorrection)
    $script:AutoChart06InvestDiffForm.ShowDialog()
})
$script:AutoChart06CheckDiffButton.Add_MouseHover({
ToolTipFunction -Title "Investigate Difference" -Icon "Info" -Message @"
⦿ Allows you to quickly search for the differences`n`n
"@ })
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06CheckDiffButton)
    
$script:AutoChart06Results = New-Object Windows.Forms.Button -Property @{
    Text      = "View Results"
    Location  = @{ X = $script:AutoChart06CheckDiffButton.Location.X
                   Y = $script:AutoChart06CheckDiffButton.Location.Y + $script:AutoChart06CheckDiffButton.Size.Height + 5 }
    Size      = @{ Width  = 140
                   Height = 25 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
$script:AutoChart06Results.Add_Click({ $script:AutoChart06DataSource | Out-GridView -Title "$script:AutoChart06CSVFileMostRecentCollection" }) 
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06Results)

### Save the chart to file
$script:AutoChart06SaveButton = New-Object Windows.Forms.Button -Property @{
    Text     = "Save Chart"
    Location = @{ X = $script:AutoChart06Results.Location.X
                    Y = $script:AutoChart06Results.Location.Y + $script:AutoChart06Results.Size.Height + 5 }
    Size     = @{ Width  = 140
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    BackColor = "LightGray"
    UseVisualStyleBackColor = $True
}
[enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
$script:AutoChart06SaveButton.Add_Click({
    $Result = script:Invoke-SaveChartAsImage
    If ($Result) { $script:AutoChart06.SaveImage($Result.FileName, $Result.Extension) }
})
$script:AutoChart06ManipulationPanel.controls.Add($script:AutoChart06SaveButton)

#==============================
# Auto Charts - Notice Textbox
#==============================
$script:AutoChart06NoticeTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Location    = @{ X = $script:AutoChart06SaveButton.Location.X 
                        Y = $script:AutoChart06SaveButton.Location.Y + $script:AutoChart06SaveButton.Size.Height + 5 }
    Size        = @{ Width  = 140
                        Height = 25 }
    Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    ForeColor   = 'Black'
    Text        = "Endpoints:  $($script:AutoChart06CsvFileHosts.Count)"
    Multiline   = $false
    Enabled     = $false
    BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
}
$script:AutoChart06ManipulationPanel.Controls.Add($script:AutoChart06NoticeTextbox)















$script:AutoChart01ManipulationPanel.TopMost  = $true
$script:AutoChart01ManipulationPanel.TopLevel = $true

$script:AutoChart02ManipulationPanel.TopMost  = $true
$script:AutoChart02ManipulationPanel.TopLevel = $true

$script:AutoChart03ManipulationPanel.TopMost  = $true
$script:AutoChart03ManipulationPanel.TopLevel = $true

$script:AutoChart04ManipulationPanel.TopMost  = $true
$script:AutoChart04ManipulationPanel.TopLevel = $true

$script:AutoChart05ManipulationPanel.TopMost  = $true
$script:AutoChart05ManipulationPanel.TopLevel = $true

$script:AutoChart06ManipulationPanel.TopMost  = $true
$script:AutoChart06ManipulationPanel.TopLevel = $true