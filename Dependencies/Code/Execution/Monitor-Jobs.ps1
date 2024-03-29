
function Monitor-Jobs {
    <#
        .Description
        This is one of the core scripts that handles how queries are conducted
        It monitors started PoSh-EasyWin jobs and updates the GUI
    #>
    param(
        $CollectionName,
        $ComputerName,
        [switch]$txt,
        [switch]$xml,
        [String]$SaveProperties,
        [switch]$NotExportFiles,
        [string]$JobsExportFiles = 'true',
        [switch]$MonitorMode,
        [switch]$SMITH,
        $SmithScript,
        $ArgumentList,
        $SmithFlag,
        [switch]$AutoReRun,
        [int]$RestartTime = $($script:OptionMonitorJobsDefaultRestartTimeCombobox.text),
        [switch]$DisableReRun,
        $InputValues,
        [switch]$PcapSwitch,
        [switch]$PSWriteHTMLSwitch,
        $PSWriteHTML,
        $PSWriteHTMLFilePath,
        [string[]]$PSWriteHTMLOptions,
        [switch]$EVTXSwitch,
        $EVTXLocalSavePath,
        [switch]$SendFileSwitch,
        $SendFilePath,
        [switch]$SysmonSwitch,
        $SysmonName,
        [switch]$ProcmonSwitch,
        $ProcmonLocalPath,
        [switch]$ExecutableAndScriptSwitch,
        [string]$ExecutableAndScriptPath
    )

    $JobId = Get-Random
    if ($txt) {
        $SaveResultsCmd = 'Out-File'
        $ImportDataCmd  = 'Get-Content'
        $FileExtension  = 'txt'
        $NoTypeInfo     = $null
    }
    elseif ($xml) {
        $SaveResultsCmd = 'Select-Object * | Export-CliXml'
        $ImportDataCmd  = 'Import-CliXml'
        $FileExtension  = 'xml'
        $NoTypeInfo     = $null
    }
    else {
        $SaveResultsCmd = 'Select-Object * | Export-Csv'
        $ImportDataCmd  = 'Import-Csv'
        $FileExtension  = 'csv'
        $NoTypeInfo     = '-NoTypeInformation'
    }

    ############################
    # Generates Dynamic Charts #
    ############################
    function script:New-PowerShellChart {
        <#
        .Description Dynamically creates powershell charts for collected data
        #>
        param(
            $SourceCSVData,
            $SourceXMLPath,
            $SeriesName = 'Unnamed Series',
            $ChartType,
            $TitleAxisX,
            $TitleAxisY,
            $PropertyX,
            $PropertyY,
            $ChartNumber = 1,
            $ChartColor
        )
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Windows.Forms.DataVisualization

        Invoke-Expression -Command @"
        `$script:SourceCSVData$ChartNumber = `$SourceCSVData
        `$script:SourceXMLPath$ChartNumber = `$SourceXMLPath
        `$script:SeriesName$ChartNumber = `$SeriesName
        `$script:PropertyX$ChartNumber  = `$PropertyX
        `$script:PropertyY$ChartNumber  = `$PropertyY

        `$script:AutoChartMainPanel$ChartNumber = New-object System.Windows.Forms.Panel -Property @{
            Width  = `$FormScale * 575
            Height = `$FormScale * 375
        }
        `$script:AutoChartsIndividualTab01.Controls.Add(`$script:AutoChartMainPanel$ChartNumber)


        # Sets the position the charts based on the chart number
        switch ($ChartNumber) {
            1  { `$ChartLocation = @( `$(`$FormScale * 5),0) }
            2  { `$ChartLocation = @( `$(`$script:AutoChartMainPanel1.Left +  `$script:AutoChartMainPanel1.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel1.Top) }
            3  { `$ChartLocation = @( `$script:AutoChartMainPanel1.Left, `$(`$script:AutoChartMainPanel1.Top + `$script:AutoChartMainPanel1.Height + `$(`$FormScale * 20))) }
            4  { `$ChartLocation = @( `$(`$script:AutoChartMainPanel3.Left +  `$script:AutoChartMainPanel3.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel3.Top) }
            5  { `$ChartLocation = @( `$script:AutoChartMainPanel3.Left, `$(`$script:AutoChartMainPanel3.Top + `$script:AutoChartMainPanel3.Height + `$(`$FormScale * 20))) }
            6  { `$ChartLocation = @( `$(`$script:AutoChartMainPanel5.Left +  `$script:AutoChartMainPanel5.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel5.Top) }
            7  { `$ChartLocation = @( `$script:AutoChartMainPanel5.Left, `$(`$script:AutoChartMainPanel5.Top + `$script:AutoChartMainPanel5.Height + `$(`$FormScale * 20))) }
            8  { `$ChartLocation = @( `$(`$script:AutoChartMainPanel7.Left +  `$script:AutoChartMainPanel7.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel7.Top) }
            9  { `$ChartLocation = @( `$script:AutoChartMainPanel7.Left, `$(`$script:AutoChartMainPanel7.Top + `$script:AutoChartMainPanel7.Height + `$(`$FormScale * 20))) }
            10 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel9.Left +  `$script:AutoChartMainPanel9.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel9.Top) }

            11 { `$ChartLocation = @( `$script:AutoChartMainPanel9.Left, `$(`$script:AutoChartMainPanel9.Top + `$script:AutoChartMainPanel9.Height + `$(`$FormScale * 20))) }
            12 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel11.Left +  `$script:AutoChartMainPanel11.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel11.Top) }
            13 { `$ChartLocation = @( `$script:AutoChartMainPanel11.Left, `$(`$script:AutoChartMainPanel11.Top + `$script:AutoChartMainPanel11.Height + `$(`$FormScale * 20))) }
            14 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel13.Left +  `$script:AutoChartMainPanel13.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel13.Top) }
            15 { `$ChartLocation = @( `$script:AutoChartMainPanel13.Left, `$(`$script:AutoChartMainPanel13.Top + `$script:AutoChartMainPanel13.Height + `$(`$FormScale * 20))) }
            16 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel15.Left +  `$script:AutoChartMainPanel15.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel15.Top) }
            17 { `$ChartLocation = @( `$script:AutoChartMainPanel15.Left, `$(`$script:AutoChartMainPanel15.Top + `$script:AutoChartMainPanel15.Height + `$(`$FormScale * 20))) }
            18 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel17.Left +  `$script:AutoChartMainPanel17.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel17.Top) }
            19 { `$ChartLocation = @( `$script:AutoChartMainPanel17.Left, `$(`$script:AutoChartMainPanel17.Top + `$script:AutoChartMainPanel17.Height + `$(`$FormScale * 20))) }
            20 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel19.Left +  `$script:AutoChartMainPanel19.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel19.Top) }

            21 { `$ChartLocation = @( `$script:AutoChartMainPanel19.Left, `$(`$script:AutoChartMainPanel19.Top + `$script:AutoChartMainPanel19.Height + `$(`$FormScale * 20))) }
            22 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel21.Left +  `$script:AutoChartMainPanel21.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel21.Top) }
            23 { `$ChartLocation = @( `$script:AutoChartMainPanel21.Left, `$(`$script:AutoChartMainPanel21.Top + `$script:AutoChartMainPanel21.Height + `$(`$FormScale * 20))) }
            24 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel23.Left +  `$script:AutoChartMainPanel23.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel23.Top) }
            25 { `$ChartLocation = @( `$script:AutoChartMainPanel23.Left, `$(`$script:AutoChartMainPanel23.Top + `$script:AutoChartMainPanel23.Height + `$(`$FormScale * 20))) }
            26 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel25.Left +  `$script:AutoChartMainPanel25.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel25.Top) }
            27 { `$ChartLocation = @( `$script:AutoChartMainPanel25.Left, `$(`$script:AutoChartMainPanel25.Top + `$script:AutoChartMainPanel25.Height + `$(`$FormScale * 20))) }
            28 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel27.Left +  `$script:AutoChartMainPanel27.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel27.Top) }
            29 { `$ChartLocation = @( `$script:AutoChartMainPanel27.Left, `$(`$script:AutoChartMainPanel27.Top + `$script:AutoChartMainPanel27.Height + `$(`$FormScale * 20))) }
            30 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel29.Left +  `$script:AutoChartMainPanel29.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel29.Top) }

            31 { `$ChartLocation = @( `$script:AutoChartMainPanel29.Left, `$(`$script:AutoChartMainPanel29.Top + `$script:AutoChartMainPanel29.Height + `$(`$FormScale * 20))) }
            32 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel31.Left +  `$script:AutoChartMainPanel31.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel31.Top) }
            33 { `$ChartLocation = @( `$script:AutoChartMainPanel31.Left, `$(`$script:AutoChartMainPanel31.Top + `$script:AutoChartMainPanel31.Height + `$(`$FormScale * 20))) }
            34 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel33.Left +  `$script:AutoChartMainPanel33.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel33.Top) }
            35 { `$ChartLocation = @( `$script:AutoChartMainPanel33.Left, `$(`$script:AutoChartMainPanel33.Top + `$script:AutoChartMainPanel33.Height + `$(`$FormScale * 20))) }
            36 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel35.Left +  `$script:AutoChartMainPanel35.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel35.Top) }
            37 { `$ChartLocation = @( `$script:AutoChartMainPanel35.Left, `$(`$script:AutoChartMainPanel35.Top + `$script:AutoChartMainPanel35.Height + `$(`$FormScale * 20))) }
            38 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel37.Left +  `$script:AutoChartMainPanel37.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel37.Top) }
            39 { `$ChartLocation = @( `$script:AutoChartMainPanel37.Left, `$(`$script:AutoChartMainPanel37.Top + `$script:AutoChartMainPanel37.Height + `$(`$FormScale * 20))) }
            40 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel39.Left +  `$script:AutoChartMainPanel39.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel39.Top) }

            41 { `$ChartLocation = @( `$script:AutoChartMainPanel39.Left, `$(`$script:AutoChartMainPanel39.Top + `$script:AutoChartMainPanel39.Height + `$(`$FormScale * 20))) }
            42 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel41.Left +  `$script:AutoChartMainPanel41.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel41.Top) }
            43 { `$ChartLocation = @( `$script:AutoChartMainPanel41.Left, `$(`$script:AutoChartMainPanel41.Top + `$script:AutoChartMainPanel41.Height + `$(`$FormScale * 20))) }
            44 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel43.Left +  `$script:AutoChartMainPanel43.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel43.Top) }
            45 { `$ChartLocation = @( `$script:AutoChartMainPanel43.Left, `$(`$script:AutoChartMainPanel43.Top + `$script:AutoChartMainPanel43.Height + `$(`$FormScale * 20))) }
            46 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel45.Left +  `$script:AutoChartMainPanel45.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel45.Top) }
            47 { `$ChartLocation = @( `$script:AutoChartMainPanel45.Left, `$(`$script:AutoChartMainPanel45.Top + `$script:AutoChartMainPanel45.Height + `$(`$FormScale * 20))) }
            48 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel47.Left +  `$script:AutoChartMainPanel47.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel47.Top) }
            49 { `$ChartLocation = @( `$script:AutoChartMainPanel47.Left, `$(`$script:AutoChartMainPanel47.Top + `$script:AutoChartMainPanel47.Height + `$(`$FormScale * 20))) }
            50 { `$ChartLocation = @( `$(`$script:AutoChartMainPanel49.Left +  `$script:AutoChartMainPanel49.Width + `$(`$FormScale * 20)), `$script:AutoChartMainPanel49.Top) }

        }
        `$script:AutoChartMainPanel$ChartNumber.Left = `$ChartLocation[0]
        `$script:AutoChartMainPanel$ChartNumber.Top  = `$ChartLocation[1]


        # Sets the Chart Color
        if (-not `$ChartColor) {
            `$array1 =  @(1,11,21,31,41)
            `$array2 =  @(2,12,22,32,42)
            `$array3 =  @(3,13,23,33,43)
            `$array4 =  @(4,14,24,34,44)
            `$array5 =  @(5,15,25,35,45)
            `$array6 =  @(6,16,26,36,46)
            `$array7 =  @(7,17,27,37,47)
            `$array8 =  @(8,18,28,38,48)
            `$array9 =  @(9,19,29,39,49)
            `$array0 = @(10,20,30,40,50)

            switch ($ChartNumber) {
                {`$array1 -contains `$_} { `$ChartColor = 'Red' }
                {`$array2 -contains `$_} { `$ChartColor = 'Blue' }
                {`$array3 -contains `$_} { `$ChartColor = 'Green' }
                {`$array4 -contains `$_} { `$ChartColor = 'Orange' }
                {`$array5 -contains `$_} { `$ChartColor = 'Brown' }
                {`$array6 -contains `$_} { `$ChartColor = 'Gray' }
                {`$array7 -contains `$_} { `$ChartColor = 'SlateBlue' }
                {`$array8 -contains `$_} { `$ChartColor = 'Purple' }
                {`$array9 -contains `$_} { `$ChartColor = 'DarkGreen' }
                {`$array0 -contains `$_} { `$ChartColor = 'Yellow' }
            }
        }


        `$script:GeneratedAutoChart$ChartNumber = New-object System.Windows.Forms.DataVisualization.Charting.Chart -Property @{
            Left            = 0
            Top             = 0
            Width           = `$FormScale * 560
            Height          = `$FormScale * 375
            BackColor       = [System.Drawing.Color]::White
            BorderColor     = 'Black'
            Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','20', [System.Drawing.FontStyle]::Bold)
            BorderDashStyle = 'Solid'
            Add_MouseHover  = {
                `$script:GeneratedAutoChartOptionsButton$ChartNumber.Text = 'Options v'
                `$script:GeneratedAutoChart$ChartNumber.Controls.Remove(`$script:GeneratedAutoChartManipulationPanel$ChartNumber)
            }
        }


        `$script:GeneratedAutoChartTitle$ChartNumber = New-Object System.Windows.Forms.DataVisualization.Charting.Title -Property @{
            Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
            Alignment = "topcenter"
        }
        `$script:GeneratedAutoChart$ChartNumber.Titles.Add(`$script:GeneratedAutoChartTitle$ChartNumber)


        `$script:GeneratedAutoChartArea$ChartNumber                         = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        `$script:GeneratedAutoChartArea$ChartNumber.Name                    = 'Chart Area'
        `$script:GeneratedAutoChartArea$ChartNumber.AxisX.Interval          = 1
        `$script:GeneratedAutoChartArea$ChartNumber.AxisX.Title             = `$TitleAxisX
        `$script:GeneratedAutoChartArea$ChartNumber.AxisY.Title             = `$TitleAxisY
        `$script:GeneratedAutoChartArea$ChartNumber.AxisY.IntervalAutoMode  = `$true
        `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Enable3D    = `$false
        `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Inclination = 75
        `$script:GeneratedAutoChart$ChartNumber.ChartAreas.Add(`$script:GeneratedAutoChartArea$ChartNumber)


        `$script:GeneratedAutoChart$ChartNumber.Series.Add(`$script:SeriesName$ChartNumber)
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Enabled           = `$True
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].BorderWidth       = 1
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].IsVisibleInLegend = `$false
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Chartarea         = 'Chart Area'
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Legend            = 'Legend'
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber]['PieLineColor']   = 'Black'
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber]['PieLabelStyle']  = 'Outside'
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].ChartType         = `$ChartType
        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Color             = `$ChartColor


                        `$script:GeneratedAutoChartCsvFileHosts$ChartNumber      = `$script:SourceCSVData$ChartNumber | Select-Object -ExpandProperty `$script:PropertyY$ChartNumber -Unique
                        `$script:GeneratedAutoChartUniqueDataFields$ChartNumber  = `$script:SourceCSVData$ChartNumber | Select-Object -Property `$script:PropertyX$ChartNumber | Sort-Object -Property `$script:PropertyX$ChartNumber -Unique | Where {`$_.`$script:PropertyX$ChartNumber -ne `$null -and `$_.`$script:PropertyX$ChartNumber -ne ''}

                        `$script:AutoChartsProgressBar.ForeColor = 'Blue'
                        `$script:AutoChartsProgressBar.Minimum = 0
                        `$script:AutoChartsProgressBar.Maximum = `$script:GeneratedAutoChartUniqueDataFields$ChartNumber.count
                        `$script:AutoChartsProgressBar.Value   = 0
                        `$script:AutoChartsProgressBar.Update()

                        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.Clear()

                        if (`$script:GeneratedAutoChartUniqueDataFields$ChartNumber.count -gt 0){
                            `$script:GeneratedAutoChartTitle$ChartNumber.ForeColor = 'Black'
                            `$script:GeneratedAutoChartTitle$ChartNumber.Text = `$script:SeriesName$ChartNumber

                            # If the Second field/Y Axis equals ComputerName, it counts it
                            `$script:GeneratedAutoChartOverallDataResults$ChartNumber = @()

                            # Generates and Counts the data - Counts the number of times that any given property possess a given value
                            foreach (`$DataField in `$script:GeneratedAutoChartUniqueDataFields$ChartNumber) {
                                `$Count = 0
                                `$script:GeneratedAutoChartCsvComputers$ChartNumber = @()
                                foreach ( `$Line in `$script:SourceCSVData$ChartNumber ) {
                                    if (`$(`$Line.`$script:PropertyX$ChartNumber) -eq `$DataField.`$script:PropertyX$ChartNumber) {
                                        `$Count += 1
                                        if ( `$script:GeneratedAutoChartCsvComputers$ChartNumber -notcontains `$(`$Line.`$script:PropertyY$ChartNumber) ) { `$script:GeneratedAutoChartCsvComputers$ChartNumber += `$(`$Line.`$script:PropertyY$ChartNumber) }
                                    }
                                }
                                `$script:GeneratedAutoChartUniqueCount$ChartNumber = `$script:GeneratedAutoChartCsvComputers$ChartNumber.Count
                                `$script:GeneratedAutoChartDataResults$ChartNumber = New-Object PSObject -Property @{
                                    DataField   = `$DataField
                                    TotalCount  = `$Count
                                    UniqueCount = `$script:GeneratedAutoChartUniqueCount$ChartNumber
                                    Computers   = `$script:GeneratedAutoChartCsvComputers$ChartNumber
                                }
                                `$script:GeneratedAutoChartOverallDataResults$ChartNumber += `$script:GeneratedAutoChartDataResults$ChartNumber
                                `$script:AutoChartsProgressBar.Value += 1
                                `$script:AutoChartsProgressBar.Update()
                            }
                            `$script:GeneratedAutoChartOverallDataResults$ChartNumber | Sort-Object -Property UniqueCount | ForEach-Object { `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.AddXY(`$_.DataField.`$script:PropertyX$ChartNumber,`$_.UniqueCount) }
                            `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.SetRange(0, `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count))
                            `$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber.SetRange(0, `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count))
                        }
                        else {
                            `$script:GeneratedAutoChartTitle$ChartNumber.ForeColor = 'Red'
                            `$script:GeneratedAutoChartTitle$ChartNumber.Text = "`$SeriesName`n`n[ No Unique Data Available ]`n"
                        }


        ### Auto Chart Panel that contains all the options to manage open/close feature
        `$script:GeneratedAutoChartOptionsButton$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = "Options v"
            Left   = `$script:GeneratedAutoChart$ChartNumber.Left + `$(`$FormScale * 5)
            Top    = `$script:GeneratedAutoChart$ChartNumber.Top + `$(`$FormScale * 350)
            Width  = `$FormScale * 75
            Height = `$FormScale * 20
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChartOptionsButton$ChartNumber
        `$script:GeneratedAutoChartOptionsButton$ChartNumber.Add_Click({
            if (`$script:GeneratedAutoChartOptionsButton$ChartNumber.Text -eq 'Options v') {
                `$script:GeneratedAutoChartOptionsButton$ChartNumber.Text = 'Options ^'
                `$script:GeneratedAutoChart$ChartNumber.Controls.Add(`$script:GeneratedAutoChartManipulationPanel$ChartNumber)
            }
            elseif (`$script:GeneratedAutoChartOptionsButton$ChartNumber.Text -eq 'Options ^') {
                `$script:GeneratedAutoChartOptionsButton$ChartNumber.Text = 'Options v'
                `$script:GeneratedAutoChart$ChartNumber.Controls.Remove(`$script:GeneratedAutoChartManipulationPanel$ChartNumber)
            }
        })
        `$script:AutoChartMainPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartOptionsButton$ChartNumber)
        `$script:AutoChartMainPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChart$ChartNumber)


        `$script:GeneratedAutoChartManipulationPanel$ChartNumber = New-Object System.Windows.Forms.Panel -Property @{
            Left        = 0
            Top         = `$script:GeneratedAutoChart$ChartNumber.Height - `$(`$FormScale * 121)
            Width       = `$script:GeneratedAutoChart$ChartNumber.Width
            Height      = `$FormScale * 121
            Font        = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ForeColor   = 'Black'
            BackColor   = 'White'
            BorderStyle = 'FixedSingle'
        }


        `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber = New-Object System.Windows.Forms.GroupBox -Property @{
            Text      = "Trim Off First: 0"
            Left      = `$FormScale * 5
            Top       = `$FormScale * 5
            Width     = `$FormScale * 165
            Height    = `$FormScale * 85
            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
                `$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber = New-Object System.Windows.Forms.TrackBar -Property @{
                    Left          = `$FormScale * 1
                    Top           = `$FormScale * 30
                    Width         = `$FormScale * 160
                    Height        = `$FormScale * 25
                    Orientation   = "Horizontal"
                    TickFrequency = 1
                    TickStyle     = "TopLeft"
                    Minimum       = 0
                    Value         = 0
                }
                `$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber.SetRange(0, `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count))
                `$script:GeneratedAutoChartTrimOffFirstTrackBarValue$ChartNumber = 0
                `$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber.add_ValueChanged({
                    `$script:GeneratedAutoChartTrimOffFirstTrackBarValue$ChartNumber = `$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber.Value
                    `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Text = "Trim Off First: `$(`$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber.Value)"
                    `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.Clear()
                    `$script:GeneratedAutoChartOverallDataResults$ChartNumber | Sort-Object -Property UniqueCount | Select-Object -skip `$script:GeneratedAutoChartTrimOffFirstTrackBarValue$ChartNumber | Select-Object -SkipLast `$script:GeneratedAutoChartTrimOffLastTrackBarValue$ChartNumber | ForEach-Object {`$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.AddXY(`$_.DataField.`$script:PropertyX$ChartNumber,`$_.UniqueCount)}
                })
                `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Controls.Add(`$script:GeneratedAutoChartTrimOffFirstTrackBar$ChartNumber)
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber)


        `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber = New-Object System.Windows.Forms.GroupBox -Property @{
            Text      = "Trim Off Last: 0"
            Left      = `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Left + `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Width + `$(`$FormScale * 8)
            Top       = `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Top
            Width     = `$FormScale * 165
            Height    = `$FormScale * 85
            Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
                `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber = New-Object System.Windows.Forms.TrackBar -Property @{
                    Left          = `$FormScale * 1
                    Top           = `$FormScale * 30
                    Width         = `$FormScale * 160
                    Height        = `$FormScale * 25
                    Orientation   = "Horizontal"
                    TickFrequency = 1
                    TickStyle     = "TopLeft"
                    Minimum       = 0
                }
                `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.RightToLeft   = `$true
                `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.SetRange(0, `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count))
                `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.Value = `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count)
                `$script:GeneratedAutoChartTrimOffLastTrackBarValue$ChartNumber = 0
                `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.add_ValueChanged({
                    `$script:GeneratedAutoChartTrimOffLastTrackBarValue$ChartNumber = `$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count) - `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.Value
                    `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber.Text = "Trim Off Last: `$(`$(`$script:GeneratedAutoChartOverallDataResults$ChartNumber.count) - `$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber.Value)"
                    `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.Clear()
                    `$script:GeneratedAutoChartOverallDataResults$ChartNumber | Sort-Object -Property UniqueCount | Select-Object -skip `$script:GeneratedAutoChartTrimOffFirstTrackBarValue$ChartNumber | Select-Object -SkipLast `$script:GeneratedAutoChartTrimOffLastTrackBarValue$ChartNumber | ForEach-Object {`$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.AddXY(`$_.DataField.`$script:PropertyX$ChartNumber,`$_.UniqueCount)}
                })
                `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber.Controls.Add(`$script:GeneratedAutoChartTrimOffLastTrackBar$ChartNumber)
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber)


        # Auto Create Charts Select Chart Type
        #======================================
        `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber = New-Object System.Windows.Forms.ComboBox -Property @{
            Text               = 'Column'
            Left               = `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Left + `$(`$FormScale * 80)
            Top                = `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Top + `$script:GeneratedAutoChartTrimOffFirstGroupBox$ChartNumber.Height + `$(`$FormScale * 5)
            Width              = `$FormScale * 85
            Height             = `$FormScale * 20
            Font               = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.add_SelectedIndexChanged({
            `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].ChartType = `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.SelectedItem
        })
        `$script:GeneratedAutoChartChartTypesAvailable$ChartNumber = @('Column','Pie','Line','Bar','Doughnut','Area','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
        ForEach (`$Item in `$script:GeneratedAutoChartChartTypesAvailable$ChartNumber) { `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.Items.Add(`$Item) }
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartChartTypeComboBox$ChartNumber)


        ### Auto Charts Toggle 3D on/off and inclination angle
        `$script:GeneratedAutoChart3DToggleButton$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = "3D Off"
            Left   = `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.Left + `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.Width + `$(`$FormScale * 8)
            Top    = `$script:GeneratedAutoChartChartTypeComboBox$ChartNumber.Top
            Width  = `$FormScale * 65
            Height = `$FormScale * 20
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChart3DToggleButton$ChartNumber
        `$script:GeneratedAutoChart3DInclination$ChartNumber = 0
        `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Add_Click({

            `$script:GeneratedAutoChart3DInclination$ChartNumber += 10
            if ( `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Text -eq "3D Off" ) {
                `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Enable3D    = `$true
                `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Inclination = `$script:GeneratedAutoChart3DInclination$ChartNumber
                `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Text  = "3D On (`$script:GeneratedAutoChart3DInclination$ChartNumber)"
            }
            elseif ( `$script:GeneratedAutoChart3DInclination$ChartNumber -le 90 ) {
                `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Inclination = `$script:GeneratedAutoChart3DInclination$ChartNumber
                `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Text  = "3D On (`$script:GeneratedAutoChart3DInclination$ChartNumber)"
            }
            else {
                `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Text  = "3D Off"
                `$script:GeneratedAutoChart3DInclination$ChartNumber = 0
                `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Inclination = `$script:GeneratedAutoChart3DInclination$ChartNumber
                `$script:GeneratedAutoChartArea$ChartNumber.Area3DStyle.Enable3D    = `$false
            }
        })
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChart3DToggleButton$ChartNumber)

        ### Change the color of the chart
        `$script:GeneratedAutoChartChangeColorComboBox$ChartNumber = New-Object System.Windows.Forms.ComboBox -Property @{
            Text               = "Change Color"
            Left               = `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Left + `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Width + `$(`$FormScale * 5)
            Top                = `$script:GeneratedAutoChart3DToggleButton$ChartNumber.Top
            Width              = `$FormScale * 95
            Height             = `$FormScale * 20
            Font               = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        `$script:GeneratedAutoChartColorsAvailable$ChartNumber = @('Red','Blue','Green','Orange','Brown','Gray','SlateBlue','Purple','DarkGreen','Yellow')
        ForEach (`$Item in `$script:GeneratedAutoChartColorsAvailable$ChartNumber) { `$script:GeneratedAutoChartChangeColorComboBox$ChartNumber.Items.Add(`$Item) }
        `$script:GeneratedAutoChartChangeColorComboBox$ChartNumber.add_SelectedIndexChanged({
            `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Color = `$script:GeneratedAutoChartChangeColorComboBox$ChartNumber.SelectedItem
        })
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartChangeColorComboBox$ChartNumber)


        function script:InvestigateDifference-AutoChart$ChartNumber {
            # List of Positive Endpoints that positively match
            `$script:GeneratedAutoChartImportCsvPosResults$ChartNumber = `$script:SourceCSVData$ChartNumber  | Where-Object `$script:PropertyX$ChartNumber -eq `$(`$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber.Text) | Select-Object -ExpandProperty `$script:PropertyY$ChartNumber -Unique
            `$script:GeneratedAutoChartInvestDiffPosResultsTextBox$ChartNumber.Text = ''
            ForEach (`$Endpoint in `$script:GeneratedAutoChartImportCsvPosResults$ChartNumber) { `$script:GeneratedAutoChartInvestDiffPosResultsTextBox$ChartNumber.Text += "`$Endpoint`r`n" }

            # List of all endpoints within the csv file
            `$script:GeneratedAutoChartImportCsvAll$ChartNumber = `$script:SourceCSVData$ChartNumber | Select-Object -ExpandProperty `$script:PropertyY$ChartNumber -Unique

            `$script:GeneratedAutoChartImportCsvNegResults$ChartNumber = @()
            # Creates a list of Endpoints with Negative Results
            foreach (`$Endpoint in `$script:GeneratedAutoChartImportCsvAll$ChartNumber) { if (`$Endpoint -notin `$script:GeneratedAutoChartImportCsvPosResults$ChartNumber) { `$script:GeneratedAutoChartImportCsvNegResults$ChartNumber += `$Endpoint } }

            # Populates the listbox with Negative Endpoint Results
            `$script:GeneratedAutoChartInvestDiffNegResultsTextBox$ChartNumber.Text = ''
            ForEach (`$Endpoint in `$script:GeneratedAutoChartImportCsvNegResults$ChartNumber) { `$script:GeneratedAutoChartInvestDiffNegResultsTextBox$ChartNumber.Text += "`$Endpoint`r`n" }

            # Updates the label to include the count
            `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Text = "Positive Match (`$(`$script:GeneratedAutoChartImportCsvPosResults$ChartNumber.count))"
            `$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber.Text = "Negative Match (`$(`$script:GeneratedAutoChartImportCsvNegResults$ChartNumber.count))"
        }


        `$script:GeneratedAutoChartCheckDiffButton$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = 'Investigate'
            Left   = `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber.Left + `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber.Width + `$(`$FormScale * 5)
            Top    = `$script:GeneratedAutoChartTrimOffLastGroupBox$ChartNumber.Top + `$(`$FormScale * 5)
            Width  = `$FormScale * 100
            Height = `$FormScale * 23
            Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChartCheckDiffButton$ChartNumber
        `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Add_Click({
            `$script:GeneratedAutoChartInvestDiffDropDownArray$ChartNumber = `$script:SourceCSVData$ChartNumber | Select-Object -Property `$script:PropertyX$ChartNumber -ExpandProperty `$script:PropertyX$ChartNumber | Sort-Object -Unique

            ### Investigate Difference Compare Csv Files Form
            `$script:GeneratedAutoChartInvestDiffForm$ChartNumber = New-Object System.Windows.Forms.Form -Property @{
                Text          = 'Investigate Difference'
                Width         = `$FormScale * 330
                Height        = `$FormScale * 360
                Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$Dependencies\Images\favicon.ico")
                StartPosition = "CenterScreen"
                ControlBox    = `$true
                Add_Closing   = { `$This.dispose() }
            }

            ### Investigate Difference Drop Down Label & ComboBox
            `$script:GeneratedAutoChartInvestDiffDropDownLabel$ChartNumber = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Investigate the difference between computers."
                Left   = `$FormScale * 10
                Top    = `$FormScale * 10
                Width  = `$FormScale * 290
                Height = `$FormScale * 60
                Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            }
            `$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber = New-Object System.Windows.Forms.ComboBox -Property @{
                Left   = `$FormScale * 10
                Top    = `$script:GeneratedAutoChartInvestDiffDropDownLabel$ChartNumber.Top + `$script:GeneratedAutoChartInvestDiffDropDownLabel$ChartNumber.Height
                Width  = `$Formscale * 290
                Height = `$Formscale * 30
                Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                AutoCompleteSource = "ListItems"
                AutoCompleteMode   = "SuggestAppend"
                Add_KeyDown = { if (`$_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart$ChartNumber } }
                Add_Click   = { script:InvestigateDifference-AutoChart$ChartNumber }
            }
            ForEach (`$Item in `$script:GeneratedAutoChartInvestDiffDropDownArray$ChartNumber) { `$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber.Items.Add(`$Item) }



            `$script:GeneratedAutoChartInvestDiffExecuteButton$ChartNumber = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute"
                Left   = `$FormScale * 10
                Top    = `$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber.Top + `$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber.Height + `$(`$FormScale * 5)
                Width  = `$Formscale * 100
                Height = `$Formscale * 20
                Add_KeyDown = { if (`$_.KeyCode -eq "Enter") { script:InvestigateDifference-AutoChart$ChartNumber } }
                Add_Click   = { script:InvestigateDifference-AutoChart$ChartNumber }
            }
            Add-CommonButtonSettings -Button `$script:GeneratedAutoChartInvestDiffExecuteButton$ChartNumber


            `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Positive Match (+)"
                Left   = `$FormScale * 10
                Top    = `$script:GeneratedAutoChartInvestDiffExecuteButton$ChartNumber.Top + `$script:GeneratedAutoChartInvestDiffExecuteButton$ChartNumber.Height + `$(`$FormScale *  10)
                Width  = `$FormScale * 100
                Height = `$FormScale * 22
                Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            }
            `$script:GeneratedAutoChartInvestDiffPosResultsTextBox$ChartNumber = New-Object System.Windows.Forms.TextBox -Property @{
                Left       = `$FormScale * 10
                Top        = `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Top + `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Height
                Width      = `$FormScale * 100
                Height     = `$FormScale * 178
                Font       = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                ReadOnly   = `$true
                BackColor  = 'White'
                WordWrap   = `$false
                Multiline  = `$true
                ScrollBars = "Vertical"
            }

            `$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Negative Match (-)"
                Left   = `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Left + `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Width + `$(`$FormScale *  10)
                Top    = `$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber.Top
                Width  = `$FormScale * 100
                Height = `$FormScale * 22
                Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            }
            `$script:GeneratedAutoChartInvestDiffNegResultsTextBox$ChartNumber = New-Object System.Windows.Forms.TextBox -Property @{
                Left       = `$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber.Left
                Top        = `$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber.Top + `$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber.Height
                Width      = `$FormScale * 100
                Height     = `$FormScale * 178
                Font       = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                ReadOnly   = `$true
                BackColor  = 'White'
                WordWrap   = `$false
                Multiline  = `$true
                ScrollBars = "Vertical"
            }
            `$script:GeneratedAutoChartInvestDiffForm$ChartNumber.Controls.AddRange(@(`$script:GeneratedAutoChartInvestDiffDropDownLabel$ChartNumber,`$script:GeneratedAutoChartInvestDiffDropDownComboBox$ChartNumber,`$script:GeneratedAutoChartInvestDiffExecuteButton$ChartNumber,`$script:GeneratedAutoChartInvestDiffPosResultsLabel$ChartNumber,`$script:GeneratedAutoChartInvestDiffPosResultsTextBox$ChartNumber,`$script:GeneratedAutoChartInvestDiffNegResultsLabel$ChartNumber,`$script:GeneratedAutoChartInvestDiffNegResultsTextBox$ChartNumber))
            `$script:GeneratedAutoChartInvestDiffForm$ChartNumber.add_Load(`$OnLoadForm_StateCorrection)
            `$script:GeneratedAutoChartInvestDiffForm$ChartNumber.ShowDialog()
        })
        `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Add_MouseHover({
            Show-ToolTip -Title "Investigate Difference" -Icon "Info" -Message "+  Allows you to quickly search for the differences`n`n"
        })
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.controls.Add(`$script:GeneratedAutoChartCheckDiffButton$ChartNumber)


        `$AutoChart01ExpandChartButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = 'Under Dev'
            Left      = `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Left + `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Width + `$(`$FormScale * 5)
            Top       = `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Top
            Width     = `$FormScale * 100
            Height    = `$FormScale * 23
            Add_Click = {
                #script:New-PowerShellChart -SourceCSVData `$script:AutoChartDataSourceCsv$JobId -ChartNumber `$count -SeriesName `$Property -TitleAxisX `$Property -TitleAxisY 'Endpoint Count' -PropertyX `$Property -PropertyY 'ComputerName'
                Generate-AutoChartsCommand -FilePath `$script:AutoChartDataSourceCsv$JobId -QueryName "Processes" -QueryTabName `$script:SeriesName$ChartNumber -PropertyX `$script:PropertyX$ChartNumber -PropertyY `$script:PropertyY$ChartNumber
            }
        }
        Add-CommonButtonSettings -Button `$AutoChart01ExpandChartButton
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$AutoChart01ExpandChartButton)


        `$script:GeneratedAutoChartOpenInShell$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = "Open In Shell"
            Left   = `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Left
            Top    = `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Top + `$script:GeneratedAutoChartCheckDiffButton$ChartNumber.Height + `$(`$FormScale * 5)
            Width  = `$FormScale * 100
            Height = `$FormScale * 23
            Add_Click = {
                `$ViewImportResults = `$script:SourceXMLPath$ChartNumber
                if ((Test-Path `$ViewImportResults)) {
                    `$SavePath = Split-Path -Path `$ViewImportResults
                    `$FileName = Split-Path -Path `$ViewImportResults -Leaf
                    script:Open-XmlResultsInShell -ViewImportResults `$ViewImportResults -FileName `$FileName -SavePath `$SavePath
                }
                else {
                    Show-MessageBox -Message "Error: Cannot Import Data!`nThe associated .xml file was not located." -Title "PoSh-EasyWin" -Options "Ok" -Type "Error" -Sound
                }
            }
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChartOpenInShell$ChartNumber
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.controls.Add(`$script:GeneratedAutoChartOpenInShell$ChartNumber)


        `$script:GeneratedAutoChartGridView$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = "GridView"
            Left   = `$script:GeneratedAutoChartOpenInShell$ChartNumber.Left + `$script:GeneratedAutoChartOpenInShell$ChartNumber.Width + `$(`$FormScale * 5)
            Top    = `$script:GeneratedAutoChartOpenInShell$ChartNumber.Top
            Width  = `$FormScale * 100
            Height = `$FormScale * 23
            Add_Click = {
                if (`$script:SourceCSVData$ChartNumber) {
                    `$script:SourceCSVData$ChartNumber | Out-GridView -Title `$script:SeriesName$ChartNumber
                }
                else {
                    Show-MessageBox -Message "No CSV data available." -Title "PoSh-EasyWin" -Options "Ok" -Type "Information" -Sound
                }
            }
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChartGridView$ChartNumber
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.controls.Add(`$script:GeneratedAutoChartGridView$ChartNumber)


        `$script:GeneratedAutoChartSaveButton$ChartNumber = New-Object Windows.Forms.Button -Property @{
            Text   = "Save Chart"
            Left   = `$script:GeneratedAutoChartOpenInShell$ChartNumber.Left
            Top    = `$script:GeneratedAutoChartOpenInShell$ChartNumber.Top + `$script:GeneratedAutoChartOpenInShell$ChartNumber.Height + `$(`$FormScale * 5)
            Width  = `$FormScale * 205
            Height = `$FormScale * 23
        }
        Add-CommonButtonSettings -Button `$script:GeneratedAutoChartSaveButton$ChartNumber
        [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
        `$script:GeneratedAutoChartSaveButton$ChartNumber.Add_Click({
            Save-ChartImage -Chart `$script:GeneratedAutoChart$ChartNumber -Title `$script:GeneratedAutoChartTitle$ChartNumber
        })
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.controls.Add(`$script:GeneratedAutoChartSaveButton$ChartNumber)


        `$script:GeneratedAutoChartNoticeTextbox$ChartNumber = New-Object System.Windows.Forms.Textbox -Property @{
            Left        = `$script:GeneratedAutoChartSaveButton$ChartNumber.Left
            Top         = `$script:GeneratedAutoChartSaveButton$ChartNumber.Top + `$script:GeneratedAutoChartSaveButton$ChartNumber.Height + `$(`$FormScale * 6)
            Width       = `$FormScale * 205
            Height      = `$FormScale * 25
            Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
            Font        = New-Object System.Drawing.Font("Courier New",`$(`$FormScale * 11),0,0,0)
            ForeColor   = 'Black'
            Text        = "Endpoints:  `$(`$script:GeneratedAutoChartCsvFileHosts$ChartNumber.Count)"
            Multiline   = `$false
            Enabled     = `$false
            BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
        }
        `$script:GeneratedAutoChartManipulationPanel$ChartNumber.Controls.Add(`$script:GeneratedAutoChartNoticeTextbox$ChartNumber)


        `$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.Clear()
        `$script:GeneratedAutoChartOverallDataResults$ChartNumber | Sort-Object -Property UniqueCount | Select-Object -skip `$script:GeneratedAutoChartTrimOffFirstTrackBarValue$ChartNumber | Select-Object -SkipLast `$script:GeneratedAutoChartTrimOffLastTrackBarValue$ChartNumber | ForEach-Object {`$script:GeneratedAutoChart$ChartNumber.Series[`$script:SeriesName$ChartNumber].Points.AddXY(`$_.DataField.`$script:PropertyX$ChartNumber,`$_.UniqueCount)}
"@
    }



















#########################################################
# Monitor Mode, is not the same as Individual Execution #
#########################################################
if ($MonitorMode) {
    if (-not $AutoReRun) {
        $MainBottomTabControl.SelectedTab = $Section3MonitorJobsTab
    }

    # Creates locations to saves the results from jobs
    if (-not (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)")){
        New-Item -Type Directory "$($script:CollectionSavedDirectoryTextBox.Text)" -Force -ErrorAction SilentlyContinue
    }

    #Get-Job | Sort-Object Id | Select-Object -Last 1 -ExpandProperty ID

    $script:AllJobs = Get-Job -Name "PoSh-EasyWin: *"

    Invoke-Expression @"
    function script:Remove-JobsFunction$JobId {
        if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
            Remove-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" -Force
            Remove-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -Force
        }

        `$script:CurrentJobs$JobId | Stop-Job -ErrorAction SilentlyContinue
        `$script:CurrentJobs$JobId | Remove-Job -Force -ErrorAction SilentlyContinue

        # Moves all form items higher up that are not created before this one
        Get-Variable | Where-Object {`$_.Name -match 'Section3MonitorJobPanel'} | Foreach-Object {
            if (`$_.Name -notin `$script:PreviousJobFormItemsList$JobId){
                `$_.Value.top = `$_.Value.Top - `$script:JobsRowHeight - `$script:JobsRowGap - (`$FormScale * 4)
            }
        }

        `$script:MonitorJobsTopPosition -= `$script:Section3MonitorJobPanel$JobId.Height + `$script:JobsRowGap


        `$script:Section3MonitorJobsTab.Controls.Remove(`$script:Section3MonitorJobPanel$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobLabel$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonStatus$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonDetails$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobProgressBar$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonRemove$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobOptionsButton$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonOne$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonTwo$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonThree$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonFour$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobKeepDataCheckbox$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:MonitorJobsButtonMonitor$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobNotifyCheckbox$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobTransparentLabel$JobId)

        Remove-Variable -Name Section3MonitorJobPanel$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobLabel$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobDetailsButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobCommandButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobViewCommandForm$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobViewCommandRichTextBox$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobProgressBar$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobRemoveButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobOptionsButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobViewButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobShellButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobChartsButton$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobKeepDataCheckbox$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobContinuousCheckbox$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobNotifyCheckbox$JobId -Scope Script
        Remove-Variable -Name Section3MonitorJobTransparentLabel$JobId -Scope Script

        Remove-Variable -Name CurrentJobs$JobId -Scope Script
        Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope Script
        Remove-Variable -Name JobsStartedCount$JobId -Scope Script
        Remove-Variable -Name JobsNotRunning$JobId -Scope Script
        Remove-Variable -Name CurrentTime$JobId -Scope Script
        Remove-Variable -Name JobsTimeCompleted$JobId -Scope Script
        Remove-Variable -Name Timer$JobId -Scope Script
        Remove-Variable -Name SelectedFilesToDownload$JobId -scope Script

        # This variable is required to pass along the job name to various sections
        #Remove-Variable -Name JobName$JobId -Scope Script

        # This variable is required for the auto re-run feature
        #Remove-Variable -Name RestartTime$JobId -Scope Script

        # This variable is required to pass the script into the next auto re-run
        #Remove-Variable -Name SmithScript$JobId -Scope Script

        # Garbage Collection to free up memory
        [System.GC]::Collect()
    }

    `$script:SmithScript$JobId  = `$SmithScript
    `$script:RestartTime$JobId  = `$RestartTime
    `$script:InputValues$JobId  = `$InputValues
    `$script:ArgumentList$JobId = `$ArgumentList
    `$CollectionName$JobId      = `$CollectionName
"@

    if ($SMITH) {
       Invoke-Expression @"
       `$script:SmithScript$JobId  = `$SmithScript
       `$script:RestartTime$JobId  = `$RestartTime
       `$script:InputValues$JobId  = `$InputValues
       `$script:ArgumentList$JobId = `$ArgumentList
"@
   }

    if ($PSWriteHTMLSwitch) {
        Invoke-Expression @"
        `$script:PSWriteHTML$JobId         = `$PSWriteHTML
        `$script:PSWriteHTMLFilePath$JobId = `$PSWriteHTMLFilePath
        `$script:PSWriteHTMLOptions$JobId  = `$PSWriteHTMLOptions
        `$CollectionName$JobId             = `$CollectionName


        if (`$script:PSWriteHTML$JobId -eq 'EndpointDataSystemSnapshot') {
            `$script:JobName$JobId = "Endpoint Analysis `$(`$(`$script:PSWriteHTMLOptions$JobId).count) `$(`$CollectionName$JobId) (Browser)"
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLProcesses') {
            `$script:JobName$JobId = 'Process Data (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointDataNetworkConnections') {
            `$script:JobName$JobId = 'Network Connections (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointProcessAndNetwork') {
            `$script:JobName$JobId = 'Process And Network (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointDataConsoleLogons') {
            `$script:JobName$JobId = 'Console Logons (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'PowerShellSessionsData') {
            `$script:JobName$JobId = 'PowerShell Sessions (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointApplicationCrashes') {
            `$script:JobName$JobId = 'Application Crashes (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointLogonActivity') {
            `$script:JobName$JobId = 'Logon Activity (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLADUsers') {
            `$script:JobName$JobId = 'Active Directory Users (Browser)'
        }
        elseif (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLADComputers') {
            `$script:JobName$JobId = 'Active Directory Computers (Browser)'
        }
"@
    }
    else {
        Invoke-Expression @"
        `$script:JobName$JobId = `$CollectionName
"@
    }


    Invoke-Expression @"
        # Timer that updates the GUI on interval
        `$script:Timer$JobId = New-Object System.Windows.Forms.Timer -Property @{
            Enabled  = `$true
            Interval = 250 #1000 = 1 second
        }
        `$script:Timer$JobId.Start()


        `$script:CurrentJobs$JobId = @()
        foreach (`$Job in `$script:AllJobs) {
            if (`$Job.Id -notin `$script:PastJobsIDList) {
                `$script:PastJobsIDList += `$Job.Id
                `$script:CurrentJobs$JobId += `$Job
            }
        }


        # Sets the job timeout value, so they don't run forever
        `$script:JobsTimer$JobId  = [int]`$(`$script:OptionJobTimeoutSelectionComboBox.Text)

        `$script:JobStartTime$JobId = Get-Date
        `$script:JobStartTimeFileFriendly$JobId = `$(`$script:JobStartTime$JobId).ToString('yyyy-MM-dd HH.mm.ss')
        `$script:PreviousJobFormItemsList$JobId = `$script:PreviousJobFormItemsList
        `$script:JobCompletionMessageShown$JobId = `$false
        `$script:JobsRowHeight = (`$FormScale * 47) #(`$FormScale * 22)
        `$script:JobsRowGap = `$FormScale * 5
        `$script:JobsStartedCount$JobId = `$script:CurrentJobs$JobId.count


        #`$TempSaveJobName = `$script:CurrentJobs$JobId[0].Name
        #`$script:JobSaveName$JobId = ((`$TempSaveJobName -replace 'PoSh-EasyWin: ','').split('-')[0..`$(`$TempSaveJobName.split('-').GetUpperBound(0)-2)] -join '-').trim(' -')


        `$script:Section3MonitorJobPanel$JobId = New-Object System.Windows.Forms.panel -Property @{
            Left      = `$script:MonitorJobsLeftPosition
            Top       = `$script:MonitorJobsTopPosition
            Width     = `$FormScale * 730
            Height    = `$script:JobsRowHeight + (`$FormScale * 4)
        }


        `$script:Section3MonitorJobLabel$JobId = New-Object System.Windows.Forms.Label -Property @{
            Text      = "`$(`$script:JobStartTime$JobId)`n "
            Left      = 0
            Top       = `$FormScale * 5
            Width     = `$FormScale * 115
            Height    = `$FormScale * 22
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            ForeColor = 'Blue'
        }


        `$script:Section3MonitorJobProgressBar$JobId = New-Object System.Windows.Forms.ProgressBar -Property @{
            Left      = `$script:Section3MonitorJobLabel$JobId.Left
            Top       =  (`$FormScale * 22) + (`$FormScale * 8)
            Width     = `$FormScale * 371 #261
            Height    = `$FormScale * 22
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            Value     = 0
            Minimum   = 0
            Maximum   = `$script:JobsStartedCount$JobId
            Forecolor = 'LightBlue'
            BackColor = 'white'
            Style     = 'Continuous' #Marque
        }

        `$script:Section3MonitorJobTransparentLabel$JobId = New-Object System.Windows.Forms.Label -Property @{
            Text      = "Endpoint Count:  0 / `$script:JobsStartedCount$JobId `n`$script:JobName$JobId"
            Left      = `$script:Section3MonitorJobLabel$JobId.Left + `$script:Section3MonitorJobLabel$JobId.Width + (`$FormScale * 5)
            Top       = `$script:Section3MonitorJobLabel$JobId.Top
            Width     = `$FormScale * 251
            Height    = (`$script:JobsRowHeight / 2) - `$(`$FormScale * 2)
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            ForeColor = 'Blue'
            BackColor = [System.Drawing.Color]::FromName('Transparent')
        }
"@

        ##############
        #  Button 1  #
        ##############
        if ($PcapSwitch) {
            Invoke-Expression @"
                `$script:EndpointName$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-2]
                `$script:JobData$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-1]

                `$script:Section3MonitorJobTransparentLabel$JobId.text = "Endpoint Count:  0 / `$script:JobsStartedCount$JobId `n`$(`$script:EndpointName$JobId):  `$script:JobName$JobId"

                `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                    text      = 'Open PCap'
                    Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                    Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                    Width     = `$FormScale * 125
                    Height    = `$FormScale * 21
                    Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                    Add_click = {
                        if (`$This.BackColor -ne 'LightGray') {
                            `$This.BackColor = 'LightGray'
                        }
                        if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng")) {
                            Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng"
                        }
                        else {
                            [System.Windows.Forms.MessageBox]::Show("There is no pcap data available.",'PoSh-EasyWin')
                        }
                    }
                }
"@
        }
        elseif ($EVTXSwitch) {
            Invoke-Expression @"
            `$script:EVTXLogfILE$JobId = "$EVTXLocalSavePath"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Event Viewer'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    # Clears localhost previously saved results... these results appear automatically when viewing saved .evtx logs
                    Get-ChildItem -Path "$env:ProgramData\Microsoft\Event Viewer\ExternalLogs" | Remove-Item -Force

                    eventvwr -l:"`$script:EVTXLogfILE$JobId"
                }
            }
"@
        }
        elseif ($SendFileSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:SendFilePath$JobId = "$SendFilePath"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Check Endpoint'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    Invoke-Command -ScriptBlock {
                        param(`$path)
                        Get-ChildItem `$path
                    } -ArgumentList @(`$script:SendFilePath$JobId, `$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential | Select-Object PSComputerName, Name, Length, CreationTime, LastAccessTime, LastWriteTime, Directory, Attributes, FullName | Out-GridView -Title "`$(`$script:ComputerName$JobId -split ' '):  Send Files Check"

                    if (`$script:RollCredentialsState -and `$script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
            }
"@
        }
        elseif ($SysmonSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:SysmonName$JobId = "$SysmonName"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Check Sysmon'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    Invoke-Command -ScriptBlock {
                        param(`$name)
                        Get-Process -Name `$name
                    } -ArgumentList @(`$script:SysmonName$JobId, `$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential | Select-Object PSComputerName, Name, Id, PriorityClass, FileVersion, WorkingSet, StartTime, CPU, Company, Path, Modules, Threads, Handles | Out-GridView -Title "`$(`$script:ComputerName$JobId -split ' '):  Check for Sysmon Running"

                    if (`$script:RollCredentialsState -and `$script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
            }
"@
        }
        elseif ($ProcmonSwitch) {
            Invoke-Expression @"
            `$script:ProcmonLocalPath$JobId = "$ProcmonLocalPath"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open Procmon'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
                    `$ProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                        Title            = "Open Procmon file"
                        InitialDirectory = "`$script:ProcmonLocalPath$JobId"
                        filter           = "Results (*.pml)|*.pml|Procmon (*.pml)|*.pml|All files (*.*)|*.*"
                        ShowHelp = `$true
                    }
                    `$ProcmonOpenFileDialog.ShowDialog()
                    Invoke-Item `$ProcmonOpenFileDialog.filename
                }
            }
"@
        }
        elseif ($ExecutableAndScriptSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:ExecutableAndScriptPath$JobId = "$ExecutableAndScriptPath"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Check Files'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Command -ScriptBlock { param(`$script:ExecutableAndScriptPath$JobId); Get-ChildItem -Path "`$script:ExecutableAndScriptPath$JobId" } -ArgumentList @(`$script:ExecutableAndScriptPath$JobId,`$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential | Select-Object -Property PSComputerName, Name, Length, PSIsContainer, Mode, Directoryname, CreationTime, LastAccessTime, LastWriteTime, Attributes, FullName, VersionInfo | Out-GridView -Title "Check Files"
                }
            }
"@
        }
        elseif ($PSWriteHTMLSwitch) {
            Invoke-Expression @"
            `$script:ProcmonLocalPath$JobId = "$ProcmonLocalPath"

            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open In Browser'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    if (`$script:PSWriteHTMLResults$JobId) {
                        if (`$script:PSWriteHTML$JobId -eq 'EndpointDataSystemSnapshot') {
                            script:Individual-PSWriteHTML -Title 'Endpoint Snapshot' -Data {
                                script:Invoke-PSWriteHTMLEndpointSnapshot -InputData `$script:PSWriteHTMLResults$JobId -CheckedItems `$script:PSWriteHTMLOptions$JobId -MenuPrompt
                            } -FilePath `$script:PSWriteHTMLFilePath$JobId
                        }
                        elseif (`$script:PSWriteHTML$JobId -eq 'EndpointDataNetworkConnections') {
                            script:Individual-PSWriteHTML -Title 'Network Connections' -Data {
                                script:Invoke-PSWriteHTMLNetworkConnections -InputData `$script:PSWriteHTMLResults$JobId -MenuPrompt
                            } -FilePath `$script:PSWriteHTMLFilePath$JobId
                        }
                        Invoke-Item `$script:PSWriteHTMLFilePath$JobId
                    }
                    elseif ((Test-Path "`$script:PSWriteHTMLFilePath$JobId")) {
                        Invoke-Item `$script:PSWriteHTMLFilePath$JobId
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("There is currently on data available.",'PoSh-EasyWin - Console')
                    }
                    [System.GC]::Collect()
                }
            }
"@
        }
        elseif ("$JobsExportFiles" -eq "false" -and "$FileExtension" -like 'txt') {
            Invoke-Expression @"
            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open Folder'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\*")) {
                        Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\"
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("There are no results avaiable.",'PoSh-EasyWin')
                    }
                }
            }
"@
        }
        else {
            Invoke-Expression @"
            `$script:MonitorJobsButtonOne$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'GridView'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 1)
                Width     = `$FormScale * 60
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension")) {
                        `$script:JobCSVResults$JobId = $ImportDataCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension"
                        if ("$FileExtension" -like 'txt') {
                            [System.Windows.Forms.MessageBox]::Show("It is recommended to use the Text button to view flat text results. The following results have been parsed from flat text into a csv format.`n`nText with two or more spaces between them normally indicate separate fields. That said, linux systems are not very consistent with their CLI output. Results returned sometimes don't have headers or some fields are separated by as little as a single space which result in frequent formatting issues.`n`nThis section should only be used for reference and is useful for column searching/filtering, but should be verified against accompanied flat text results.","PoSh-EasyWin - `$(`$script:JobName$JobId)")
                            Import-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        elseif ("$FileExtension" -like 'xml') {
                            `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                            (`$script:PSWriteHTMLResults$JobId | Out-GridView -Title "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId))" -PassThru).Value | Out-GridView -Title "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        else {
                            if (`$script:JobCSVResults$JobId) {
                                `$script:JobCSVResults$JobId  | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                            }
                            else {
                                [System.Windows.Forms.MessageBox]::Show("There are no results avaiable.",'PoSh-EasyWin - View Progress')
                            }
                        }
                    }
                    else {
                        `$script:CurrentJobsWithComputerName$JobId = @()
                        foreach (`$Job in `$script:CurrentJobs$JobId) {
                            `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                        }
                        if (`$script:CurrentJobsWithComputerName$JobId.count -ge 1) {
                            `$script:CurrentJobsWithComputerName$JobId | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        else {
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                        }
                    }
                    Remove-Variable -Name JobCSVResults$JobId -Scope script
                    Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                    [System.GC]::Collect()
                }
            }
"@
        }



        ##############
        #  Button 2  #
        ##############
        if ($EVTXSwitch) {
            Invoke-Expression @"
            `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                Left   = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                Top    = `$script:MonitorJobsButtonOne$JobId.Top
                Width  = `$FormScale * 60
                Height = `$FormScale * 21
            }
"@
        }
        elseif ($SmithFlag -eq 'RetrieveFile') {
            Invoke-Expression @"
            `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text      = "Get File"
                Left      = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top
                Width     = `$FormScale * 60
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    # Checks to see if there are any results
                    `$script:CurrentJobsWithComputerName$JobId = @()
                    foreach (`$Job in `$script:CurrentJobs$JobId) {
                        `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                    }
                    if ( `$script:CurrentJobsWithComputerName$JobId.count -ge 1 ) {
                        `$script:SelectedFilesToDownload$JobId = `$script:CurrentJobsWithComputerName$JobId | Select-Object ComputerName, Name, FullName, CreationTime, LastAccessTime, LastWriteTime, Length, Attributes, VersionInfo, * -ErrorAction SilentlyContinue | Out-GridView -Title 'Get Files' -PassThru
                        Get-RemoteFile -Files `$script:SelectedFilesToDownload$JobId
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                    }
                    Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                    Remove-Variable -Name SelectedFilesToDownload$JobId -Scope script
                    [System.GC]::Collect()
                }
            }
"@
        }
        elseif ($SmithFlag -eq 'RetrieveADS') {
            Invoke-Expression @"
            `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text      = 'Get ADS'
                Left      = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top
                Width     = `$FormScale * 60
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    # Checks to see if there are any results
                    `$script:CurrentJobsWithComputerName$JobId = @()
                    foreach (`$Job in `$script:CurrentJobs$JobId) {
                        `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                    }
                    if ( `$script:CurrentJobsWithComputerName$JobId.count -ge 1 ) {
                        `$script:SelectedFilesToDownload$JobId = `$script:CurrentJobsWithComputerName$JobId | Select-Object ComputerName, Name, FullName, CreationTime, LastAccessTime, LastWriteTime, Length, Attributes, VersionInfo, * -ErrorAction SilentlyContinue | Out-GridView -Title 'Get Alternate Data Stream' -PassThru
                        Get-RemoteAlternateDataStream -Files `$script:SelectedFilesToDownload$JobId
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                    }
                    Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                    Remove-Variable -Name SelectedFilesToDownload$JobId -Scope script
                    [System.GC]::Collect()
                }
            }
"@
        }
        elseif ($PSWriteHTMLSwitch) {
                Invoke-Expression @"
                `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                    Left   = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                    Top    = `$script:MonitorJobsButtonOne$JobId.Top
                    Width  = `$FormScale * 60
                    Height = `$FormScale * 21
                    Font   = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                }
"@
        }
        elseif ($SMITH) {
            if ("$JobsExportFiles" -eq "true" -or ("$JobsExportFiles" -eq "false" -and "$FileExtension" -like 'csv')) {
                Invoke-Expression @"

                if ("$FileExtension" -like 'txt') {
                    `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                        Text   = 'Text'
                        Left   = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                        Top    = `$script:MonitorJobsButtonOne$JobId.Top
                        Width  = `$FormScale * 60
                        Height = `$FormScale * 21
                        Font   = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                        Add_click = {
                            if (`$This.BackColor -ne 'LightGray') {
                                `$This.BackColor = 'LightGray'
                            }
                            if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).txt")) {
                                notepad.exe "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).txt"
                            }
                            else {
                                [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                            }
                            Remove-Variable -Name JobCSVResults$JobId -Scope script
                            Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                            [System.GC]::Collect()
                        }
                    }
                }
                elseif ((Test-Path -Path "`$Dependencies\Modules\PSWriteHTML") -and (Get-Content "`$PewSettings\PSWriteHTML Module Install.txt") -match 'Yes') {
                    `$script:MonitorJobsButtonTwo$JobId = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "HTML"
                        Left   = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
                        Top    = `$script:MonitorJobsButtonOne$JobId.Top
                        Width  = `$FormScale * 60
                        Height = `$FormScale * 21
                        Font   = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                        Add_click = {
                            if (`$This.BackColor -ne 'LightGray') {
                                `$This.BackColor = 'LightGray'
                            }
                            if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension")) {
                                `$script:JobCSVResults$JobId = $ImportDataCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension"
                                if (`$script:JobCSVResults$JobId) {
                                    `$script:JobCSVResults$JobId  | Out-HTMLView -Title "`$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                                }
                                else {
                                    [System.Windows.Forms.MessageBox]::Show("There are no results avaiable.",'PoSh-EasyWin - View Progress')
                                }
                            }
                            else {
                                `$script:CurrentJobsWithComputerName$JobId = @()
                                foreach (`$Job in `$script:CurrentJobs$JobId) {
                                    `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                                }
                                if (`$script:CurrentJobsWithComputerName$JobId.count -ge 1) {
                                    `$script:CurrentJobsWithComputerName$JobId | Out-HTMLView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                                }
                                else {
                                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                                }
                            }
                            Remove-Variable -Name JobCSVResults$JobId -Scope script
                            Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                            [System.GC]::Collect()
                        }
                    }
                }


                # `$script:MonitorJobsButtonStatus$JobId.Left      = `$script:MonitorJobsButtonTwo$JobId.Left + `$script:MonitorJobsButtonTwo$JobId.Width + (`$FormScale * 5)
                # `$script:MonitorJobsButtonDetails$JobId.Left      = `$script:MonitorJobsButtonStatus$JobId.Left
                # `$script:MonitorJobsButtonRemove$JobId.Left       = `$script:MonitorJobsButtonStatus$JobId.Left + `$script:MonitorJobsButtonStatus$JobId.Width + (`$FormScale * 5)
                # `$script:Section3MonitorJobOptionsButton$JobId.Left      = `$script:MonitorJobsButtonRemove$JobId.Left
                # `$script:Section3MonitorJobKeepDataCheckbox$JobId.Left   = `$script:MonitorJobsButtonRemove$JobId.Left + `$script:MonitorJobsButtonRemove$JobId.Width + (`$FormScale * 5)
                # `$script:MonitorJobsButtonMonitor$JobId.Left = `$script:Section3MonitorJobKeepDataCheckbox$JobId.Left
                # `$script:Section3MonitorJobNotifyCheckbox$JobId.Left     = `$script:Section3MonitorJobKeepDataCheckbox$JobId.Left
"@
            }
        }


        ##############
        #  Button 3  #
        ##############
        if ($PcapSwitch) {
            Invoke-Expression @"
            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open Folder'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\"
                }
            }
"@
        }
        elseif ($EVTXSwitch) {
            Invoke-Expression @"
            `$script:SaveLocation$JobId = Split-Path "$EVTXLocalSavePath" -Parent
            `$EVTXLogfILE$JobId = "$EVTXLocalSavePath"

            `$script:EVTXChainSawCommand$JobId = @"
Start-Process 'PowerShell' -ArgumentList '-NoProfile',
'-ExecutionPolicy ByPass',
{ Set-Location '"`$script:SaveLocation$JobId"' | Out-Null; },
{ "& '$Dependencies\Executables\chainsaw\chainsaw.exe' hunt '`$EVTXLogfILE$JobId' --rules '$Dependencies\Executables\chainsaw\sigma_rules\' --mapping '$Dependencies\Executables\chainsaw\mapping_files\sigma-mapping.yml' --full --lateral-all --csv"; },
{ Foreach ( ```$EvtxFile in ```$(Get-ChildItem '"`$script:SaveLocation$JobId\chainsaw_*"' -Recurse | Where-Object {```$_.Name -like '*.csv'}) ) { ```$FullName = iex '```$EvtxFile.FullName'; ```$BaseName = iex '```$EvtxFile.BaseName'; ```$BaseName = 'ChainSaw by F-Secure Countercept:  ' + '"'+ ```$BaseName + '"'; Import-Csv "```$FullName" | Out-GridView -Title ```$BaseName -Wait }; }
`"@
# #'-NoExit',
# #{ `$ErrorActionPreference = 'SilentlyContinue'; },
# #{ Write-Host "Passing information from PoSh-EasyWin to ChainSaw"; },
# #{ Write-Host ".\chainsaw.exe' hunt '`$EVTXLogfILE$JobId' --rules '.\sigma_rules\' --mapping '.\mapping_files\sigma-mapping.yml' --full --lateral-all --csv"; },
# #{ Write-Host ""; },


            `$script:EndpointName$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-2]
            `$script:JobData$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-1]

            `$script:MonitorJobsLabelTransparentStatus$JobId.text = "Endpoint Count:  0 / `$script:JobsStartedCount$JobId `n`$(`$script:EndpointName$JobId):  `$script:JobName$JobId"

            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'ChainSaw'
                Left     = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 60
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    # if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng")) {
                    #     Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng"
                    # }
                    # else {
                    #     [System.Windows.Forms.MessageBox]::Show("There is no pcap data available.",'PoSh-EasyWin')
                    # }

                    Invoke-Expression "`$script:EVTXChainSawCommand$JobId"
                }
            }
"@
        }
        elseif ($SendFileSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:SendFilePath$JobId = "$SendFilePath"

            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Remove Files'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    `$script:SelectedFilesToRemove$JobId = Invoke-Command -ScriptBlock {
                        param(`$path)
                        Get-ChildItem `$path
                    } -ArgumentList @(`$script:SendFilePath$JobId, `$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential | Select-Object PSComputerName, Name, Length, CreationTime, LastAccessTime, LastWriteTime, Directory, Attributes, FullName | Out-GridView -Title "`$(`$script:ComputerName$JobId -split ' '):  Select Files to Remove" -PassThru

                    `$script:SelectedFilesToRemove$JobId = Invoke-Command -ScriptBlock {
                        param(`$ToRemove)
                        Remove-Item `$ToRemove.FullName -Force
                    } -ArgumentList @(`$script:SelectedFilesToRemove$JobId, `$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential

                    if (`$script:RollCredentialsState -and `$script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
            }
"@
        }
        elseif ($SysmonSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:SysmonName$JobId = "$SysmonName"

            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Remove Sysmon'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    `$script:SelectedEndpointsToRemoveSysmon$JobId = Invoke-Command -ScriptBlock {
                        param(`$name)
                        Get-Process -Name `$name
                    } -ArgumentList @(`$script:SysmonName$JobId, `$null) -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential | Select-Object PSComputerName, Name, Id, PriorityClass, FileVersion, WorkingSet, StartTime, CPU, Company, Path, Modules, Threads, Handles | Out-GridView -Title "Endpoint Count: `$((`$script:ComputerName$JobId -split ' ').Count) - Select to Remove Sysmon" -PassThru

                    `$script:SelectedEndpointsToRemoveSysmonFrom = `$null
                    `$script:SelectedEndpointsToRemoveSysmonFrom = `$((`$script:SelectedEndpointsToRemoveSysmon$JobId).PSComputerName -split ' ')

                    if (`$script:SelectedEndpointsToRemoveSysmonFrom) {
                        Invoke-Command -ScriptBlock {
                            param(`$name)
                            & "`$name" -u
                        } -ArgumentList @(`$script:SysmonName$JobId, `$null) -ComputerName `$(`$script:SelectedEndpointsToRemoveSysmonFrom -split ' ') -Credential `$script:Credential
                    }

                    if (`$script:RollCredentialsState -and `$script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
            }
"@
        }
        elseif ($ProcmonSwitch) {
            Invoke-Expression @"
            `$script:ProcmonLocalPath$JobId = "$ProcmonLocalPath"

            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open Folder'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$script:ProcmonLocalPath$JobId"
                }
            }
"@
        }
        elseif ($ExecutableAndScriptSwitch) {
            Invoke-Expression @"
            `$script:ComputerName$JobId = "$ComputerName"
            `$script:ExecutableAndScriptPath$JobId = "$ExecutableAndScriptPath"
            `$script:PSSession$JobId   = `$False
            `$script:RemoveFiles$JobId = `$false

            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Remove Files'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 125
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    `$script:PSSession$JobId = New-PSSession -ComputerName `$(`$script:ComputerName$JobId -split ' ') -Credential `$script:Credential
                    `$script:RemoveFiles$JobId = Invoke-Command -ScriptBlock { param(`$script:ExecutableAndScriptPath$JobId); Get-ChildItem -Path "`$script:ExecutableAndScriptPath$JobId" } -ArgumentList @(`$script:ExecutableAndScriptPath$JobId,`$null) -Session `$script:PSSession$JobId | Select-Object -Property PSComputerName, Name, Length, PSIsContainer, Mode, Directoryname, CreationTime, LastAccessTime, LastWriteTime, Attributes, FullName, VersionInfo | Out-GridView -Title "Remove Files - Note: The Selected Directories and/or Files are removed from all listed endpoints, not just the highlighted." -PassThru
                    `$script:RemoveFiles$JobId  = `$script:RemoveFiles$JobId | Select-Object -ExpandProperty FullName
                    Invoke-Command -ScriptBlock { param(`$RemoveFiles); Remove-Item -Path `$RemoveFiles -Recurse -Force } -ArgumentList @(`$script:RemoveFiles$JobId,`$null) -Session `$script:PSSession$JobId
                    `$script:PSSession$JobId | Remove-PSSession
                }
            }
"@
        }
        elseif ($PSWriteHTMLSwitch) {
            Invoke-Expression @"
            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'GridView'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width     = `$FormScale * 60
                Height    = `$FormScale * 21
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }

                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension")) {
                        `$script:JobCSVResults$JobId = $ImportDataCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension"
                        if ("$FileExtension" -like 'txt') {
                            [System.Windows.Forms.MessageBox]::Show("It is recommended to use the Text button to view flat text results. The following results have been parsed from flat text into a csv format.`n`nText with two or more spaces between them normally indicate separate fields. That said, linux systems are not very consistent with their CLI output. Results returned sometimes don't have headers or some fields are separated by as little as a single space which result in frequent formatting issues.`n`nThis section should only be used for reference and is useful for column searching/filtering, but should be verified against accompanied flat text results.","PoSh-EasyWin - `$(`$script:JobName$JobId)")
                            Import-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        elseif ("$FileExtension" -like 'xml') {
                            `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                            (`$script:PSWriteHTMLResults$JobId | Out-GridView -Title "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId))" -PassThru).Value | Out-GridView -Title "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        else {
                            if (`$script:JobCSVResults$JobId) {
                                `$script:JobCSVResults$JobId  | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                            }
                            else {
                                [System.Windows.Forms.MessageBox]::Show("There are no results avaiable.",'PoSh-EasyWin - View Progress')
                            }
                        }
                    }
                    else {
                        `$script:CurrentJobsWithComputerName$JobId = @()
                        foreach (`$Job in `$script:CurrentJobs$JobId) {
                            `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                        }
                        if (`$script:CurrentJobsWithComputerName$JobId.count -ge 1) {
                            `$script:CurrentJobsWithComputerName$JobId | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                        }
                        else {
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are currently no results available.",'PoSh-EasyWin - View Progress')
                        }
                    }
                    Remove-Variable -Name JobCSVResults$JobId -Scope script
                    Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                    [System.GC]::Collect()
                }
            }
"@
        }
        else {
            Invoke-Expression @"
            `$script:MonitorJobsButtonThree$JobId = New-Object System.Windows.Forms.Button -Property @{
                text     = "Shell"
                Left     = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml")) {
                        `$script:JobXMLResults$JobId = Import-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -ErrorAction SilentlyContinue

                        if (`$script:JobXMLResults$JobId ) {
                            script:Open-XmlResultsInShell -ViewImportResults "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -FileName "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -SavePath `$script:CollectionSavedDirectoryTextBox.Text
                        }
                        else {
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nThere are no results available.",'PoSh-EasyWin - Console')
                        }
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("There is no XML data available.",'PoSh-EasyWin - Console')
                    }
                    Remove-Variable -Name JobXMLResults$JobId -Scope script
                    [System.GC]::Collect()
                }
            }
            if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$false) {
                `$script:MonitorJobsButtonThree$JobId.Text = 'Shell'
            }
"@
        }


        ##############
        #  Button 4  #
        ##############


        if ($EVTXSwitch) {
            Invoke-Expression @"
            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text     = 'Folder'
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_Click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\"
                }
            }
"@
        }
        elseif ($PSWriteHTMLSwitch) {
            Invoke-Expression @"
            `$script:FolderPath$JobId = "`$(`$script:CollectionSavedDirectoryTextBox.Text)"

            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text     = 'Folder'
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_Click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$script:FolderPath$JobId"
                }
            }
"@
        }
        elseif ($SmithFlag -eq 'RetrieveFile') {
            Invoke-Expression @"
            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text     = 'Folder'
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_Click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)"
                }
            }
"@
        }
        elseif ($SmithFlag -eq 'RetrieveADS') {
            Invoke-Expression @"
            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text     = 'Folder'
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_Click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)"
                }
            }
"@
        }
        elseif ($SMITH) {
            Invoke-Expression @"
            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_Click = {
                    if (`$This.BackColor -ne 'LightGray') {
                        `$This.BackColor = 'LightGray'
                    }
                }
            }
            if ("$JobsExportFiles" -eq "true" -and "$FileExtension" -like 'txt') {
                `$script:MonitorJobsButtonFour$JobId.text = 'Folder'
                `$script:MonitorJobsButtonFour$JobId.Add_click({
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\"
                })
            }
            else {
                `$script:MonitorJobsButtonFour$JobId.text = 'Charts'
                `$script:MonitorJobsButtonFour$JobId.Add_click({
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension")) {
                        `$AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left


                        `$script:AutoChartsForm = New-Object Windows.Forms.Form -Property @{
                            Left   = `$FormScale * 5
                            Top    = `$FormScale * 5
                            Width  = `$PoShEasyWin.Size.Width   #1241
                            Height = `$PoShEasyWin.Size.Height  #638
                            Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                            Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                            StartPosition = "CenterScreen"
                            Add_Closing   = { `$This.dispose() }
                        }
                            `$AutoChartsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                                Text   = 'Auto Charts'
                                Left   = `$FormScale * 5
                                Top    = `$FormScale * 5
                                Width  = `$PoShEasyWin.Size.Width - `$(`$FormScale * 25)
                                Height = `$PoShEasyWin.Size.Height - `$(`$FormScale * 50)
                                Appearance = [System.Windows.Forms.TabAppearance]::Buttons
                                Hottrack = `$true
                                Font     = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),1,2,1)
                            }
                            `$AutoChartsTabControl.Anchor = `$AnchorAll
                            `$AutoChartsTabControl.Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                            `$script:AutoChartsForm.Controls.Add(`$AutoChartsTabControl)


                            `$script:AutoChartsIndividualTab01 = New-Object System.Windows.Forms.TabPage -Property @{
                                Width      = `$FormScale * 1700
                                Height     = `$FormScale * 1050
                                #Anchor    = `$AnchorAll
                                Font       = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                                AutoScroll = `$True
                                UseVisualStyleBackColor = `$True
                            }
                            `$AutoChartsTabControl.Controls.Add(`$script:AutoChartsIndividualTab01)


                            `$script:AutoChartDataSourceCsv$JobId = Import-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -ErrorAction SilentlyContinue
                            `$script:AutoChartXmlPath$JobId = "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"

                            if ( `$script:AutoChartDataSourceCsv$JobId ) {
                                `$ChartProperties = `$script:AutoChartDataSourceCsv$JobId[0] | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name'
                                #`$ChartProperties = `$ChartProperties | Where-Object { `$_ -ne '' -and `$_ -ne `$null -and `$_ -notlike "__*" -and `$_ -notmatch 'ComputerName' -and `$_ -notmatch 'RunSpaceID' } | Out-GridView -Title 'Select Properties to Generate Charts' -PassThru | Sort-Object

                                `$ChartProperties = `$ChartProperties | Where-Object { `$_ -ne '' -and `$_ -ne `$null -and `$_ -notlike "__*" -and `$_ -notmatch 'ComputerName' -and `$_ -notmatch 'RunSpaceID' } | Sort-Object

                                    `$ChartGenerationOptionsForm = New-Object System.Windows.Forms.Form -Property @{
                                        Text   = "PoSh-EasyWin - Create Charts"
                                        Width  = `$FormScale * 400
                                        Height = `$FormScale * 500
                                        StartPosition = "CenterScreen"
                                        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                                        Font          = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                                        AutoScroll    = `$True
                                        #FormBorderStyle =  "fixed3d"
                                        #ControlBox    = `$false
                                        MaximizeBox   = `$false
                                        MinimizeBox   = `$false
                                        ShowIcon      = `$true
                                        TopMost       = `$true
                                        Add_Closing = { `$This.dispose() }
                                    }

                                    `$ChartGenerationPropertyList0PictureBox = New-Object Windows.Forms.PictureBox -Property @{
                                        Text   = "PowerShell Charts"
                                        Left   = `$FormScale * 10
                                        Top    = `$FormScale * 10
                                        Width  = `$FormScale * 355
                                        Height = `$FormScale * 44
                                        Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PowerShell_Charts.png")
                                        SizeMode = 'StretchImage'
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$ChartGenerationPropertyList0PictureBox)


                                    `$ChartGenerationPropertyList0Label = New-Object System.Windows.Forms.Label -Property @{
                                        Text   = "Select among the following list boxes to generate charts. Use the Shift and Ctrl keys to select multiple properties."
                                        Left   = `$FormScale * 10
                                        Top    = `$ChartGenerationPropertyList0PictureBox.Top + `$ChartGenerationPropertyList0PictureBox.Height + (`$FormScale * 5)
                                        Width  = `$FormScale * 355
                                        Height = `$FormScale * 44
                                        Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),1,2,1)
                                        ForeColor = 'Blue'
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$ChartGenerationPropertyList0Label)


                                    `$ChartGenerationPropertyList1Label = New-Object System.Windows.Forms.Label -Property @{
                                        Text   = "Counts the unique values found across all endpoints`n`nDefault Chart: Bar"
                                        Left   = `$FormScale * 10
                                        Top    = `$ChartGenerationPropertyList0Label.Top + `$ChartGenerationPropertyList0Label.Height + (`$FormScale * 5)
                                        Width  = `$FormScale * 355 #200
                                        Height = `$FormScale * 50
                                        Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),1,2,1)
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$ChartGenerationPropertyList1Label)

                                    `$GenerateChartsExeuction$JobId = {
                                        `$ScriptBlockProgressBar1Input$JobId = {
                                            `$ChartProperties1Selected = @()
                                            foreach (`$Selected in `$script:ChartGenerationPropertyList1ListBox.SelectedItems) {
                                                `$ChartProperties1Selected += `$Selected
                                            }

                                            `$script:ProgressBarFormProgressBar.Value   = 0
                                            `$script:ProgressBarFormProgressBar.Maximum = `$ChartProperties1Selected.count

                                            `$script:ProgressBarMessageLabel.text = "`Please be patience as the data loads.`nTotal charts to be created:  `$(`$ChartProperties1Selected.count)"
                                            `$script:ProgressBarSelectionForm.Refresh()


                                            `$count = 0
                                            foreach ( `$Property in `$ChartProperties1Selected ) {
                                                `$count += 1
                                                if (`$Count -le 50) {
                                                    Update-FormProgress `$Property
                                                    script:New-PowerShellChart -ChartType 'Column' -SourceCSVData `$script:AutoChartDataSourceCsv$JobId -SourceXMLPath `$script:AutoChartXmlPath$JobId -ChartNumber `$count -SeriesName `$Property -TitleAxisX `$Property -TitleAxisY 'Endpoint Count' -PropertyX `$Property -PropertyY 'ComputerName'
                                                    `$script:ProgressBarFormProgressBar.Value += 1
                                                    `$script:ProgressBarFormProgressBar.Refresh()
                                                }
                                            }
                                            `$script:ProgressBarFormProgressBar.Maximum = 1
                                            `$script:ProgressBarFormProgressBar.Value   = 1
                                            `$script:AutoChartsIndividualTab01.Text = `$script:JobName$JobId
                                            `$script:ProgressBarSelectionForm.Hide()
                                        }

                                        if (`$(`$script:ChartGenerationPropertyList1ListBox.SelectedItems.Count) -gt 6) {
                                            if (Verify-Action -Title "Generate Charts [`$(`$script:ChartGenerationPropertyList1ListBox.SelectedItems.Count)/`$(`$script:ChartGenerationPropertyList1ListBox.Items.Count)]" -Question "There are a total of `$(`$script:ChartGenerationPropertyList1ListBox.SelectedItems.Count)/`$(`$script:ChartGenerationPropertyList1ListBox.Items.Count) properties selected to generate charts from. This feature is limited to generating charts from the first 50.`n`nIt is highly NOT recommended to generate numerous charts at the same time, as this can cause the GUI to lock up or the tool to crash as charts are being generated.`n`nDo you want to generate charts?") {
                                                `$ChartGenerationOptionsForm.Hide()

                                                # Generates Column Charts
                                                Show-ProgressBar -FormTitle "Generating Charts [Column] Unique Values Found" -ProgressBarImage "$Dependencies\Images\PowerShell_Charts.png" -ShowImage -ScriptBlockProgressBarInput `$ScriptBlockProgressBar1Input$JobId

                                                `$script:AutoChartsForm.ShowDialog()
                                            }
                                        }
                                        else {
                                            `$ChartGenerationOptionsForm.Hide()

                                            # Generates Column Charts
                                            Show-ProgressBar -FormTitle "Generating Charts [Column] Unique Values Found" -ProgressBarImage "$Dependencies\Images\PowerShell_Charts.png" -ShowImage -ScriptBlockProgressBarInput `$ScriptBlockProgressBar1Input$JobId

                                            `$script:AutoChartsForm.ShowDialog()
                                        }
                                    }

                                    `$script:ChartGenerationPropertyList1ListBox = New-Object System.Windows.Forms.ListBox -Property @{
                                        Name   = "ResultsListBox"
                                        Left   = `$FormScale * 10
                                        Top    = `$ChartGenerationPropertyList1Label.Top + `$ChartGenerationPropertyList1Label.Height + (`$FormScale * 5)
                                        Width  = `$FormScale * 355 #200
                                        Height = `$FormScale * 200
                                        FormattingEnabled   = `$True
                                        SelectionMode       = 'MultiExtended'
                                        ScrollAlwaysVisible = `$True
                                        AutoSize            = `$False
                                        Font                = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                                        Add_KeyDown         = { if (`$_.KeyCode -eq "Enter") { & `$GenerateChartsExeuction$JobId } }
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$script:ChartGenerationPropertyList1ListBox)


                                    `$ChartGenerationPropertyList1Button = New-Object System.Windows.Forms.Button -Property @{
                                        Text   = "Select All"
                                        Left   = `$FormScale * 10
                                        Top    = `$script:ChartGenerationPropertyList1ListBox.Top + `$script:ChartGenerationPropertyList1ListBox.Height + (`$FormScale * 5)
                                        Width  = `$script:ChartGenerationPropertyList1ListBox.Width
                                        Height = `$FormScale * 22
                                        Add_KeyDown = { if (`$_.KeyCode -eq "Enter") { & `$GenerateChartsExeuction$JobId } }
                                        Add_Click   = { for(`$i = 0; `$i -lt `$script:ChartGenerationPropertyList1ListBox.Items.Count; `$i++) { `$script:ChartGenerationPropertyList1ListBox.SetSelected(`$i, `$true) } }
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$ChartGenerationPropertyList1Button)
                                    Add-CommonButtonSettings -Button `$ChartGenerationPropertyList1Button

                                    foreach ( `$Property in `$ChartProperties ) { `$script:ChartGenerationPropertyList1ListBox.Items.Add(`$Property) }


                                    `$ChartGenerationPropertyList3Button = New-Object System.Windows.Forms.Button -Property @{
                                        Text   = "Generate Charts"
                                        Left   = `$ChartGenerationPropertyList0Label.Left
                                        Top    = `$ChartGenerationPropertyList1Button.Top + `$ChartGenerationPropertyList1Button.Height + (`$FormScale * 5)
                                        Width  = `$ChartGenerationPropertyList0Label.Width
                                        Height = `$FormScale * 44
                                        Add_KeyDown = { if (`$_.KeyCode -eq "Enter") { & `$GenerateChartsExeuction$JobId } }
                                        Add_Click   = `$GenerateChartsExeuction$JobId
                                    }
                                    `$ChartGenerationOptionsForm.Controls.Add(`$ChartGenerationPropertyList3Button)
                                    Add-CommonButtonSettings -Button `$ChartGenerationPropertyList3Button

                                    `$ChartGenerationOptionsForm.ShowDialog()
                            }
                        `$script:AutoChartsForm.Add_Shown({`$script:AutoChartsForm.Activate()})
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("There is no CSV data available.",'PoSh-EasyWin - Console')
                    }
                    Remove-Variable -Name JobXMLResults$JobId -Scope script
                    [System.GC]::Collect()
                })
            }
"@
        }
        else {
            Invoke-Expression @"
            `$script:MonitorJobsButtonFour$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text     = `$null
                Left     = `$script:MonitorJobsButtonThree$JobId.Left + `$script:MonitorJobsButtonThree$JobId.Width + (`$FormScale * 5)
                Top      = `$script:MonitorJobsButtonOne$JobId.Top + `$script:MonitorJobsButtonOne$JobId.Height + (`$FormScale * 5)
                Width    = `$FormScale * 60
                Height   = `$FormScale * 21
            }
"@
        }



        ############
        #  Status  #
        ############


        Invoke-Expression @"
        `$script:MonitorJobsButtonStatus$JobId = New-Object System.Windows.Forms.Button -Property @{
            text      = "Status"
            Left      = `$script:MonitorJobsButtonTwo$JobId.Left + `$script:MonitorJobsButtonTwo$JobId.Width + (`$FormScale * 5)
            Top       = `$script:MonitorJobsButtonTwo$JobId.Top
            Width     = `$FormScale * 75
            Height    = `$FormScale * 21
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 6),0,0,0)
        }
        if (`$script:MonitorJobsButtonOne$JobId.Width -ne (`$FormScale * 60)) {
            `$script:MonitorJobsButtonStatus$JobId.Left = `$script:MonitorJobsButtonOne$JobId.Left + `$script:MonitorJobsButtonOne$JobId.Width + (`$FormScale * 5)
            `$script:MonitorJobsButtonStatus$JobId.Top = `$script:MonitorJobsButtonOne$JobId.Top
        }


        if ("$JobsExportFiles" -eq "false") {
            `$script:MonitorJobsButtonStatus$JobId.add_click({[System.Windows.Forms.MessageBox]::Show("The selected query does not support providing Status Information.","PoSh-EasyWin",'Ok',"Info")})
        }
        if ("$JobsExportFiles" -eq "true") {
            `$script:MonitorJobsButtonStatus$JobId.Add_click({
                                `$script:MonitorJobsDetailsFrom$JobId = New-Object Windows.Forms.Form -Property @{
                                    Text          = "Monitor Jobs Details - `$(`$script:JobName$JobId)"
                                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                                    Width         = `$FormScale * 670
                                    Height        = `$FormScale * 600
                                    StartPosition = "CenterScreen"
                                    Font          = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                                    Add_Closing = {
                                        Remove-Variable MonitorJobsDetailsFrom$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsRunningGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsCompletedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsStoppedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsFailedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsStatusGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStatusRichTextBox$JobId -scope script

                                        `$This.dispose()
                                    }
                                }


                                    `$script:MonitorJobsDetailsRunningGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Running"
                                        left      = `$FormScale * 10
                                        top       = `$FormScale * 10
                                        Width     = `$FormScale * 150
                                        Height    = `$FormScale * 402
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Blue"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningGroupBox$JobId)

                                        `$script:MonitorJobsDetailsRunningListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 300
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            FormattingEnabled   = `$True
                                            SelectionMode       = 'MultiExtended'
                                            ScrollAlwaysVisible = `$True
                                            AutoSize            = `$false
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningListBox$JobId)


                                        `$script:MonitorJobsDetailsRunningSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = 'Select All'
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsRunningListBox$JobId.Top + `$script:MonitorJobsDetailsRunningListBox$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 22
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsRunningListBox$JobId.Items.Count; `$i++) {
                                                    `$script:MonitorJobsDetailsRunningListBox$JobId.SetSelected(`$i, `$true)
                                                }
                                            }
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningSelectAllButton$JobId)
                                        Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsRunningSelectAllButton$JobId


                                        `$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = "Computer TreeView:`nCheckbox The Above`nSelected Endpoints"
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsRunningSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsRunningSelectAllButton$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 44
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                [System.Windows.Forms.TreeNodeCollection]`$AllTreeViewNodes = `$script:ComputerTreeView.Nodes
                                                foreach (`$root in `$AllTreeViewNodes) {
                                                    `$root.Checked = `$false
                                                    foreach (`$Category in `$root.Nodes) {
                                                        `$Category.Checked = `$false
                                                        foreach (`$Entry in `$Category.nodes) {
                                                            `$Entry.Checked = `$false
                                                        }
                                                    }
                                                }

                                                foreach (`$Selected in `$script:MonitorJobsDetailsRunningListBox$JobId.SelectedItems) {
                                                    foreach (`$root in `$AllTreeViewNodes) {
                                                        foreach (`$Category in `$root.Nodes) {
                                                            foreach (`$Entry in `$Category.nodes) {
                                                                if (`$Entry.Text -eq `$Selected){
                                                                    `$Entry.Checked = `$true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                Update-TreeViewData -Endpoint -TreeView `$script:ComputerTreeView.Nodes
                                            }
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId)
                                        Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId


                                        `$script:MonitorJobsDetailsCompletedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                            text      = "Completed"
                                            left      = `$script:MonitorJobsDetailsRunningGroupBox$JobId.Left + `$script:MonitorJobsDetailsRunningGroupBox$JobId.Width + (`$FormScale * 10)
                                            top       = `$FormScale * 10
                                            Width     = `$FormScale * 150
                                            Height    = `$FormScale * 402
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                            ForeColor = "DarkGreen"
                                        }
                                        `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedGroupBox$JobId)

                                            `$script:MonitorJobsDetailsCompletedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                                left      = `$FormScale * 5
                                                top       = `$FormScale * 20
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 300
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                FormattingEnabled   = `$True
                                                SelectionMode       = 'MultiExtended'
                                                ScrollAlwaysVisible = `$True
                                                AutoSize            = `$false
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedListBox$JobId)

                                            `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = 'Select All'
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsCompletedListBox$JobId.Top + `$script:MonitorJobsDetailsCompletedListBox$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 22
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsCompletedListBox$JobId.Items.Count; `$i++) {
                                                        `$script:MonitorJobsDetailsCompletedListBox$JobId.SetSelected(`$i, `$true)
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedSelectAllButton$JobId)
                                            Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId


                                            `$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = "Computer TreeView:`nCheckbox The Above`nSelected Endpoints"
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 44
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    [System.Windows.Forms.TreeNodeCollection]`$AllTreeViewNodes = `$script:ComputerTreeView.Nodes
                                                    foreach (`$root in `$AllTreeViewNodes) {
                                                        `$root.Checked = `$false
                                                        foreach (`$Category in `$root.Nodes) {
                                                            `$Category.Checked = `$false
                                                            foreach (`$Entry in `$Category.nodes) {
                                                                `$Entry.Checked = `$false
                                                            }
                                                        }
                                                    }

                                                    foreach (`$Selected in `$script:MonitorJobsDetailsCompletedListBox$JobId.SelectedItems) {
                                                        foreach (`$root in `$AllTreeViewNodes) {
                                                            foreach (`$Category in `$root.Nodes) {
                                                                foreach (`$Entry in `$Category.nodes) {
                                                                    if (`$Entry.Text -eq `$Selected){
                                                                        `$Entry.Checked = `$true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Update-TreeViewData -Endpoint -TreeView `$script:ComputerTreeView.Nodes
                                                }
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId)
                                            Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId


                                    `$script:MonitorJobsDetailsStoppedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Stopped"
                                        left      = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Left + `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Width + (`$FormScale * 10)
                                        top       = `$FormScale * 10
                                        Width     = `$FormScale * 150
                                        Height    = `$FormScale * 402
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Brown"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedGroupBox$JobId)

                                        `$script:MonitorJobsDetailsStoppedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 300
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            FormattingEnabled   = `$True
                                            SelectionMode       = 'MultiExtended'
                                            ScrollAlwaysVisible = `$True
                                            AutoSize            = `$false
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedListBox$JobId)


                                        `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = 'Select All'
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsStoppedListBox$JobId.Top + `$script:MonitorJobsDetailsStoppedListBox$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 22
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsStoppedListBox$JobId.Items.Count; `$i++) {
                                                    `$script:MonitorJobsDetailsStoppedListBox$JobId.SetSelected(`$i, `$true)
                                                }
                                            }
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedSelectAllButton$JobId)
                                        Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId


                                        `$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = "Computer TreeView:`nCheckbox The Above`nSelected Endpoints"
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 44
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                [System.Windows.Forms.TreeNodeCollection]`$AllTreeViewNodes = `$script:ComputerTreeView.Nodes
                                                foreach (`$root in `$AllTreeViewNodes) {
                                                    `$root.Checked = `$false
                                                    foreach (`$Category in `$root.Nodes) {
                                                        `$Category.Checked = `$false
                                                        foreach (`$Entry in `$Category.nodes) {
                                                            `$Entry.Checked = `$false
                                                        }
                                                    }
                                                }

                                                foreach (`$Selected in `$script:MonitorJobsDetailsStoppedListBox$JobId.SelectedItems) {
                                                    foreach (`$root in `$AllTreeViewNodes) {
                                                        foreach (`$Category in `$root.Nodes) {
                                                            foreach (`$Entry in `$Category.nodes) {
                                                                if (`$Entry.Text -eq `$Selected){
                                                                    `$Entry.Checked = `$true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                Update-TreeViewData -Endpoint -TreeView `$script:ComputerTreeView.Nodes
                                            }
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId)
                                        Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId


                                        `$script:MonitorJobsDetailsFailedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                            text      = "Failed"
                                            left      = `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Left + `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Width + (`$FormScale * 10)
                                            top       = `$FormScale * 10
                                            Width     = `$FormScale * 150
                                            Height    = `$FormScale * 402
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                            ForeColor = "Red"
                                        }
                                        `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedGroupBox$JobId)

                                            `$script:MonitorJobsDetailsFailedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                                left      = `$FormScale * 5
                                                top       = `$FormScale * 20
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 300
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                FormattingEnabled   = `$True
                                                SelectionMode       = 'MultiExtended'
                                                ScrollAlwaysVisible = `$True
                                                AutoSize            = `$false
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedListBox$JobId)


                                            `$script:MonitorJobsDetailsFailedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = 'Select All'
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsFailedListBox$JobId.Top + `$script:MonitorJobsDetailsFailedListBox$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 22
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsFailedListBox$JobId.Items.Count; `$i++) {
                                                        `$script:MonitorJobsDetailsFailedListBox$JobId.SetSelected(`$i, `$true)
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedSelectAllButton$JobId)
                                            Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsFailedSelectAllButton$JobId


                                            `$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = "Computer TreeView:`nCheckbox The Above`nSelected Endpoints"
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsFailedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsFailedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 44
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    [System.Windows.Forms.TreeNodeCollection]`$AllTreeViewNodes = `$script:ComputerTreeView.Nodes
                                                    foreach (`$root in `$AllTreeViewNodes) {
                                                        `$root.Checked = `$false
                                                        foreach (`$Category in `$root.Nodes) {
                                                            `$Category.Checked = `$false
                                                            foreach (`$Entry in `$Category.nodes) {
                                                                `$Entry.Checked = `$false
                                                            }
                                                        }
                                                    }

                                                    foreach (`$Selected in `$script:MonitorJobsDetailsFailedListBox$JobId.SelectedItems) {
                                                        foreach (`$root in `$AllTreeViewNodes) {
                                                            foreach (`$Category in `$root.Nodes) {
                                                                foreach (`$Entry in `$Category.nodes) {
                                                                    if (`$Entry.Text -eq `$Selected){
                                                                        `$Entry.Checked = `$true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId)
                                            Add-CommonButtonSettings -Button `$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId


                                    `$script:MonitorJobsDetailsStatusGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Job Messages"
                                        left      = `$FormScale * 10
                                        top       = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Top + `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Height + (`$FormScale * 10)
                                        Width     = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Width + `$script:MonitorJobsDetailsRunningGroupBox$JobId.Width + `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Width + `$script:MonitorJobsDetailsFailedGroupBox$JobId.Width +(`$FormScale * 30)
                                        Height    = `$FormScale * 130
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Black"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsStatusGroupBox$JobId)

                                        `$script:MonitorJobsDetailsStatusRichTextBox$JobId = New-Object System.Windows.Forms.RichTextbox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$script:MonitorJobsDetailsStatusGroupBox$JobId.Width - (`$FormScale * 10)
                                            Height    = `$FormScale * 125
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            ShortcutsEnabled = `$true
                                            ReadOnly         = `$false
                                            ScrollBars       = "Vertical"
                                            MultiLine        = `$True
                                            WordWrap         = `$True
                                        }
                                        `$script:MonitorJobsDetailsStatusGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStatusRichTextBox$JobId)


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Completed'})) {
                                            `$CurrentJobEndpointName = (`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName
                                            `$Job | Receive-Job -Keep -ErrorVariable JobErrors

                                            `$script:MonitorJobsDetailsCompletedListBox$JobId.Items.Add(`$CurrentJobEndpointName)
                                            foreach (`$JobErr in `$JobErrors){
                                                `$script:MonitorJobsDetailsStatusRichTextBox$JobId.text += "[`$(`$CurrentJobEndpointName)] `$(`$JobErr)`n`n"
                                            }
                                        }
                                        `$script:JobsStatusCompletedNameList$JobId -join ', '


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Running'})) {
                                            `$script:MonitorJobsDetailsRunningListBox$JobId.Items.Add((`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName)
                                        }


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Stopped'})) {
                                            `$CurrentJobEndpointName = (`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName

                                            `$script:MonitorJobsDetailsStoppedListBox$JobId.Items.Add(`$CurrentJobEndpointName)
                                            `$script:MonitorJobsDetailsStatusRichTextBox$JobId.text += "[`$(`$CurrentJobEndpointName)]  Timed Out:  `$((New-TimeSpan -Start `$Job.PSBeginTime -End `$Job.PSEndTime).ToString())  (`$(`$Job.PSBeginTime) -- `$(`$Job.PSEndTime))`n`n"
                                        }


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Failed'})) {
                                            `$CurrentJobEndpointName = (`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName

                                            `$script:MonitorJobsDetailsFailedListBox$JobId.Items.Add(`$CurrentJobEndpointName)
                                            `$script:MonitorJobsDetailsStatusRichTextBox$JobId.text += "[`$(`$CurrentJobEndpointName)]  `$(`$job.ChildJobs.JobStateInfo.Reason.Message)`n`n"
                                        }

                                    `$script:MonitorJobsDetailsFrom$JobId.ShowDialog()
            })
        }
"@

        #############
        #  Details  #
        #############
        Invoke-Expression @"
        `$script:MonitorJobsButtonDetails$JobId = New-Object System.Windows.Forms.Button -Property @{
            text     = 'Details'
            Left     = `$script:MonitorJobsButtonStatus$JobId.Left
            Top      = `$script:MonitorJobsButtonStatus$JobId.Top + `$script:MonitorJobsButtonStatus$JobId.Height + (`$FormScale * 5)
            Width    = `$FormScale * 75
            Height   = `$FormScale * 21
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 6),0,0,0)
            Add_click = {
                `$script:Section3MonitorJobViewCommandForm$JobId = New-Object Windows.Forms.Form -Property @{
                    Text          = "View Command - `$(`$script:JobName$JobId)"
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                    Width         = `$FormScale * 670
                    Height        = `$FormScale * 600
                    StartPosition = "CenterScreen"
                    Font          = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                    Add_Closing = {
                        Remove-Variable Section3MonitorJobViewCommandForm$JobId -scope script

                        Remove-Variable Section3MonitorJobViewCommandRichTextBox$JobId -scope script
                        `$This.dispose()
                    }
                }

                    `$script:Section3MonitorJobViewCommandRichTextBox$JobId = New-Object System.Windows.Forms.RichTextBox -Property @{
                        text      =  `$(`$script:InputValues$JobId)  #`$(`$script:CurrentJobs$JobId.command)
                        left      = `$FormScale * 10
                        top       = `$FormScale * 10
                        Width     = `$FormScale * 635
                        Height    = `$FormScale * 545
                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                        ForeColor = "Black"
                        #MultiLine  = `$True
                        #ScrollBars = "Vertical"
                        WordWrap   = `$True
                        ShortcutsEnabled = `$true
                    }
                    `$script:Section3MonitorJobViewCommandForm$JobId.Controls.Add(`$script:Section3MonitorJobViewCommandRichTextBox$JobId)

                `$script:Section3MonitorJobViewCommandForm$JobId.ShowDialog()
            }
        }
"@

        ############
        #  Remove  #
        ############
        Invoke-Expression @"
        `$script:MonitorJobsButtonRemove$JobId = New-Object System.Windows.Forms.Button -Property @{
            Text      = 'Remove'
            Left      = `$script:MonitorJobsButtonStatus$JobId.Left + `$script:MonitorJobsButtonStatus$JobId.Width + (`$FormScale * 5)
            Top       = `$script:MonitorJobsButtonStatus$JobId.Top
            Width     = `$FormScale * 75
            Height   = `$FormScale * 21
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            ForeColor = 'Red'
            Add_click = {
                if ( `$script:MonitorJobsButtonMonitor$JobId.checked ) {
                    [System.Windows.Forms.MessageBox]::Show("You must first uncheck the associated Monitor checkbox to remove this job.","PoSh-EasyWin")
                }
                else {
                    if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
                        `$RemoveJobVerify$JobId = [System.Windows.Forms.MessageBox]::Show("You checked to not keep the saved data.`nAre you sure you want to remove the following:`n        `$(`$script:JobName$JobId)",'PoSh-EasyWin','YesNo','Warning')
                        switch (`$RemoveJobVerify$JobId) {
                            'Yes'{
                                script:Remove-JobsFunction$JobId
                            }
                            'No' {
                                continue
                            }
                        }
                    }
                    else {
                        script:Remove-JobsFunction$JobId
                    }
                }
            }
        }
"@


        #############
        #  Options  #
        #############
        Invoke-Expression @"
        `$script:Section3MonitorJobOptionsButton$JobId = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Options"
            Left      = `$script:MonitorJobsButtonRemove$JobId.Left
            Top       = `$script:MonitorJobsButtonRemove$JobId.Top + `$script:MonitorJobsButtonRemove$JobId.Height + (`$FormScale * 5)
            Width     = `$FormScale * 75
            Height    = `$FormScale * 21
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            Add_click = {
                `$script:Section3MonitorJobViewOptionsForm$JobId = New-Object Windows.Forms.Form -Property @{
                    Text          = "Options - `$(`$script:JobName$JobId)"
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                    Width         = `$FormScale * 670
                    Height        = `$FormScale * 200
                    StartPosition = "CenterScreen"
                    Font          = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                }
                    `$script:Section3MonitorJobViewOptionsGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                        text      = 'Monitor Restart Delay'
                        left      = `$FormScale * 10
                        top       = `$FormScale * 10
                        Width     = `$FormScale * 635
                        Height    = `$FormScale * 145
                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                        ForeColor = "Blue"
                    }
                    `$script:Section3MonitorJobViewOptionsForm$JobId.Controls.Add(`$script:Section3MonitorJobViewOptionsGroupBox$JobId)


                    # The RichtextBox was created outside this scope, so that it's value can be available when commands are restarted without having to open this form
                    `$script:PreviousValue$JobId = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.text
                    `$script:Section3MonitorJobViewOptionsGroupBox$JobId.Controls.Add(`$script:Section3MonitorJobViewOptionsRichTextBox$JobId)


                    `$script:Section3MonitorJobViewOptionsMonitorRestartDelayLabel$JobId = New-Object System.Windows.Forms.Label -Property @{
                        text      = "Monitor Endpoints with Agentless SMITH (System Monitoring Intel-driven Threat Hunting)`nTime is seconds until the command is restarted and runs until an endpoint returns results."
                        left      = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.Left + `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.Width + (`$FormScale * 5)
                        top       = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.top - (`$FormScale * 2)
                        Width     = `$FormScale * 490
                        Height    = `$FormScale * 25
                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                        ForeColor = "Black"
                    }
                    `$script:Section3MonitorJobViewOptionsGroupBox$JobId.Controls.Add(`$script:Section3MonitorJobViewOptionsMonitorRestartDelayLabel$JobId)

                `$script:Section3MonitorJobViewOptionsForm$JobId.ShowDialog()
            }
        }
"@










        #####################
        #  Job Status Text  #
        #####################
        Invoke-Expression @"
        # This Richtextbox was created here to store a value regardless if the form was ever launched
        # It's being invoked within `$script:Section3MonitorJobOptionsButton
        `$script:Section3MonitorJobViewOptionsRichTextBox$JobId = New-Object System.Windows.Forms.RichTextBox -Property @{
            text      = `$script:RestartTime$JobId
            left      = `$FormScale * 20
            top       = `$FormScale * 20
            Width     = `$FormScale * 50
            Height    = `$FormScale * 22
            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
            ForeColor = "Black"
            MultiLine = `$False
            WordWrap  = `$False
            Add_Click = {
                if (`$script:MonitorJobsButtonMonitor$JobId.checked ) {
                    [System.Windows.Forms.MessageBox]::Show("The associated Monitor Checkbox has been uncheck. This is required to ensure that this the new value takes affect.",'PoSh-EasyWin')
                    `$script:MonitorJobsButtonMonitor$JobId.checked = `$false
                }
            }
        }
"@


        ###############
        #  Keep Data  #
        ###############
        Invoke-Expression @"
        `$script:Section3MonitorJobKeepDataCheckbox$JobId = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = 'Keep Data'
            Left     = `$script:MonitorJobsButtonRemove$JobId.Left + `$script:MonitorJobsButtonRemove$JobId.Width + (`$FormScale * 5)
            Top      = `$script:Section3MonitorJobLabel$JobId.Top - (`$FormScale * 2)
            Width    = `$FormScale * 70
            Height   = `$script:JobsRowHeight / 3
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            ForeColor = 'Black'
            Checked   = `$true
            add_click = {
                if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.checked -eq `$false) {
                    `$script:Section3MonitorJobKeepDataAllCheckbox.checked = `$false
                    `$script:Section3MonitorJobKeepDataAllCheckbox.forecolor = 'red'
                    `$script:Section3MonitorJobKeepDataCheckbox$JobId.forecolor = 'red'
                }
                else {
                    `$script:Section3MonitorJobKeepDataCheckbox$JobId.forecolor = 'black'
                }
            }
        }
        if ( `$script:Section3MonitorJobKeepDataAllCheckbox.checked ) {
            `$script:Section3MonitorJobKeepDataCheckbox$JobId.checked = `$true
            `$script:Section3MonitorJobKeepDataCheckbox$JobId.ForeColor = 'Black'
        }
"@


        #############
        #  Monitor  #
        #############
        Invoke-Expression @"
        `$script:MonitorJobsButtonMonitor$JobId = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = 'Monitor'
            Left     = `$script:MonitorJobsButtonRemove$JobId.Left + `$script:MonitorJobsButtonRemove$JobId.Width + (`$FormScale * 5)
            Top      = `$script:Section3MonitorJobKeepDataCheckbox$JobId.Top + `$script:Section3MonitorJobKeepDataCheckbox$JobId.Height + (`$FormScale * 1)
            Width    = `$FormScale * 70
            Height   = `$script:JobsRowHeight / 3
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            Checked  = `$false
            Forecolor = 'black'
        }
"@
        if ($SmithFlag -eq 'RetrieveFile') {
            Invoke-Expression @"
            `$script:SmithFlagRetrieveFile$JobId = `$true
            `$script:MonitorJobsButtonMonitor$JobId.Add_click({
                `$script:RestartTime$JobId = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.text
                if ( `$script:SMITHRunning$JobId -eq `$false -and `$this.checked) {
                    script:Remove-JobsFunction$JobId

                    # Restarts the query, by starting a new job
                    Invoke-Command -ScriptBlock `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId
                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -SmithFlag 'RetrieveFile' -InputValues `$script:InputValues$JobId
                }

                if (`$script:MonitorJobsButtonMonitor$JobId.checked -eq `$false) {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'black'
                }
                else {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'blue'
                }
            })
"@
        }
        elseif ($SmithFlag -eq 'RetrieveADS') {
            Invoke-Expression @"
            `$script:SmithFlagRetrieveADS$JobId = `$true
            `$script:MonitorJobsButtonMonitor$JobId.Add_click({
                `$script:RestartTime$JobId = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.text
                if ( `$script:SMITHRunning$JobId -eq `$false -and `$this.checked) {
                    script:Remove-JobsFunction$JobId

                    # Restarts the query, by starting a new job
                    Invoke-Command -ScriptBlock `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId
                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -SmithFlag 'RetrieveADS' -InputValues `$script:InputValues$JobId
                }

                if (`$script:MonitorJobsButtonMonitor$JobId.checked -eq `$false) {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'black'
                }
                else {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'blue'
                }
            })
"@
        }
        else {
            Invoke-Expression @"
            `$script:MonitorJobsButtonMonitor$JobId.Add_click({
                `$script:RestartTime$JobId = `$script:Section3MonitorJobViewOptionsRichTextBox$JobId.text
                if ( `$script:SMITHRunning$JobId -eq `$false -and `$this.checked) {
                    script:Remove-JobsFunction$JobId

                    # Restarts the query, by starting a new job
                    Invoke-Command -ScriptBlock `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId
                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -InputValues `$script:InputValues$JobId
                }

                if (`$script:MonitorJobsButtonMonitor$JobId.checked -eq `$false) {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'black'
                }
                else {
                    `$script:MonitorJobsButtonMonitor$JobId.forecolor = 'blue'
                }
            })
"@
        }


        if ($AutoReRun) {
            Invoke-Expression @"
                    `$script:MonitorJobsButtonMonitor$JobId.checked = `$true
                    `$script:MonitorJobsButtonMonitor$JobId.ForeColor = 'Black'
"@
        }
        if ($DisableReRun) {
            Invoke-Expression @"
                    `$script:MonitorJobsButtonMonitor$JobId.enabled = `$false
"@
        }



        ###############
        #  Notify Me  #
        ###############
        Invoke-Expression @"
        `$script:Section3MonitorJobNotifyCheckbox$JobId = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = 'Notify Me'
            Left     = `$script:MonitorJobsButtonRemove$JobId.Left + `$script:MonitorJobsButtonRemove$JobId.Width + (`$FormScale * 5)
            Top      = `$script:MonitorJobsButtonMonitor$JobId.Top + `$script:MonitorJobsButtonMonitor$JobId.Height + (`$FormScale * 1)
            Width    = `$FormScale * 70
            Height   = `$script:JobsRowHeight / 3
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            Checked  = `$false
            forecolor = 'black'
        }


        `$script:Section3MonitorJobsTab.Controls.Add(`$script:Section3MonitorJobPanel$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.AddRange(@(
            `$script:MonitorJobsButtonStatus$JobId,
            `$script:MonitorJobsButtonDetails$JobId,
            `$script:Section3MonitorJobLabel$JobId,
            `$script:Section3MonitorJobTransparentLabel$JobId,
            `$script:Section3MonitorJobProgressBar$JobId,
            `$script:MonitorJobsButtonOne$JobId,
            `$script:MonitorJobsButtonTwo$JobId,
            `$script:MonitorJobsButtonThree$JobId,
            `$script:MonitorJobsButtonFour$JobId,
            `$script:MonitorJobsButtonRemove$JobId,
            `$script:Section3MonitorJobOptionsButton$JobId,
            `$script:Section3MonitorJobKeepDataCheckbox$JobId,
            `$script:MonitorJobsButtonMonitor$JobId,
            `$script:Section3MonitorJobNotifyCheckbox$JobId
        ))


        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonStatus$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonDetails$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonOne$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonTwo$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonThree$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonFour$JobId
        Add-CommonButtonSettings -Button `$script:MonitorJobsButtonRemove$JobId
        Add-CommonButtonSettings -Button `$script:Section3MonitorJobOptionsButton$JobId

        `$script:MonitorJobsButtonRemove$JobId.ForeColor = 'Red'

        `$PoShEasyWin.Refresh()

        `$script:MonitorJobsTopPosition += `$script:Section3MonitorJobPanel$JobId.Height + `$script:JobsRowGap

        # This adds each form item to a list
        `$script:PreviousJobFormItemsList += "Section3MonitorJobPanel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobLabel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobDetailsButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobProgressBar$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobTransparentLabel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobRemoveButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobOptionsButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobViewButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobShellButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobChartsButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobKeepDataCheckbox$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobContinuousCheckbox$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobNotifyCheckbox$JobId"
"@

    #############
    #  Tickers  #
    #############

    ##############################################
    # Timer code that monitors the jobs by query #
    ##############################################
    if ($PcapSwitch){
    # For just Packet Capture
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "Endpoint:  `$(`$script:EndpointName$JobId)`n`$script:JobName$JobId"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:MonitorJobsButtonOne$JobId.BackColor = 'LightGreen'
                `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'

                if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng")) {
                    `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen'
                    `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightGreen'
                }
                elseif ((Get-ChildItem "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\`$(`$script:EndpointName$JobId)*Packet Capture*`$(`$script:JobData$JobId)*.pcapng").length -lt 30 ) {
                    `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightCoral'
                    `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightCoral'
                }

                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()

                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script


                `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "Endpoint:  `$(`$script:EndpointName$JobId)`n`$script:JobName$JobId"


                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()
            }
        })
"@
    }
    elseif ($EVTXSwitch){
    # For just Packet Capture
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "Endpoint:  `$(`$script:EndpointName$JobId)`n`$script:JobName$JobId"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:MonitorJobsButtonOne$JobId.BackColor = 'LightGreen'
                `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'

                if ((Test-Path "`$script:EVTXLogfILE$JobId")) {
                    `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen'
                    `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightGreen'
                }
                else {
                    `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightCoral'
                    `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightCoral'
                }

                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()

                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script


                `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "Endpoint:  `$(`$script:EndpointName$JobId)`n`$script:JobName$JobId"

                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()
            }
        })
"@
    }
    elseif ($PSWriteHTMLSwitch) {
    # Just for queries that generate the PSWriteHTML charts
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:MonitorJobsButtonOne$JobId.BackColor = 'LightGreen'

                #if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$false) { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightCoral' }
                #else { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen' }

                `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen'
                `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightGreen'

                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()

                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script

                `$script:CurrentJobs$JobId | Receive-Job -Keep | $SaveResultsCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" $NoTypeInfo
                if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$true) {
                    `$script:CurrentJobs$JobId | Receive-Job -Keep | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                }

                if (`$script:PSWriteHTML$JobId -eq 'EndpointDataSystemSnapshot') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Endpoint Snapshot' -Data { script:Invoke-PSWriteHTMLEndpointSnapshot -InputData `$script:PSWriteHTMLResults$JobId -CheckedItems `$script:PSWriteHTMLOptions$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLProcesses') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Process Data' -Data { script:Invoke-PSWriteHTMLProcess -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'EndpointDataNetworkConnections') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Network Connections' -Data { script:Invoke-PSWriteHTMLNetworkConnections -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'EndpointProcessAndNetwork') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Process And Network' -Data { script:Invoke-PSWriteHTMLProcessAndNetwork -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'EndpointDataConsoleLogons') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Console Logons' -Data { script:Invoke-PSWriteHTMLConsoleLogons -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'PowerShellSessionsData') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'PowerShell Sessions' -Data { script:Invoke-PSWriteHTMLPowerShellSessions -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'EndpointLogonActivity') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'Logon Activity' -Data { script:Invoke-PSWriteHTMLLogonActivity -InputData `$script:PSWriteHTMLResults$JobId } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLADUsers') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'AD Users' -Data { script:Start-PSWriteHTMLActiveDirectoryUsers } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }
                if (`$script:PSWriteHTML$JobId -eq 'PSWriteHTMLADComputers') {
                    `$script:PSWriteHTMLResults$JobId = `$script:CurrentJobs$JobId | Receive-Job -Keep
                    script:Individual-PSWriteHTML -Title 'AD Computers' -Data { script:Start-PSWriteHTMLActiveDirectoryComputers } -FilePath `$script:PSWriteHTMLFilePath$JobId
                }

                `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){ [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin') }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"

                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()
            }
        })
"@
    }
    else {
        if ($SMITH) {
            ###############################
            # Monitor Jobs for Completion #
            ###############################
            Invoke-Expression @"
            `$script:JobStopTime$JobId = `$null
            `$script:JobComplete$JobId = `$false

            `$script:Timer$JobId.add_Tick({
                `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count
                `$script:CurrentTime$JobId = Get-Date

                ##########################
                # When the jobs are DONE #
                ##########################
                if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                    if (`$script:JobComplete$JobId -eq `$false){
                        `$script:JobComplete$JobId = `$true
                        `$script:JobStopTime$JobId = Get-Date
                    }
                    `$script:CurrentJobsWithComputerName$JobId = @()
                    `$script:CurrentJobsWithComputerNameAuto$JobId = @()

                    # Checks to see if there are any results
                    foreach (`$Job in `$script:CurrentJobs$JobId) {
                        `$script:CurrentJobsWithComputerNameAutoEach$JobId = @()

                        if ("$FileExtension" -like 'csv') {
                            `$script:CurrentJobsWithComputerNameAuto$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                        }
                        elseif ("$FileExtension" -like 'txt') {
                            # Layers the results into a sting to produce a text file
                            `$script:CurrentJobsWithComputerNameAuto$JobId += "####################################################################################################"
                            `$script:CurrentJobsWithComputerNameAuto$JobId += (`$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}}).computername | Select -First 1
                            `$script:CurrentJobsWithComputerNameAuto$JobId += "####################################################################################################"
                            `$script:CurrentJobsWithComputerNameAuto$JobId += `$Job | Receive-Job -Keep
                            `$script:CurrentJobsWithComputerNameAuto$JobId += "`r`n"

                            # Saves the results of each query to file
                            `$EndpointHostNameTxt = (`$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}}).computername | Select -First 1
                            `$script:CurrentJobsWithComputerNameAutoEach$JobId += "####################################################################################################"
                            `$script:CurrentJobsWithComputerNameAutoEach$JobId += `$EndpointHostNameTxt
                            `$script:CurrentJobsWithComputerNameAutoEach$JobId += "####################################################################################################"
                            `$script:CurrentJobsWithComputerNameAutoEach$JobId += `$Job | Receive-Job -Keep
                            `$script:CurrentJobsWithComputerNameAutoEach$JobId | Out-File "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId\`$script:JobName$JobId - `$EndpointHostNameTxt.txt"

                            # Attempts to create a csv by replacing more than one space with comas
                            `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Foreach-Object { `$_ -replace "\s{2,}",","} | ConvertFrom-Csv
                        }
                    }

                    function script:Get-JobsCollectedData$JobId {
                        `$script:JobsTimeCompleted$JobId = Get-Date
                        `$script:Timer$JobId.Stop()
                        `$script:Timer$JobId = `$null
                        Remove-Variable -Name Timer$JobId -Scope script

                        `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                        `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"

                        if ( "$JobsExportFiles" -eq "true" ) {
                            # Auto: will save as .txt or .csv depending on if the -txt switch was set
                            `$script:CurrentJobsWithComputerNameAuto$JobId | $SaveResultsCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" $NoTypeInfo

                            # If the -txt switch was applied, this will also attempt to convert it into a csv file... but it's not always accurate ie there are missing fields, so both .csv and .txt are produced in this case
                            if ("$FileExtension" -like 'txt') {
                                `$script:CurrentJobsWithComputerName$JobId | Export-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -NoTypeInformation
                            }

                            # If the save results are XML data is checked under options, the results will be saved
                            if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$true) {
                                `$script:CurrentJobsWithComputerNameAuto$JobId | Select-Object * | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                            }
                            else {
                                `$script:MonitorJobsButtonThree$JobId.Text = 'Shell'
                                #[System.Windows.Forms.MessageBox]::Show("The Feature is disabled by default as it can be resource intensive. To enable, checkbox the 'Save XML Data' within the top center Options tab.",'PoSh-EasyWin')
                            }
                        }
                        elseif ( "$JobsExportFiles" -eq "false" -and "$FileExtension" -like 'csv') {
                            Post-MonitorJobs -CollectionName `$(`$script:JobName$JobId) -ExecutionStartTime `$(`$JobStartTimeFileFriendly$JobId)
                        }

                        `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                        if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                        }


                        `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                        `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'


                        # Sets the button color depending on if there are results
                        if ("$JobsExportFiles" -eq "false" -and (Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\*")) {
                        # Support for PSExec/SMB commands
                            `$script:Section3MonitorJobProgressBar$JobId.ForeColor          = 'LightGreen'
                            `$script:MonitorJobsButtonOne$JobId.BackColor           = 'LightGreen'
                            `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'
                            `$script:MonitorJobsButtonThree$JobId.BackColor          = 'LightCoral'
                            if (Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv") {
                                `$script:MonitorJobsButtonFour$JobId.BackColor     = 'LightGreen'
                            }
                            else {
                                `$script:MonitorJobsButtonFour$JobId.BackColor     = 'LightCoral'
                            }
                        }
                        elseif ("$JobsExportFiles" -eq "false" -and -not (Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$(`$script:JobName$JobId)\*")) {
                        # Support for PSExec/SMB commands
                            `$script:Section3MonitorJobProgressBar$JobId.ForeColor          = 'LightCoral'
                            `$script:MonitorJobsButtonOne$JobId.BackColor           = 'LightCoral'
                            `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightCoral'
                            `$script:MonitorJobsButtonThree$JobId.BackColor          = 'LightCoral'
                            `$script:MonitorJobsButtonFour$JobId.BackColor         = 'LightCoral'
                        }
                        elseif ( `$script:CurrentJobsWithComputerName$JobId.count -ge 1 -or `$script:CurrentJobsWithComputerNameAuto$JobId.count -ge 1) {
                        # Support for normal WinRM and WMI/RPC commands
                            `$script:Section3MonitorJobProgressBar$JobId.ForeColor          = 'LightGreen'
                            `$script:MonitorJobsButtonOne$JobId.BackColor           = 'LightGreen'
                            `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'
                            if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$false) {
                                `$script:MonitorJobsButtonThree$JobId.BackColor      = 'LightCoral'
                            }
                            else {
                                `$script:MonitorJobsButtonThree$JobId.BackColor      = 'LightGreen'
                            }
                            `$script:MonitorJobsButtonFour$JobId.BackColor     = 'LightGreen'
                        }
                        else {
                            `$script:Section3MonitorJobProgressBar$JobId.ForeColor          = 'LightCoral'
                            `$script:MonitorJobsButtonOne$JobId.BackColor           = 'LightCoral'
                            `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightCoral'
                            `$script:MonitorJobsButtonThree$JobId.BackColor          = 'LightCoral'
                            `$script:MonitorJobsButtonFour$JobId.BackColor         = 'LightCoral'
                        }
                        `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                        `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                        `$script:Section3MonitorJobViewOptionsMonitorRestartDelayLabel$JobId.ForeColor = 'Black'


                        # Cleanup
                        `$script:CurrentJobsWithComputerName$JobId = `$null
                        Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                        `$script:SMITHRunning$JobId = `$false
                    }


                    if ( `$script:CurrentJobsWithComputerName$JobId.count -eq 0 -and `$script:MonitorJobsButtonMonitor$JobId.checked -eq `$true ) {

                        # Displays how long until the code is executed again
                        if ( `$script:CurrentTime$JobId -lt `$script:JobStopTime$JobId.AddSeconds(`$script:RestartTime$JobId) ) {
                            `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                            `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                            `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                            `$script:RestartTimeCountdown$JobId = (`$script:JobStopTime$JobId.AddSeconds(`$script:RestartTime$JobId) - `$script:CurrentTime$JobId).TotalSeconds
                            `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] -- Restarts: [`$([Math]::Truncate(`$script:RestartTimeCountdown$JobId))] `n`$script:JobName$JobId"
                        }
                        # Executes the code again when the timer runs out
                        else {
                            if (-not (`$script:CurrentJobs$JobId | Receive-Job -Keep)) {
                                `$script:JobsTimeCompleted$JobId = Get-Date
                                `$script:Timer$JobId.Stop()
                                `$script:Timer$JobId = `$null
                                Remove-Variable -Name Timer$JobId -Scope script

                                script:Remove-JobsFunction$JobId

                                # Restarts the query, by starting a new job
                                Invoke-Command -ScriptBlock `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId
                                if ( `$script:SmithFlagRetrieveFile$JobId ) {
                                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -SmithFlag 'RetrieveFile' -InputValues `$script:InputValues$JobId
                                }
                                elseif ( `$script:SmithFlagRetrieveADS$JobId ) {
                                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -SmithFlag 'RetrieveADS' -InputValues `$script:InputValues$JobId
                                }
                                else {
                                    Monitor-Jobs -CollectionName `$script:JobName$JobId -MonitorMode -SMITH -SMITHscript `$script:SmithScript$JobId -ArgumentList `$script:ArgumentList$JobId -AutoReRun -RestartTime `$script:RestartTime$JobId -InputValues `$script:InputValues$JobId
                                }
                                Remove-Variable -Name "SmithScript$JobId" -Scope script

                                # Cleanup
                                `$script:CurrentJobsWithComputerName$JobId = `$null
                                Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                                `$script:SMITHRunning$JobId = `$false
                            }
                            else {
                                script:Get-JobsCollectedData$JobId

                                `$script:MonitorJobsButtonMonitor$JobId.checked = `$false
                                [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nAgentless SMITH has something to report.`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin - Agentless SMITH')
                            }
                        }
                    }
                    elseif ( `$script:MonitorJobsButtonMonitor$JobId.checked -eq `$false ) {
                        script:Get-JobsCollectedData$JobId
                    }
                }
                else {
                    #####################################################
                    # If the jobs are running, keep updating the status #
                    #####################################################

                    `$script:SMITHRunning$JobId = `$true

                    # Updates the counter and data label
                    `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                    `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"
                    # Updates the Progress bar
                    `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                    `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                    # If the jobs timeout... stop the ticker, save what you've got, and stop the jobs.
                    if (`$script:CurrentTime$JobId -gt (`$script:CurrentJobs$JobId.PSBeginTime[0]).AddSeconds(`$script:JobsTimer$JobId) ) {
                        `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                        `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] -- TIMED OUT `n`$script:JobName$JobId"


                        `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'Gold' #'Orange' #'LightCoral'
                        `$script:MonitorJobsButtonOne$JobId.BackColor = 'Gold' #'Orange'
                        `$script:MonitorJobsButtonTwo$JobId.BackColor = 'Gold' #'Orange'

                        `$script:MonitorJobsButtonThree$JobId.BackColor = 'Gold' #'Orange'
                        `$script:MonitorJobsButtonFour$JobId.BackColor = 'Gold' #'Orange'


                        `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                        `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                        `$script:Section3MonitorJobViewOptionsMonitorRestartDelayLabel$JobId.ForeColor = 'Black'


                        `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Refresh()


                        `$script:JobsTimeCompleted$JobId = Get-Date
                        `$script:Timer$JobId.Stop()
                        `$script:Timer$JobId = `$null
                        Remove-Variable -Name Timer$JobId -Scope script


                        `$script:CurrentJobs$JobId | Receive-Job -Keep | $SaveResultsCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" $NoTypeInfo
                        if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$true) {
                            `$script:CurrentJobs$JobId | Receive-Job -Keep | Select-Object * | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                        }
                        `$script:CurrentJobs$JobId | Stop-Job


                        if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                        }
                    }
                }
            })
"@
        }
        else {
            # Everything else, all the treeview queries checked and collection tabs.
            Invoke-Expression @"
            `$script:Timer$JobId.add_Tick({
                `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

                `$script:CurrentTime$JobId = Get-Date

                if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {

                    `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                    `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"

                    `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                    `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                    `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                    `$script:MonitorJobsButtonOne$JobId.BackColor = 'LightGreen'
                    `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'

                    if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$false) { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightCoral' }
                    else { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen' }
                    `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightGreen'

                    `$script:JobsTimeCompleted$JobId = Get-Date
                    `$script:Timer$JobId.Stop()

                    `$script:Timer$JobId = `$null
                    Remove-Variable -Name Timer$JobId -Scope script


                    `$script:CurrentJobsWithComputerName$JobId = @()
                    foreach (`$Job in `$script:CurrentJobs$JobId) {
                        `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                    }


                    `$script:CurrentJobsWithComputerName$JobId | $SaveResultsCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" $NoTypeInfo
                    if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$true) {
                        `$script:CurrentJobsWithComputerName$JobId | Select-Object * | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                    }

                    `$script:CurrentJobsWithComputerName$JobId = `$null
                    Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script

                    `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                    `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                    `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                    if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                        [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                    }
                }
                else {
                    `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                    `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `n`$script:JobName$JobId"

                    `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                    `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                    if (`$script:CurrentTime$JobId -gt (`$script:CurrentJobs$JobId.PSBeginTime[0]).AddSeconds(`$script:JobsTimer$JobId) ) {
                        `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                        `$script:Section3MonitorJobTransparentLabel$JobId.Text = "Endpoint Count: [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] -- TIMED OUT `n`$script:JobName$JobId"

                        `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightCoral'
                        `$script:MonitorJobsButtonOne$JobId.Text = 'View Results'
                        `$script:MonitorJobsButtonOne$JobId.BackColor = 'LightGreen'
                        `$script:MonitorJobsButtonTwo$JobId.BackColor = 'LightGreen'
                        if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$false) { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightCoral' }
                        else { `$script:MonitorJobsButtonThree$JobId.BackColor = 'LightGreen' }
                        `$script:MonitorJobsButtonFour$JobId.BackColor = 'LightGreen'

                        `$script:JobsTimeCompleted$JobId = Get-Date
                        `$script:Timer$JobId.Stop()

                        `$script:Timer$JobId = `$null
                        Remove-Variable -Name Timer$JobId -Scope script


                        `$script:CurrentJobs$JobId | Receive-Job -Keep | $SaveResultsCmd "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).$FileExtension" $NoTypeInfo
                        if (`$OptionSaveCliXmlDataCheckBox.checked -eq `$true) {
                            `$script:CurrentJobs$JobId | Receive-Job -Keep | Select-Object * | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                        }
                        `$script:CurrentJobs$JobId | Stop-Job


                        `$script:Section3MonitorJobProgressBar$JobId.Maximum = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Value = 1
                        `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                        if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                            [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                        }
                    }
                }
            })
"@
        }
    }
}

































    #########################################################
    # Individual Execution, is not the same as Monitor Mode #
    #########################################################

    if (-not $MonitorMode) {
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        # Creates locations to saves the results from jobs
        if (-not (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)")){
            New-Item -Type Directory "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)" -Force -ErrorAction SilentlyContinue
        }

        # Initially updates statistics
        $StatisticsResults = Get-PoShEasyWinStatistics
        $StatisticsNumberOfCSVs.text = $StatisticsResults

        $SleepMilliSeconds = 250
        $script:ProgressBarEndpointsProgressBar.Value = 0
        $script:ProgressBarFormProgressBar.Value      = 0

        # Sets the job timeout value, so they don't run forever
        $script:JobsTimer  = [int]$($script:OptionJobTimeoutSelectionComboBox.Text)
        # This is how often the statistics page updates, be default it is 20 which is 5 Seconds (250 ms x 4)
        $StatisticsUpdateInterval      = (1000 / $SleepMilliSeconds) * 5
        $StatisticsUpdateIntervalCount = 0

        # The number of Jobs created by PoSh-EasyWin
        $JobsCount = (Get-Job -Name "PoSh-EasyWin:*").count
        $script:ProgressBarEndpointsProgressBar.Maximum = $JobsCount
        $script:ProgressBarFormProgressBar.Maximum      = $JobsCount

        $Done = 0

        do {
            # Updates Statistics
            $StatisticsUpdateIntervalCount++
            if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
                $StatisticsResults = Get-PoShEasyWinStatistics
                $StatisticsNumberOfCSVs.text = $StatisticsResults
            }

            # The number of Jobs created by PoSh-EasyWin
            $CurrentJobs = Get-Job -Name "PoSh-EasyWin:*"

            # Breaks loops if there are not jobs
            if ($CurrentJobs.count -eq 0) {break}



            # Calcualtes and formats time elaspsed
            $CurrentTime = Get-Date
            $Timecount   = $ExecutionStartTime - $CurrentTime
            $Hour        = [Math]::Truncate($Timecount)
            $Minute      = ($CollectionTime - $Hour) * 60
            $Second      = [int](($Minute - ([Math]::Truncate($Minute))) * 60)
            $Minute      = [Math]::Truncate($Minute)
            $Timecount   = [datetime]::Parse("$Hour`:$Minute`:$Second")

            # Provides updates on the jobs
            $ResultsListBox.Items.Insert(0,"Running Jobs:  $($JobsCount - $Done)")
            $ResultsListBox.Items.Insert(1,"Current Time:  $($CurrentTime)")
            $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
            $ResultsListBox.Items.Insert(3,"")

            # From ProgressBar Update (if used)
            $script:ProgressBarMainLabel.text = "Status:
Running Jobs:  $($JobsCount - $Done)
Current Time:  $($CurrentTime)
Elasped Time:  $($Timecount -replace '-','')"

            # This is how often PoSoh-EasyWin's GUI will refresh when provide the status of the jobs
            # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
            Start-Sleep -MilliSeconds $SleepMilliSeconds
            $ResultsListBox.Refresh()

            # Checks if the current job is running too long and stops it
            foreach ($Job in $CurrentJobs) {
                # Gets the results from jobs that are completed, saves them, and deletes the job
                if ( $Job.State -eq 'Completed' ) {
                    $Done++
                    $script:ProgressBarEndpointsProgressBar.Value = $Done
                    $script:ProgressBarFormProgressBar.Value      = $Done

                    $JobName     = $Job.Name  -replace 'PoSh-EasyWin: ',''
                    $JobReceived = $Job | Receive-Job #-Keep

                    if (-not $NotExportFiles) {
                        if ($job.Location -notmatch $(($Job.Name -split ' ')[-1]) ) {
                            if ($SaveProperties) {
                                # This is needed because when jobs are started locally that use invoke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                                $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.csv" $NoTypeInfo
                                if ($OptionSaveCliXmlDataCheckBox.checked -eq $true) {
                                    $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.xml"
                                }
                            }
                            else {
                                # This is needed because when jobs are started locally that use inovke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                                $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-CSV "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.csv" $NoTypeInfo
                                if ($OptionSaveCliXmlDataCheckBox.checked -eq $true) {
                                    $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.xml"
                                }
                            }
                        }
                        else {
                            if ($SaveProperties) {
                                $JobReceived | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.csv" $NoTypeInfo
                                if ($OptionSaveCliXmlDataCheckBox.checked -eq $true) {
                                    $JobReceived | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.xml"
                                }
                            }
                            else {
                                $JobReceived | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.csv" $NoTypeInfo
                                if ($OptionSaveCliXmlDataCheckBox.checked -eq $true) {
                                    $JobReceived | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$JobName.xml"
                                }
                            }
                        }
                    }
                    $Job | Remove-Job -Force
                }
                elseif ($CurrentTime -gt ($Job.PSBeginTime).AddSeconds($script:JobsTimer)) {
                    $TimeStamp = $($CurrentTime).ToString('yyyy/MM/dd HH:mm:ss')
                    $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[-1])")
                    $Job | Stop-Job
                    $Job | Receive-Job -Force
                    $Job | Remove-Job -Force
                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message " - Job [TIMED OUT]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ran for $($CurrentTime - $Job.PSBeginTime)"
                    break
                }
            }

            $ResultsListBox.Items.RemoveAt(0)
            $ResultsListBox.Items.RemoveAt(0)
            $ResultsListBox.Items.RemoveAt(0)
            $ResultsListBox.Items.RemoveAt(0)
        } while ($Done -lt $JobsCount)

        # Logs Jobs Beginning and Ending Times
        foreach ($Job in $CurrentJobs) {
            if ($($Job.PSEndTime -ne $null)) {
            # $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                #$ResultsListBox.Items.insert(1,"$($TimeStamp)   - Job Completed: $((($Job | Select-Object -ExpandProperty Name) -split ' ')[-1])")
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "$($TimeStamp)  Job [COMPLETED]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ended at $($Job.PSEndTime)"
            }
        }

        # Updates Statistics One last time
        $StatisticsResults           = Get-PoShEasyWinStatistics
        $StatisticsNumberOfCSVs.text = $StatisticsResults
        Get-Job -Name "PoSh-EasyWin:*" | Remove-Job -Force -ErrorAction SilentlyContinue
        $PoShEasyWin.Refresh()
        Start-Sleep -Seconds 1
    }


}








# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJqI9i1EiARipgtxkNY9IfZG/
# u5SgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWW7OuHXzM8q2O7v9kYOxBRQMcxowDQYJKoZI
# hvcNAQEBBQAEggEAVilFrStvPf2eOzFZNUq1zRL0jM78DtjsYssANU0iYfM0Nyhc
# jWvahQSkqjgbcYpc+NxS/oMU0sVoQKnZNRcgSz9qaMflqCGopkPfAiHNYtwMjaDZ
# hPFb7rqGSvEB2APoMIO3J2JHfzQnFDq07rd28furTXNNzX4kNHeQTmIwk8ku8rxN
# z2s/58v8xsYxvURT32YWe1P1QsGTjYkdICkFsOFTtlImUhsgIEzuH8FUW6Gix5Bq
# T3+Gy9DCRL1vX1M/5KIoKRwNd2p7Rahjj69DFCDd/Qbr+r7KnsameWk/PWhL8xtN
# oNdz49B1yrCmI/grHiln98TEuD+hIzOrbmODhg==
# SIG # End signature block
