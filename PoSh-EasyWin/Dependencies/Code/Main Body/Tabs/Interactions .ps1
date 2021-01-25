
$Section1InteractionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Interactions"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 0 }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($Section1InteractionsTab)


$MainLeftSection1InteractionsTabTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Interactions TabControl"
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1InteractionsTab.Controls.Add($MainLeftSection1InteractionsTabTabControl)


Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Interactions\Interactions Multi-Endpoint Actions.ps1"
. "$Dependencies\Code\Main Body\Tabs\Interactions\Interactions Multi-Endpoint Actions.ps1"
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()


Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Interactions\Interactions Executables.ps1"
. "$Dependencies\Code\Main Body\Tabs\Interactions\Interactions Executables.ps1"
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()
