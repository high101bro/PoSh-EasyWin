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
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        #ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
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
    $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AutoChartsViewCharts }})
    $AutoChartSelectChartComboBox.Add_Click({
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
    })
    $AutoChartsAvailable = @(
        "Active Directory Users",
        "Active Directory Computers",
        "Dashboard Quick View",
        "Network Interfaces",
        "Processes",
        "Security Patches",
        "Services",
        "SMB Shares",
        "Software",
        "Startups"
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
    CommonButtonSettings -Button $AutoChartsExecuteButton
    $AutoChartsExecuteButton.Add_Click({ 
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
        AutoChartsViewCharts
    })
    function AutoChartsViewCharts {
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
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
            Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
        if ($AutoChartSelectChartComboBox.SelectedItem -eq "Active Directory Users") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_ActiveDirectoryUserAccounts.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Active Directory Computers") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_ActiveDirectoryComputerAccounts.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Dashboard Quick View") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Hunt.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Network Interfaces") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_NetworkInterfaces.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Processes") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Processes.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_SecurityPatches.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Services.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "SMB Shares") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_SmbShare.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }                
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Software.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startups") { 
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\AutoChartSelectChartComboBoxSelectedItem_Startups.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }

    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)   
    [void] $AutoChartsSelectionForm.ShowDialog()

    CommonButtonSettings -Button $OpenXmlResultsButton
    CommonButtonSettings -Button $OpenCsvResultsButton
    
    CommonButtonSettings -Button $BuildChartButton
    CommonButtonSettings -Button $AutoCreateDashboardChartButton
    CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton
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
