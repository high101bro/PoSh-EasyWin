# Deprecated
# $Section1ProcessesTab = New-Object System.Windows.Forms.TabPage -Property @{
#     Text                    = "Processes"
#     Name                    = "Processes Tab"
#     UseVisualStyleBackColor = $True
#     Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ImageIndex = 1
# }
# if (Test-Path "$Dependencies\Process Info") { $MainLeftTabControl.Controls.Add($Section1ProcessesTab) }


# $TabRightPosition       = 3
# $TabhDownPosition       = 3
# $TabAreaWidth           = 446
# $TabAreaHeight          = 557
# #$TextBoxRightPosition   = -2
# #$TextBoxDownPosition    = -2
# #$TextBoxWidth           = 442
# #$TextBoxHeight          = 536


# $MainLeftProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
#     Name     = "Processes TabControl"
#     Location = @{ X = $FormScale * $TabRightPosition
#                   Y = $FormScale * $TabhDownPosition }
#     Size     = @{ Width  = $FormScale * $TabAreaWidth
#                   Height = $FormScale * $TabAreaHeight }
#     Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ShowToolTips  = $True
#     SelectedIndex = 0
# }
# $Section1ProcessesTab.Controls.Add($MainLeftProcessesTabControl)

# Deprecated
# # Dynamically generates tabs
# # Iterates through the files and dynamically creates tabs and imports data
# Load-Code "$Dependencies\Code\Main Body\Dynamically Create Process Info.ps1"
# . "$Dependencies\Code\Main Body\Dynamically Create Process Info.ps1"
# $script:ProgressBarFormProgressBar.Value += 1
# $script:ProgressBarSelectionForm.Refresh()
