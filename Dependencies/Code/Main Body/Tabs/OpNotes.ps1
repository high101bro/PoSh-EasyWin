
$Section1OpNotesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "OpNotes"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainLeftTabControl.Controls.Add($Section1OpNotesTab)

#$TabRightPosition          = 3
#$TabhDownPosition          = 3
#$TabAreaWidth              = 446
#$TabAreaHeight             = 557
$OpNotesInputTextBoxWidth  = 450
$OpNotesInputTextBoxHeight = 22
$OpNotesButtonWidth        = 100
$OpNotesButtonHeight       = 22
$OpNotesMainTextBoxWidth   = 450
$OpNotesMainTextBoxHeight  = 470
$OpNotesRightPositionStart = 0
$OpNotesRightPosition      = 0
$OpNotesRightPositionShift = $OpNotesButtonWidth + 10
$OpNotesDownPosition       = 2
$OpNotesDownPositionShift  = 22

# The purpose to allow saving of Opnotes automatcially
Load-Code "$Dependencies\Code\Main Body\Save-OpNotes.ps1"
. "$Dependencies\Code\Main Body\Save-OpNotes.ps1"

# This function is called when pressing enter in the text box or click add
Load-Code "$Dependencies\Code\Main Body\OpNoteTextBoxEntry.ps1"
. "$Dependencies\Code\Main Body\OpNoteTextBoxEntry.ps1"


$OpNotesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Enter Your Operator Notes (OpNotes) - Auto-Timestamp:"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 13),1,2,1)
    ForeColor = "Blue"
}
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Load-Code "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
$OpNotesInputTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown = $OpNotesInputTextBoxAdd_KeyDown
}
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesAddButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesAddButton)
CommonButtonSettings -Button $OpNotesAddButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
$OpNotesSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesSelectAllButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesSelectAllButton)
CommonButtonSettings -Button $OpNotesSelectAllButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
$OpNotesOpenOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesOpenOpNotesButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenOpNotesButton)
CommonButtonSettings -Button $OpNotesOpenOpNotesButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
$OpNotesMoveUpButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Up'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveUpButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton)
CommonButtonSettings -Button $OpNotesMoveUpButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)
$OpNotesRightPosition = $OpNotesRightPositionStart


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Remove'
            Location = @{ X = $FormScale * $OpNotesRightPosition
                      Y = $FormScale * $OpNotesDownPosition }
        Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                      Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesRemoveButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton)
CommonButtonSettings -Button $OpNotesRemoveButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
$OpNotesCreateReportButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Create Report"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesCreateReportButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesCreateReportButton)
CommonButtonSettings -Button $OpNotesCreateReportButton

$OpNotesRightPosition += $OpNotesRightPositionShift


$OpNotesOpenReportsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Reports"
        Location = @{ X = $FormScale * $OpNotesRightPosition
                      Y = $FormScale * $OpNotesDownPosition }
        Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                      Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = { Invoke-Item -Path "$PoShHome\Reports" }
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenReportsButton)
CommonButtonSettings -Button $OpNotesOpenReportsButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
$OpNotesMoveDownButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Down'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveDownButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton)
CommonButtonSettings -Button $OpNotesMoveDownButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Load-Code "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
$OpNotesListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "OpNotesListBox"
    Location = @{ X = $FormScale * $OpNotesRightPositionStart
                  Y = $FormScale * $OpNotesDownPosition + 5 }
    Size     = @{ Width  = $FormScale * $OpNotesMainTextBoxWidth
                  Height = $FormScale * $OpNotesMainTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $false
    Add_MouseEnter = $OpNotesListBoxAdd_MouseEnter
    Add_MouseLeave = $OpNotesListBoxAdd_MouseLeave

}
$Section1OpNotesTab.Controls.Add($OpNotesListBox)

# Obtains the OpNotes to be viewed and manipulated later
$OpNotesFileContents = Get-Content "$OpNotesFile"

# Checks to see if OpNotes.txt exists and loads it
$OpNotesFileContents = Get-Content "$OpNotesFile"
if (Test-Path -Path $OpNotesFile) {
    $OpNotesListBox.Items.Clear()
    foreach ($OpNotesEntry in $OpNotesFileContents){ $OpNotesListBox.Items.Add("$OpNotesEntry") }
}