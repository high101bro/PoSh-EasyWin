
$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info" #"Results"
    Name = "Results Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
}
$InformationTabControl.Controls.Add($Section3ResultsTab)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add Selected To OpNotes"
    Left   = $FormScale * 578
    Width  = $FormScale * 150
    Height = $FormScale * 25
    Add_Click = $ResultsTabOpNotesAddButtonAdd_Click
    Add_MouseHover = $ResultsTabOpNotesAddButtonAdd_MouseHover
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton)
CommonButtonSettings -Button $ResultsTabOpNotesAddButton


$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "ResultsListBox"
    Left   = $FormScale * 3
    Top    = $FormScale * 10
    Width  = $FormScale * 742
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsListBox)
