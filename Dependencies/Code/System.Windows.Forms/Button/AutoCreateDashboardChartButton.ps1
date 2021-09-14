$AutoCreateDashboardChartButtonAdd_Click = {
    # https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
    # https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/
    # Auto Charts Select Property Function

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    #----------------------------------
    # Auto Create Charts Selection Form
    #----------------------------------
    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        Name          = "Dashboard Charts"
        Text          = "Dashboard Charts"
        Size      = @{ Width  = $FormScale * 327
                       Height = $FormScale * 155 }
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        #ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        Add_Closing = { $This.dispose() }
    }

    #------------------------------
    # Auto Create Charts Main Label
    #------------------------------
    $AutoChartsMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Generates a dashboard with multiple charts "
        Location = @{ X = $FormScale * 10
                      Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 300
                      Height = $FormScale * 25 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)


    #----------------------------------
    # Auto Chart Select Chart ComboBox
    #----------------------------------
    $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Select A Chart"
        Location  = @{ X = $FormScale * 10
                     Y = $AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + $($FormScale * 5) }
        Size      = @{ Width  = $FormScale * 292
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Red'
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Launch-AutoChartsViewCharts }})
    $AutoChartSelectChartComboBox.Add_Click({
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
    })
    $AutoChartsAvailable = @(
        "Dashboard Overview",
        "Active Directory Computers, Users, and Groups",
        "Threat Hunting with Deep Blue"
    )
    ForEach ($Item in $AutoChartsAvailable) { [void] $AutoChartSelectChartComboBox.Items.Add($Item) }
    $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox)


    #----------------------------
    # Auto Charts - Progress Bar
    #----------------------------
    $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Style    = "Continuous"
        #Maximum = 10
        Minimum  = 0
        Location = @{ X = $FormScale * 10
                      Y = $AutoChartSelectChartComboBox.Location.y + $AutoChartSelectChartComboBox.Size.Height + 10 }
        Size     = @{ Width  = $FormScale * 290
                      Height = $FormScale * 10 }
        Value   = 0
    }
    $AutoChartsSelectionForm.Controls.Add($script:AutoChartsProgressBar)


    #-----------------------------------
    # Auto Create Charts Execute Button
    #-----------------------------------
    $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "View Dashboard"
        Location = @{ X = $AutoChartsProgressBar.Location.X
                      Y = $AutoChartsProgressBar.Location.y + $AutoChartsProgressBar.Size.Height + $($FormScale * 5) }
        Size     = @{ Width  = $AutoChartsProgressBar.Size.Width
                      Height = $FormScale * 22 }
    }
    Apply-CommonButtonSettings -Button $AutoChartsExecuteButton
    $AutoChartsExecuteButton.Add_Click({
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
        Launch-AutoChartsViewCharts
    })
    function Launch-AutoChartsViewCharts {
        #####################################################################################################################################
        #####################################################################################################################################
        ##
        ## Auto Create Charts Form
        ##
        #####################################################################################################################################
        #####################################################################################################################################
        $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
            [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $script:AutoChartsForm = New-Object Windows.Forms.Form -Property @{
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 5 }
            Size     = @{ Width  = $PoShEasyWin.Size.Width    #1241
                          Height = $PoShEasyWin.Size.Height } #638
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_Closing = { $This.dispose() }
        }


        #####################################################################################################################################
        ##
        ## Auto Create Charts TabControl
        ##
        #####################################################################################################################################
        # The TabControl controls the tabs within it
        $AutoChartsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
            Name     = "Auto Charts"
            Text     = "Auto Charts"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 5 }
            Size     = @{ Width  = $PoShEasyWin.Size.Width - $($FormScale * 25)
                          Height = $PoShEasyWin.Size.Height - $($FormScale * 50) }
        }
        $AutoChartsTabControl.ShowToolTips  = $True
        $AutoChartsTabControl.SelectedIndex = 0
        $AutoChartsTabControl.Anchor        = $AnchorAll
        $AutoChartsTabControl.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        $script:AutoChartsForm.Controls.Add($AutoChartsTabControl)

        # Dashboard with multiple charts
        if ($AutoChartSelectChartComboBox.SelectedItem -eq "Dashboard Overview") {
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Hunt.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Services.ps1"
            [System.Windows.Forms.MessageBox]::Show("These charts are populated with data from previous queries. If some of the charts are outdated or don't contain data, try running the associated queries. There is a command group with all the applicable queries needs for your convienience.","PoSh-EasyWin",'Ok',"Info")
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Active Directory Computers, Users, and Groups") {
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_ActiveDirectoryComputers.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_ActiveDirectoryUserAccounts.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_ActiveDirectoryGroups.ps1"
            
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Threat Hunting with Deep Blue") {
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_DeepBlue.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        # Garbage Collection to free up memory
        [System.GC]::Collect()
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)
    [void] $AutoChartsSelectionForm.ShowDialog()

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$AutoCreateDashboardChartButtonAdd_MouseHover = {
    Show-ToolTip -Title "Dashboard Charts" -Icon "Info" -Message @"
+  Utilizes PowerShell (v3) charts to visualize data.
+  These charts are auto created from pre-selected CSV files and fields.
+  The dashboard consists of multiple charts from the same CSV file and
    are designed for easy analysis of data to identify outliers.
+  Each chart can be modified and an image can be saved.
"@
}


