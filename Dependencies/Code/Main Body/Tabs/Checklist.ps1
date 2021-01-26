
$MainLeftChecklistTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Checklist"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
if (Test-Path "$Dependencies\Checklists") { $MainLeftTabControl.Controls.Add($MainLeftChecklistTab) }


$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557
$TextBoxRightPosition = -2
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536


$MainLeftChecklistTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Checklist TabControl"
    Location  = @{ X = $FormScale * $TabRightPosition
                   Y = $FormScale * $TabhDownPosition }
    Size      = @{ Width  = $FormScale * $TabAreaWidth
                   Height = $FormScale * $TabAreaHeight }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftChecklistTab.Controls.Add($MainLeftChecklistTabControl)


#-------------------------------------------------------
# Checklists Auto Create Tabs and Checkboxes from files
#-------------------------------------------------------
$ResourceChecklistFiles = Get-ChildItem "$Dependencies\Checklists"

# Iterates through the files and dynamically creates tabs and imports data
Update-FormProgress "$Dependencies\Code\Main Body\Dynamically Create Checklists.ps1"
. "$Dependencies\Code\Main Body\Dynamically Create Checklists.ps1"
