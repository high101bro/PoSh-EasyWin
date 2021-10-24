function Set-GuiLayout {
    param(
        [switch]$Compact,
        [switch]$Extended
    )
    if ($Compact) {
        $PoShEasyWin.Width = $FormScale * 1260
        $PoShEasyWin.Height = $FormScale * 660

        $QueryAndCollectionPanel.Controls.Remove($PoShEasyWinPictureBox)
        $Section3AboutTab.Controls.Add($PoShEasyWinPictureBox)

        $MainLeftTabControl.Top = 0

        $QueryAndCollectionPanel.Width = $FormScale * 460
        $QueryAndCollectionPanel.Height = $FormScale * 590
    
        $MainCenterPanel.Left = $FormScale * 470
        $MainCenterPanel.Top = $FormScale * 5
        $MainCenterPanel.Width = $FormScale * 370
        $MainCenterPanel.Height = $FormScale * 278 
            $StatusListBox.Width = $FormScale * 295
            $script:ProgressBarEndpointsProgressBar.Width = $StatusListBox.Width - ($FormScale * 1)
            $script:ProgressBarQueriesProgressBar.Width = $StatusListBox.Width - ($FormScale * 1)

            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Width = $FormScale * 352
            $ResultsFolderAutoTimestampCheckbox.Left = $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Left
            $DirectoryUpdateButton.Left = $ResultsFolderAutoTimestampCheckbox.Left + $ResultsFolderAutoTimestampCheckbox.Width + $($FormScale * 5)
            $DirectoryOpenButton.Left = $DirectoryUpdateButton.Left + $DirectoryUpdateButton.Width + $($FormScale * 5)
            $PoshEasyWinStatistics.Width = $FormScale * 354
            $MainCenterMainTab.Controls.Remove($PowerShellTerminalButton)

        $ComputerAndAccountTreeNodeViewPanel.Left = $FormScale * 845
        $ComputerAndAccountTreeNodeViewPanel.Top = $FormScale * 7
        $ComputerAndAccountTreeNodeViewPanel.Width = $FormScale * 230
        $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 300
            $ComputerAndAccountTreeViewTabControl.Width = $FormScale * 230
            $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 275
            $ComputerTreeNodeSearchGreedyCheckbox.Left = $script:ComputerTreeNodeComboBox.Left + $script:ComputerTreeNodeComboBox.Width + $($FormScale * 45)
            $ComputerTreeNodeSearchComboBox.Width = $FormScale * 162
            $ComputerTreeNodeSearchButton.Left = $ComputerTreeNodeSearchComboBox.Left + $ComputerTreeNodeSearchComboBox.Width + ($FormScale * 5 )
            $script:ComputerTreeView.Left = $ComputerTreeNodeSearchComboBox.Left
            $script:ComputerTreeView.Top = $ComputerTreeNodeSearchButton.Top + $ComputerTreeNodeSearchButton.Height + ($FormScale * 5)
            $script:ComputerTreeView.Width = $FormScale * 222
            $script:ComputerTreeView.Height = $FormScale * 200
            $script:ComputerTreeView.Add_MouseHover({
                $ComputerAndAccountTreeNodeViewPanel.Height = $QueryAndCollectionPanel.Height
                $ComputerAndAccountTreeViewTabControl.Height = $QueryAndCollectionPanel.Height - ($FormScale * 2)
                $script:ComputerTreeView.Height = $FormScale * 514
                $ComputerAndAccountTreeNodeViewPanel.bringtofront()
                $ComputerAndAccountTreeViewTabControl.bringtofront()
                $script:ComputerTreeView.bringtofront()
            })
            $script:ComputerTreeView.Add_MouseLeave({
                $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 300
                $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 275
                $script:ComputerTreeView.Height = $FormScale * 200
            })
            $script:ComputerTreeView.Scrollable = $true

        $ExecutionButtonPanel.Left = $FormScale * 1082
        $ExecutionButtonPanel.Top = $FormScale * 7
        $ExecutionButtonPanel.Height = $FormScale * 300
        $ExecutionButtonPanel.Width = $FormScale * 140
            $MainRightTabControl.Height = $ComputerAndAccountTreeViewTabControl.Height
        
        $InformationPanel.Left = $MainCenterPanel.Left
        $InformationPanel.Top = $MainCenterPanel.Top + $MainCenterPanel.Height + ($FormScale * 5)
        $InformationPanel.Width = $FormScale * 752
        $InformationPanel.Height = $FormScale * 352
  
        $ResultsTabOpNotesAddButton.Top = $FormScale * 296
            $InformationTabControl.Height = $FormScale * 307
            $Section1AboutSubTabRichTextBox.Top = $PoShEasyWinPictureBox.Top + $PoShEasyWinPictureBox.Height
            $Section1AboutSubTabRichTextBox.Height = ($FormScale * 283) - $PoShEasyWinPictureBox.Height
            $ResultsListBox.Height = $FormScale * 276
            $Section3HostDataNotesRichTextBox.Height = $FormScale * 200

            function script:Maximize-MonitorJobsTab {
                $script:Section3MonitorJobsResizeButton.text = "v Minimize Tab"
                $InformationPanel.Top = $MainCenterTabControl.Top
                $InformationPanel.Height = $FormScale * 605
                $InformationPanel.bringtofront()
                $InformationTabControl.Height = $FormScale * 595
            }
            function script:Minimize-MonitorJobsTab {
                $script:Section3MonitorJobsResizeButton.text = "^ Maximize Tab"
                $InformationPanel.Top = $InformationTabControlOriginalTop
                $InformationPanel.Height = $FormScale * 340
                $InformationPanel.bringtofront()
                $InformationTabControl.Height = $InformationPanel.Height - ($FormScale * 33)
            }
    }
    elseif ($Extended) {
        $PoShEasyWin.Width = $FormScale * 1470
        $PoShEasyWin.Height = $FormScale * 695

        $Section3AboutTab.Controls.Remove($PoShEasyWinPictureBox)
        $QueryAndCollectionPanel.Controls.Add($PoShEasyWinPictureBox)

        $MainLeftTabControl.Top = $PoShEasyWinPictureBox.Top + $PoShEasyWinPictureBox.Height

        $QueryAndCollectionPanel.Width = $FormScale * 460
        $QueryAndCollectionPanel.Height = $FormScale * 645
    
        $ComputerAndAccountTreeNodeViewPanel.Left = $FormScale * 472
        $ComputerAndAccountTreeNodeViewPanel.Top = $FormScale * 5
        $ComputerAndAccountTreeNodeViewPanel.Width = $FormScale * 200
        $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 635
            $ComputerAndAccountTreeViewTabControl.Width = $FormScale * 192
            $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 635
            $ComputerTreeNodeSearchGreedyCheckbox.Left = $script:ComputerTreeNodeComboBox.Left + $script:ComputerTreeNodeComboBox.Width + $($FormScale * 5)
            $ComputerTreeNodeSearchComboBox.Width = $FormScale * 120
            $ComputerTreeNodeSearchButton.Left = $ComputerTreeNodeSearchComboBox.Left + $ComputerTreeNodeSearchComboBox.Width + ($FormScale * 5 )
            $script:ComputerTreeView.Left = $ComputerTreeNodeSearchComboBox.Left
            $script:ComputerTreeView.Top = $ComputerTreeNodeSearchButton.Top + $ComputerTreeNodeSearchButton.Height + ($FormScale * 5)
            $script:ComputerTreeView.Width = $FormScale * 180
            $script:ComputerTreeView.Height = $FormScale * 558
            $script:ComputerTreeView.Add_MouseHover({
                $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 635
                $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 635
                $script:ComputerTreeView.Height = $FormScale * 558
            })
            $script:ComputerTreeView.Add_MouseLeave({
                $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 635
                $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 635
                $script:ComputerTreeView.Height = $FormScale * 558
            })

        $MainCenterPanel.Left = $ComputerAndAccountTreeNodeViewPanel.Left + $ComputerAndAccountTreeNodeViewPanel.Width + ($FormScale * 2)
        $MainCenterPanel.Top = $FormScale * 5
        $MainCenterPanel.Width = $FormScale * 607
        $MainCenterPanel.Height = $FormScale * 278 
            $MainCenterTabControl.Width = $FormScale * 607
            $script:CollectionSavedDirectoryTextBox.Width = $FormScale * 595
            $DirectoryOpenButton.Left = $script:CollectionSavedDirectoryTextBox.Width - ($FormScale * 232)
            $DirectoryUpdateButton.Left = $DirectoryOpenButton.Left + $DirectoryOpenButton.width + ($FormScale * 5)
            $StatusListBox.Width = $FormScale * 535
            $script:ProgressBarEndpointsProgressBar.Width = $StatusListBox.Width - ($FormScale * 1)
            $script:ProgressBarQueriesProgressBar.Width = $StatusListBox.Width - ($FormScale * 1)

            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Width = $FormScale * 590
            $ResultsFolderAutoTimestampCheckbox.Left = $script:CollectionSavedDirectoryTextBox.Left + ($FormScale * 240)
            $DirectoryUpdateButton.Left = $ResultsFolderAutoTimestampCheckbox.Left + $ResultsFolderAutoTimestampCheckbox.Width + $($FormScale * 5)
            $DirectoryOpenButton.Left = $DirectoryUpdateButton.Left + $DirectoryUpdateButton.Width + $($FormScale * 5)
            $PoshEasyWinStatistics.Width = $FormScale * 590
            $MainCenterMainTab.Controls.Add($PowerShellTerminalButton)

        $ExecutionButtonPanel.Left = $MainCenterPanel.Left + $MainCenterPanel.Width + ($FormScale * 5)
        $ExecutionButtonPanel.Top = $FormScale * 10
        $ExecutionButtonPanel.Height = $FormScale * 273
        $ExecutionButtonPanel.Width = $FormScale * 140
            $MainRightTabControl.Height = $FormScale * 273


        $InformationPanel.Left = $MainCenterPanel.Left
        $InformationPanel.Top = $MainCenterPanel.Top + $MainCenterPanel.Height + ($FormScale * 5)
        $InformationPanel.Width = $FormScale * 752
        $InformationPanel.Height = $FormScale * 352
            $ResultsTabOpNotesAddButton.Top = $FormScale * 296
            $InformationTabControl.Height = $FormScale * 352
            $Section1AboutSubTabRichTextBox.Top = $FormScale * 10
            $Section1AboutSubTabRichTextBox.Height = $FormScale * 317
            $ResultsListBox.Height = $FormScale * 317
            $Section3HostDataNotesRichTextBox.Height = $FormScale * 243

            function script:Maximize-MonitorJobsTab {
                $script:Section3MonitorJobsResizeButton.text = "v Minimize Tab"
                $InformationPanel.Top    = $ComputerAndAccountTreeNodeViewPanel.Top
                $InformationPanel.Height = $FormScale * 655
                $InformationPanel.bringtofront()
                $InformationTabControl.Height = $ComputerAndAccountTreeNodeViewPanel.Height
            }            
            function script:Minimize-MonitorJobsTab {
                $script:Section3MonitorJobsResizeButton.text = "^ Maximize Tab"
                $InformationPanel.Top    = $InformationTabControlOriginalTop
                $InformationPanel.Height = $FormScale * 352
                $InformationPanel.bringtofront()
                $InformationTabControl.Height = $InformationPanel.Height
            }
    }
}