
$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info" #"Results"
    Name = "Results Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3ResultsTab)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Selected To OpNotes"
    Location  = @{ X = $FormScale * 578
                   Y = $FormScale * 198 }
    Size      = @{ Width  = $FormScale * 150
                   Height = $FormScale * 25 }
    Add_Click = $ResultsTabOpNotesAddButtonAdd_Click
    Add_MouseHover = $ResultsTabOpNotesAddButtonAdd_MouseHover
}
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton)
CommonButtonSettings -Button $ResultsTabOpNotesAddButton


$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "ResultsListBox"
    Location = @{ X = $FormScale * -1
                  Y = $FormScale * -1 }
    Size     = @{ Width  = $FormScale * 752 - 3
                  Height = $FormScale * 250 - 15 }
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsListBox)
